
module PrawnCharts
  module Helpers

    # Adds some common functionality to any object which needs to act as a
    # container for graph layers.  The best example of this is the PrawnCharts::Graph
    # object itself, but this module is also used by PrawnCharts::Layer::Stacked.
    module LayerContainer

      # Adds a Layer to the Graph/Container.  Accepts either a list of
      # arguments used to build a new layer, or a PrawnCharts::Layers::Base-derived
      # object.  When passing a list of arguments, all arguments are optional,
      # but the arguments specified must be provided in a particular order:
      # type (Symbol), title (String), points (Array), options (Hash).
      #
      # Both #add and #<< can be used.
      #
      #   graph.add(:line, [100, 200, 150])     # Create and add an untitled line graph
      #
      #   graph << (:line, "John's Sales", [150, 100])    # Create and add a titled line graph
      #
      #   graph << PrawnCharts::Layers::Bar.new({...})   # Adds Bar layer to graph
      #
      def <<(*args, &block)
        if args[0].kind_of?(PrawnCharts::Layers::Layer)
          layers << args[0]
        else
          type = args.first.is_a?(Symbol) ? args.shift : @default_type
          title = args.shift if args.first.is_a?(String)

          # Layer handles PointContainer mixin, don't do it here
          points = [Array, Hash].include?(args.first.class) ? args.shift : []
          options = args.first.is_a?(Hash) ? args.shift : {}

          title ||= ''

          raise ArgumentError,
            'You must specify a graph type (:area, :bar, :line, etc) if you do not have a default type specified.' if type.nil?

          class_name = "PrawnCharts::Layers::#{to_camelcase(type.to_s)}"
          layer_class = Kernel::module_eval(class_name)
          options = {:points => points, :title => title}.merge options
          layer = layer_class.new(options, &block)
          layers << layer
        end
        layer
      end

      alias :add :<<


      # Layer Writer
      def layers=(val)
        @layers = val
      end

      # Layer Reader
      def layers
        @layers ||= []
      end

      # Returns the highest value in any of this container's layers.
      #
      # If padding is set to :padded, a 15% padding is added to the highest value.
      def top_value(padding=nil) # :nodoc:
        topval = layers.inject(0) { |max, layer| (max = ((max < layer.top_value) ? layer.top_value : max)) unless layer.top_value.nil?; max }
        below_zero = (topval <= 0)
        topval = padding == :padded ? (topval + ((topval - bottom_value) * 0.15)) : topval
        (below_zero && topval > 0) ? 0 : topval
      end

      # Returns the lowest value in any of this container's layers.
      #
      # If padding is set to :padded, a 15% padding is added below the lowest value.
      # If the lowest value is greater than zero, then the padding will not cross the zero line, preventing
      # negative values from being introduced into the graph purely due to padding.
      def bottom_value(padding=nil) # :nodoc:
        botval = layers.inject(0) do |min, layer|
          (min = ((min > layer.bottom_value) ? layer.bottom_value : min)) unless layer.bottom_value.nil?
          min
        end
        above_zero = (botval >= 0)
        botval = (botval - ((top_value - botval) * 0.15)) if padding == :padded

        # Don't introduce negative values solely due to padding.
        # A user-provided value must be negative before padding will extend into negative values.
        (above_zero && botval < 0) ? 0 : botval
      end

      def bottom_key(padding=nil)
        return 0 unless layers.any?
        min = layers[0].bottom_key
        layers.each do |layer|
          min = layer.bottom_key if min.nil? && !layer.bottom_key.nil?
          (min = ((min > layer.bottom_key) ? layer.bottom_key : min)) unless layer.bottom_key.nil?
        end
        min
      end

      def top_key(padding=nil)
        return 1 unless layers.any?
        max = layers[0].top_key
        layers.each do |layer|
          max = layer.top_key if max.nil? && !layer.top_key.nil?
          (max = ((max < layer.top_key) ? layer.top_key : max)) unless layer.top_key.nil?
        end
        max
      end

      protected
      def to_camelcase(type)  # :nodoc:
        type.split('_').map { |e| e.capitalize }.join('')
      end

    end # LayerContainer

  end # Helpers
end # PrawnCharts