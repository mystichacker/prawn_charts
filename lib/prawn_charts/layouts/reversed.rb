
require 'prawn_charts/layouts/layout'

module PrawnCharts
  module Layouts

    class Reversed < Layout
      def define_layout
        self.components << PrawnCharts::Components::Background.new(:background, :position => [0,0], :size =>[100, 100])
        self.components << PrawnCharts::Components::Title.new(:title, :position => [98, 95], :size => [1, 3], :text_anchor => 'end')
        #self.components << PrawnCharts::Components::Grid.new(:grid, :position => [14, 12], :size => [78.5, 70])
        self.components << PrawnCharts::Components::ValueMarkers.new(:value_markers, :position => [2, 14], :size => [10, 70])
        self.components << PrawnCharts::Components::DataMarkers.new(:data_markers, :position => [14, 3.5], :size => [78.5, 4])
        self.components << PrawnCharts::Components::Graphs.new(:graphs, :position => [14, 12], :size => [78.5, 70])
        self.components << PrawnCharts::Components::Legend.new(:legend, :position => [3, 90], :size => [55, 6])
      end
    end # Reversed

  end # Layouts
end # PrawnCharts
