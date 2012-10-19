
require 'prawn_charts/shapes'

module Prawn
  class Document
    include PrawnCharts::Shapes

    def marks?
      @marks || nil
    end

    #--------------------------------------------------------------------------------------------------#

    def show_marks
      @marks = true
    end

    #--------------------------------------------------------------------------------------------------#

    def hide_marks
      @marks = false
    end

    #--------------------------------------------------------------------------------------------------#

    def text_marks_y
      @text_marks_y = bounds.top unless @text_marks_y
      @text_marks_y
    end

    #--------------------------------------------------------------------------------------------------#

    def text_marks_y_down(size)
      @text_marks_y = bounds.top unless @text_marks_y
      @text_marks_y = @text_marks_y - size
    end

    #--------------------------------------------------------------------------------------------------#

    def reset_text_marks
      @text_marks_y = bounds.top
    end

    #--------------------------------------------------------------------------------------------------#

    def text_mark(text, level=:debug, options={})
      return unless marks?
      fill_color (level == :fatal ? 'ff0000' : (level == :error ? '990033' : (level == :warn ? 'ffff00' : (level == :debug ? 'cc0066' : '6699cc'))))
      prefix = (level == :fatal ? 'FATAL' : (level == :error ? 'ERROR' : (level == :warn ? 'WARN' : (level == :debug ? 'DEBUG' : 'INFO'))))
      font_family = "Helvetica"
      font_size = 8
      font(font_family) do
        text_box "#{prefix}: #{text}", :at => [0, text_marks_y], :size => font_size
      end
      fill_color '000000'
      text_marks_y_down(font_size)
    end

    #--------------------------------------------------------------------------------------------------#

    # Draws X and Y axis rulers beginning at the bounding box origin.
    #
    def axis_marks(options={})
      return unless marks?
      options = {:height => (cursor - 20).to_i,
                 :width => bounds.width.to_i
      }.merge(options)

      dash(1, :space => 5)
      stroke_horizontal_line(-21, options[:width], :at => 0)
      stroke_vertical_line(-21, options[:height], :at => 0)
      undash

      fill_circle [0, 0], 3

      (100..options[:width]).step(100) do |point|
        fill_circle [point, 0], 1
        draw_text point, :at => [point-5, -10], :size => 7
      end

      (100..options[:height]).step(100) do |point|
        fill_circle [0, point], 1
        draw_text point, :at => [-17, point-2], :size => 7
      end
    end

    #--------------------------------------------------------------------------------------------------#

    # Draws grid beginning at the margin box origin.
    #
    def grid_marks(options={})
      return unless marks?
      options = {:spacing => [12, 12], :height => (cursor - 20).to_i,
                 :width => bounds.width.to_i
      }.merge(options)

      dash(1, :space => 5)
      dx = options[:spacing][0]
      dy = options[:spacing][1]
      width = options[:width]
      height = options[:height]

      (dx..(width-dx)).step(dx) do |x|
        stroke_vertical_line(dy, height-dy, :at => x)
      end
      (dx..(height-dy)).step(dy) do |y|
        stroke_horizontal_line(dx, width-dx, :at => y)
      end
      undash
    end

    #--------------------------------------------------------------------------------------------------#

    # Draws crop marks at each corner of a bounding box
    #
    def crop_marks(at, width, height)
      return unless marks?
      length = 10
      # upper left
      stroke_horizontal_line(at[0]-length, at[0], :at => at[1])
      stroke_vertical_line(at[1], at[1]+length, :at => at[0])
      # upper right
      stroke_horizontal_line(at[0]+width, at[0]+width+length, :at => at[1])
      stroke_vertical_line(at[1], at[1]+length, :at => at[0]+width)
      # lower right
      stroke_horizontal_line(at[0]+width, at[0]+width+length, :at => at[1]-height)
      stroke_vertical_line(at[1]-height, at[1]-height-length, :at => at[0]+width)
      # upper left
      stroke_horizontal_line(at[0]-length, at[0], :at => at[1]-height)
      stroke_vertical_line(at[1]-height, at[1]-height-length, :at => at[0])
      # dash bounds
      dash(1, :space => 5)
      stroke_rectangle(at, width, height)
      undash
    end

    #--------------------------------------------------------------------------------------------------#

    # Draws centroid mark at center with radius
    #
    # options must include :radius
    #
    def centroid_mark(center, options)
      return unless marks?
      radius = options[:radius] || 12
      pie_slice(center,
                :radius => radius,
                :start_angle => 0,
                :end_angle => Math::HALF_PI,
                :stroke_both_sides => true)
      open_curve(arc_vertices(center,
                              :radius => radius,
                              :start_angle => Math::HALF_PI,
                              :end_angle => Math::PI))
      pie_slice(center,
                :radius => radius,
                :start_angle => Math::PI,
                :end_angle => Math::THREE_HALVES_PI,
                :stroke_both_sides => true)
      open_curve(arc_vertices(center,
                              :radius => radius,
                              :start_angle => Math::THREE_HALVES_PI,
                              :end_angle => 0))
    end

  end
end