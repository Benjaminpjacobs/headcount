require 'gchart'

class Chart
  
  def initialize(args)
    @data = args[:data]
    @labels = args[:labels]
    @legend = args[:legend]
    @title = args[:title]
  end

  def chart
    chart = GChart.bar do |g|
      g.data   = @data
      g.colors = [:black ]
      g.legend = @legend

      g.width             = 600
      g.height            = 150
      g.entire_background = "f4f4f4"

      g.axis(:bottom) { |a| a.range = (@data.min..@data.max)}

      g.axis :left do |a|
        a.labels          = @labels
        # a.label_positions = [14.2,    28.4,    43.6,    57.8,    72,   86.2, 100]
        a.text_color      = :black
      end
    
      g.axis :left do |a|
        a.labels          = [@title]
        a.label_positions = [50]
      end
    end

    title = @title
    chart.write title 
  end
  
end