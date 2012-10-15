
require 'prawn_charts/renderers/empty'

module PrawnCharts
  module Renderers

    class AxisLegend < Empty
      def define_layout
        super do |components|
          components << PrawnCharts::Components::Title.new(:title, :position => [5, 2], :size => [90, 7])


          components << PrawnCharts::Components::Viewport.new(:view, :position => [6, 22], :size => [90, 66]) do |graph|
            graph << PrawnCharts::Components::ValueMarkers.new(:values, :position => [0, 2], :size => [8, 89])
            graph << PrawnCharts::Components::Grid.new(:grid, :position => [10, 0], :size => [90, 89], :stroke_width => 1)
            graph << PrawnCharts::Components::VerticalGrid.new(:vertical_grid, :position => [10, 0], :size => [90, 89], :stroke_width => 1)
            graph << PrawnCharts::Components::DataMarkers.new(:labels, :position => [10, 92], :size => [90, 8])
            graph << PrawnCharts::Components::Graphs.new(:graphs, :position => [10, 0], :size => [90, 89])
          end
          components << PrawnCharts::Components::YLegend.new(:y_legend, :position => [1, 26], :size => [5, 66])
          components << PrawnCharts::Components::XLegend.new(:x_legend, :position => [5, 92], :size => [90, 6])
          components << PrawnCharts::Components::Legend.new(:legend, :position => [5, 13], :size => [90, 6])
        end
      end

      protected
      def hide_values
        super
        component(:view).position[0] = -10
        component(:view).size[0] = 100
      end

      def labels
        [component(:view).component(:labels)]
      end

      def values
        [component(:view).component(:values)]
      end

      def grids
        [component(:view).component(:grid),component(:view).component(:vertical_grid)]
      end
    end # AxisLengend

  end # Renderers
end # PrawnCharts