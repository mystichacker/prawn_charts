
require 'prawn_charts/layers/layer'

module PrawnCharts
  module Layers

    # Bar graph.
    class Bar < Layer

      def draw(pdf, coords, options = {})
        #puts "bar draw options #{options.awesome_inspect}"
        options.merge!(@options)
        marker = options[:marker] || :circle
        marker_size = options[:marker_size] || 2
        marker_size = (options[:relative]) ? relative(marker_size) : marker_size
        pdf.reset_text_marks
        theme.reset_color
        coords.each_with_index do |coord,idx|
          next if coord.nil?
          color = preferred_color || theme.next_color

          x, y, bar_width = (coord.first), coord.last, 1#(width - coord.last)

          valw = max_value + min_value * -1 #value_width
          maxw = max_value * width / valw #positive area width
          minw = min_value * width / valw #negative area width
          if points[idx] > 0
            bar_width = points[idx]*maxw/max_value
          else
            bar_width = points[idx]*minw/min_value
          end

          #pdf.text_mark "bar rect [#{x},#{y}], #{@bar_height}, #{bar_width}"
          pdf.centroid_mark([x+bar_width/2.0,height-y-@bar_height/2.0],:radius => 3)
          pdf.crop_marks([x,height-y],bar_width,@bar_height)

          current_color = color.is_a?(Array) ? color[idx % color.size] : color

          pdf.fill_color current_color
          #alpha = 1.0
          #pdf.transparent(alpha) do
          pdf.fill_rectangle([0.0,height-y], bar_width, @bar_height)
          #end
          if options[:border]
            theme.reset_outline
            pdf.stroke_color theme.next_outline
            pdf.stroke_rectangle([0.0,height-y],bar_width, @bar_height)
          end
        end

        if marker
          theme.reset_color
          coords.each do |coord|
            x, y = (coord.first), height-coord.last
            color = preferred_color || theme.next_color
            draw_marker(pdf,marker,width-x,y-@bar_height/2.0,marker_size,color)
          end
        end
      end

      def legend_data
        if relevant_data? && @color
          retval = []
          if titles && !titles.empty?
            titles.each_with_index do |stitle, index|
              retval << {:title => stitle,
                         :color => @colors[index],
                         :priority => :normal}
            end
          end
          retval
        else
          nil
        end
      end

      protected

      # Due to the size of the bar graph, X-axis coords must
      # be squeezed so that the bars do not hang off the ends
      # of the graph.
      #
      # Unfortunately this just mean that bar-graphs and most other graphs
      # end up on different points.  Maybe adding a padding to the coordinates
      # should be a graph-wide thing?
      #
      # Update : x-axis coords for lines and area charts should now line
      # up with the center of bar charts.

      def generate_coordinates(options = {})
        dy = @options[:explode] ? relative(@options[:explode]) : 0
        @bar_height = (height / points.size)-dy
        options[:point_distance] = (height - @bar_height ) / (points.size - 1).to_f

        coords = (0...points.size).map do |idx|
          next if points[idx].nil?
          y_coord = (options[:point_distance] * idx) + (height / points.size * 0.5) - (@bar_height * 0.5) - dy/2.0

          relative_percent = ((points[idx] == min_value) ? 0 : ((points[idx] - min_value) / (max_value - min_value).to_f))
          x_coord = (width - (width * relative_percent))
          [x_coord, y_coord]
        end
        coords
      end
    end # Bar

  end # Layers
end # PrawnCharts