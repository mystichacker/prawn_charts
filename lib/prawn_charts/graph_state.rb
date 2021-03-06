
# State object for holding all of the graph's
# settings.  Attempting to clean up the
# graph interface a bit.
module PrawnCharts

  class GraphState
    attr_accessor :title
    attr_accessor :x_legend
    attr_accessor :y_legend
    attr_accessor :theme
    attr_accessor :default_type
    attr_accessor :point_markers
    attr_accessor :point_markers_rotation
    attr_accessor :point_markers_ticks
    attr_accessor :value_formatter
    attr_accessor :key_formatter
    attr_accessor :marks

    def initialize
    end
  end # GraphState

end # PrawnCharts
