require 'erb'

class Chart
  def enrollment(name, statistics, stat, stat_label)
    enrollment_view = File.read "./views/enrollment_erb_template.erb"
    erb_template = ERB.new enrollment_view
    data = statistics[stat].values
    years = statistics[stat].keys.map{|year| year.to_s}
    label = [stat_label]
    title = ["#{stat_label} for #{name}"]
    data_set = erb_template.result(binding)
     
    Dir.mkdir("output/#{name}") unless Dir.exists? "output/#{name}"
    filename = "output/#{name}/#{name}_#{stat_label}_enrollment_data.html"

    File.open(filename, 'w') do |file|
      file.puts data_set
    end
    
  end
end