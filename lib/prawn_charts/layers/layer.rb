
require 'prawn_charts/layers/layer'

module PrawnCharts
  module Layers

    # PrawnCharts::Layers::Layer contains the basic functionality needed by the various types of graphs.  The Base
    # class is responsible holding layer information such as the title and data points.
    #
    # When the graph is rendered, the graph renderer calls Base#render.  Base#render sets up
    # some standard information, and calculates the x,y coordinates of each data point.  The draw() method,
    # which should have been overridden by the current instance, is then called.  The actual rendering of
    # the graph takes place there.
    #
    # ====Create New Graph Types
    #
    # Assuming the information generated by PrawnCharts::Layers::Layer is sufficient, you can create a new graph type
    # simply by overriding the draw() method.  See Base#draw for arguments.
    #
    class Layer
      # The following attributes are user-definable at any time.
      # title, points, relevant_data, preferred_color, options
      attr_accessor :title
      attr_accessor :points
      attr_accessor :relevant_data
      attr_accessor :preferred_color
      attr_accessor :preferred_outline
      attr_accessor :options          # On-the-fly values for easy customization / acts as attributes.

      # The following attributes are set during the layer's render process,
      # and act more as a record of what just happened for later processes.
      # height, width, min_value, max_value, color, opacity, complexity
      attr_reader :height, :width
      attr_reader :min_value, :max_value
      attr_reader :color
      attr_reader :outline
      attr_reader :opacity
      attr_reader :complexity

      # Returns a new Base object.
      #
      # Any options other that those specified below are stored in the @options variable for
      # possible later use.  This would be a good place to store options needed for a custom
      # graph.
      #
      # Options:
      # title:: Name/title of data group
      # points:: Array of data points
      # preferred_color:: Color used to render this graph, overrides theme color.
      # preferred_outline:: Color used to render this graph outline, overrides theme outline.
      # relevant_data:: Rarely used - indicates the data on this graph should not
      #                 included in any graph data aggregations, such as averaging data points.
      # style:: pdf polyline style. (default: 'fill-opacity: 0; stroke-opacity: 0.35')
      # stroke_width:: numeric value for width of line (0.1 - 10, default: 1)
      # relativestroke:: stroke-width relative  to image size? true or false (default)
      # shadow:: Display line shadow? true or false (default)
      # dots:: Display co-ord dots? true or false (default)
      def initialize(options = {})
        @title              = options.delete(:title) || ''
        @preferred_color    = options.delete(:color)
        @preferred_outline    = options.delete(:outline)
        @relevant_data      = options.delete(:relevant_data) || true
        @points             = options.delete(:points) || []
        @points.extend PrawnCharts::Helpers::PointContainer unless @points.kind_of? PrawnCharts::Helpers::PointContainer

        options[:stroke_width] ||= 1
        options[:dots] ||= false
        options[:shadow] ||= false
        options[:style] ||= false
        options[:relativestroke] ||= false

        @options            = options

      end

      # Renders the layer to a Prawn PDF Document
      # This method actually generates data needed by this graph, then passes the
      # rendering responsibilities to Base#draw.
      #
      # pdf:: a Prawn PDF Document object.
      def render(pdf, options)
        setup_variables(options)
        coords = generate_coordinates(options)

        draw(pdf, coords, options)
      end

      # The method called by Base#draw to render the graph.
      #
      # pdf:: a Prawn PDF Document object.
      # coords:: An array of coordinates relating to the graph's data points.  ie: [[100, 120], [200, 140], [300, 40]]
      # options:: Optional arguments.
      def draw(pdf, coords, options={})
        raise RenderError, "You must override the Base#draw method."
      end

      # Returns a hash with information to be used by the legend.
      #
      # Alternatively, returns nil if you don't want this layer to be in the legend,
      # or an array of hashes if this layer should have multiple legend entries (stacked?)
      #
      # By default, #legend_data returns nil automatically if relevant_data is set to false
      # or the @color attribute is nil.  @color is set when the layer is rendered, so legends
      # must be rendered AFTER layers.
      def legend_data
        if relevant_data? && @color
          {:title => title,
            :color => @color,
            :priority => :normal}
        else
          nil
        end
      end

      # Returns the value of relevant_data
      def relevant_data?
        @relevant_data
      end

      # The highest data point on this layer, or nil if relevant_data == false
      def top_value
        @relevant_data ? points.maximum_value : nil
      end

      # The lowest data point on this layer, or nil if relevant_data == false
      def bottom_value
        @relevant_data ? points.minimum_value : nil
      end

      # The highest data point on this layer, or nil if relevant_data == false
      def bottom_key
        @relevant_data ? points.minimum_key : nil
      end

      # The lowest data point on this layer, or nil if relevant_data == false
      def top_key
        @relevant_data ? points.maximum_key : nil
      end

      # The sum of all values
      def sum_values
        points.sum
      end

      protected
      # Sets up several variables that almost every graph layer will need to render
      # itself.
      def setup_variables(options = {})
        @color = (preferred_color || options.delete(:color))
        @outline = (preferred_outline || options.delete(:outline))
        @width, @height = options.delete(:size)
        @min_value, @max_value = options[:min_value], options[:max_value]
        @opacity = options[:opacity] || 1.0
        @complexity = options[:complexity]
      end

      # Optimistic generation of coordinates for layer to use.  These coordinates are
      # just a best guess, and can be overridden or thrown away (for example, this is overridden
      # in pie charting and bar charts).

      # Updated : Assuming n number of points, the graph is divided into n rectangles
      # and the points are plotted in the middle of each rectangle.  This allows bars to
      # play nice with lines.
      def generate_coordinates(options = {})
        dy = height.to_f / (options[:max_value] - options[:min_value])
        dx = width.to_f / (options[:max_key] - options[:min_key] + 1)

        ret = []
        points.each_point do |x, y|
          if y
            x_coord = dx * (x - options[:min_key]) + dx/2
            y_coord = dy * (y - options[:min_value])

            ret << [x_coord, height - y_coord]
          end
        end
        return ret
      end

      # Converts a percentage into a pixel value, relative to the height.
      #
      # Example:
      #   relative(5)   # On a 100px high layer, this returns 5.  200px high layer, this returns 10, etc.
      def relative(pct)
        # Default to Relative Height
        relative_height(pct)
      end

      def relative_width(pct)
        if pct # Added to handle nils
          @width * (pct / 100.to_f)
        end
      end

      def relative_height(pct)
        if pct # Added to handle nils
          @height * (pct / 100.to_f)
        end
      end

      # Some pdf elements take a long string of multiple coordinates.  This is here
      # to make that a little easier.
      def stringify_coords(coords) # :nodoc:
        coords.map { |c| c.join(',') }
      end
    end # Layer

  end # Layers
end # PrawnCharts