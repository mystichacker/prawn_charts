module PrawnCharts::Renderers
  # Provides a more appropriate rendering for Pie Charts.
  # Does not show grid or Data markers, but does add Pie Value Markers.
  class Pie < Base

    def initialize
      self.components = []
      self.components << PrawnCharts::Components::Background.new(:background, :position => [0,0], :size =>[100, 100])
      self.components << PrawnCharts::Components::Graphs.new(:graphs, :position => [-15, 12], :size => [90, 88])
      self.components << PrawnCharts::Components::Title.new(:title, :position => [5, 2], :size => [90, 7])
      self.components << PrawnCharts::Components::Legend.new(:legend, :position => [60, 15], :size => [40, 88], :vertical_legend => true)
    end
  end
  
end