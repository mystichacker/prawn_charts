
require 'prawn_charts/layers/layer'

module PrawnCharts
  module Layers

    # Provides a generic way for displaying multiple bar graphs side by side.
    class Multi < Layer
      include PrawnCharts::Helpers::LayerContainer

      # Returns new Multi graph.
      #
      # You can provide a block for easily adding layers during (just after) initialization.
      # Example:
      #   Multi.new do |multi|
      #     multi << PrawnCharts::Layers::Line.new( ... )
      #     multi.add(:multi_bar, 'My Bar', [...])
      #   end
      #
      # The initialize method passes itself to the block, and since multi is a LayerContainer,
      # layers can be added just as if they were being added to Graph.
      def initialize(options={}, &block)
        super(options)

        block.call(self)    # Allow for population of data with a block during initialization.
      end

      # Overrides Base#render to fiddle with layers' points to achieve a multi effect.
      def render(pdf, options = {})
        #TODO ensure this works with new points
        #current_points = points
        layers.each_with_index do |layer,i|

          #real_points = layer.points
          #layer.points = current_points
          layer_options = options.dup

          layer_options[:num_bars] = layers.size
          layer_options[:position] = i
          layer_options[:color] = layer.preferred_color || layer.color || options[:theme].next_color
          layer.render(pdf, layer_options)

          options.merge(layer_options)

          #layer.points = real_points
          #layer.points.each_with_index { |val, idx| current_points[idx] -= val }
        end
      end

      # A multi graph has many data sets.  Return legend information for all of them.
      def legend_data
        if relevant_data?
          retval = []
          layers.each do |layer|
            retval << layer.legend_data
          end
          retval
        else
          nil
        end
      end

      # TODO, special points accessor


      def points=(val)
        throw ArgumentsError, "Multi layers cannot accept points, only other layers."
      end
    end # Multi

  end # Layers
end # PrawnCharts