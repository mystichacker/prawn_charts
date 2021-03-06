
require 'prawn_charts/layers/layer'

module PrawnCharts
  module Layers

    # An 'average' graph.  This graph iterates through all the layers and averages
    # all the data at each point, then draws a thick, translucent, shadowy line graph
    # indicating the average values.
    class Average < Layer
      attr_reader :layers

      # Returns new Average graph.
      def initialize(options = {})
        # Set self's relevant_data to false.  Otherwise we get stuck in a
        # recursive loop.
        super(options.merge({:relevant_data => false}))

        # The usual :points argument is actually layers for Average, name it as such
        @layers = options[:points]
      end

      # Render average graph.
      def draw(pdf, coords, options = {})
        #pdf.polyline( :points => coords.join(' '), :fill => 'none', :stroke => 'black',
        #  'stroke-width' => relative(5), 'opacity' => '0.4')
        px, py = (coords[0].first), coords[0].last
        coords.each_with_index do |coord,index|
          x, y = (coord.first), coord.last
          unless index == 0
            #pdf.text_mark "line stroke_line [#{px}, #{height-py}], [#{x}, #{height-y}]"
            pdf.transparent(0.5) do
              pdf.stroke_color = outline_color
              pdf.stroke_line [px, height-py], [x, height-y]
            end
          end
          px, py = x, y
        end
      end

      protected
      # Override default generate_coordinates method to iterate through the layers and
      # generate coordinates based on the average data points.
      def generate_coordinates(options = {})
        key_layer = layers.find { |layer| layer.relevant_data? }

        options[:point_distance] = width / (key_layer.points.size - 1).to_f

        coords = []

        #TODO this will likely break with the new hash model
        key_layer.points.each_with_index do |layer, idx|
          sum, objects = points.inject([0, 0]) do |arr, elem|
            if elem.relevant_data?
              arr[0] += elem.points[idx]
              arr[1] += 1
            end
            arr
          end

          average = sum / objects.to_f

          x_coord = options[:point_distance] * idx

          relative_percent = ((average == min_value) ? 0 : ((average - min_value) / (max_value - min_value).to_f))
          y_coord = (height - (height * relative_percent))

          coords << [x_coord, y_coord].join(',')
        end

        return coords
      end

    end # Average

  end # Layers
end # PrawnCharts