
require 'prawn_charts/layers/layer'

module PrawnCharts
  module Layers

    # Provides a container for pie slice.
    class Pie < Layer
      include PrawnCharts::Helpers::LayerContainer

      # Basic Example:
      #
      #   graph = PrawnCharts::Graph.new
      #   graph.title = "Snack Preference"
      #   graph.renderer = PrawnCharts::Renderers::Pie.new
      #   graph.add :pie, 'Example', {'Apples' => 90, 'Orange' => 60, 'Taco' => 30}
      #
      # Or, using a block to add slices:
      #
      #     graph = PrawnCharts::Graph.new
      #     graph.title = "Snack Preference"
      #     graph.renderer = PrawnCharts::Renderers::Pie.new
      #     graph.add :pie do |pie|
      #       pie.add :pie_slice, 'Apple', [90]
      #       pie.add :pie_slice, 'Orange', [60]
      #       pie.add :pie_slice, 'Taco', [30]
      #     end
      #
      # Another Example:
      #   graph.title = "Scruff-Pac!"
      #   graph.renderer = PrawnCharts::Renderers::Pie.new
      #   graph.add :pie, :diameter => 40, :offset_angle => 30 do |pie|
      #     pie.add :pie_slice, '', [160], :preferred_color => "yellow", :shadow => true,
      #             :shadow_x => -1, :shadow_y => 1, :shadow_color=>"black", :shadow_opacity => 0.4
      #     pie.add :pie_slice, '', [50], :preferred_color => "green", :explode => 5, :diameter => 20,
      #           :shadow => true, :shadow_x => -1, :shadow_y => 1, :shadow_color => "black", :shadow_opacity => 0.4
      #   end
      #
      #   graph.add :pie, :diameter => 3, :center_x => 48, :center_y=> 37, :offset_angle => 20 do |pie|
      #     pie.add :pie_slice, '', [160], :preferred_color => "blue", :stroke => "black"
      #   end

      attr_accessor :diameter
      attr_accessor :percent_used
      attr_accessor :offset_angle
      attr_accessor :scaler
      attr_accessor :center_x, :center_y

      # The initialize method passes itself to the block, and since Pie is a
      # LayerContainer, layers (pie slice) can be added just as if they were being
      # added to Graph.
      def initialize(options = {}, &block)
        super(options)

        # Allow for population of data with a block during initialization.
        if block
          block.call(self)
        else
          # Otherwise, just iterate over the points, adding the slices
          #if @points.class == Hash
          #  @points.keys.each {|k|
          #    self.add :pie_slice, k.to_s, [@points[k]]}
          #end
          #if @points.class == Array
            @points.each_with_index do |value,index|
              self.add :pie_slice, @titles.fetch(index,''), [value]
            end
          #end
        end
      end


      # Overrides Base#render to fiddle with layers' points to achieve a stacked
      # effect.
      def render(pdf, options = {})
        @theme = options[:theme] || PrawnCharts::Themes::Theme.default
        # #current_points = points.dup

        @scaler = 1
        total = 0

        layers.each do |layer|
          total += layer.sum_values
        end

        @scaler = 100.0 / total

        @percent_used = 0

        theme.reset_color
        layers.each do |layer|
          layer_options = options.dup
          layer_options = layer_options.merge(@options)
          layer_options = layer_options.merge(layer.options)
          layer_options[:scaler] = @scaler
          layer_options[:percent_used] = @percent_used
          @percent_used += @scaler * layer.sum_values
          layer_options[:color] = layer.preferred_color || layer.color || theme.next_color

          layer.render(pdf, layer_options)
        end
      end

      # A stacked graph has many data sets.  Return legend information for all of them.
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

      def points=(val)
        throw ArgumentsError, "Pie layers cannot accept points, only pie slices."
      end
    end # Pie

  end # Layers
end # PrawnCharts