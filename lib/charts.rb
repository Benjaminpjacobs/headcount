require 'erb'
require 'pry'

class Chart
  def enrollment(name, statistics, stat, stat_label)
    enrollment_view = File.read "./views/enrollment_erb_template.erb"
    erb_template = ERB.new enrollment_view
    data = statistics[stat].values
    years = statistics[stat].keys.map{|year| year.to_s}
    label = [stat_label]
    title = ["#{stat_label} for #{name}"]
    data_set = erb_template.result(binding)

    make_dir("enrollment", name)
    
    filename = "output/enrollment/#{name}/#{name}_#{stat_label}_enrollment_data.html"

    write_files(filename, data_set)
  end

  def statewide_tests(name, statistics, which_stat, stat_label)
    test_view = File.read "./views/statewide_test_erb_template.erb"
    erb_template = ERB.new test_view
    years = statistics[which_stat].keys.map{|year| year.to_s.split("_").join(" ").capitalize}
    data1 = statistics[which_stat].values.map{|value| value[0][1]}
    data2 = statistics[which_stat].values.map{|value| value[1][1]}
    data3 = statistics[which_stat].values.map{|value| value[2][1]}
    label1 = [statistics[which_stat].values[0][0][0].to_s]
    label2 = [statistics[which_stat].values[0][1][0].to_s]
    label3 = [statistics[which_stat].values[0][2][0].to_s]
    title = ["#{stat_label} Proficiency for #{name}"]
    data_set = erb_template.result(binding)

    make_dir("statewide_testing", name)
    
    filename = "output/statewide_testing/#{name}/#{name}_#{stat_label}_statewide_testing_data.html"

    write_files(filename, data_set)
  end

  def economic_profile(name, statistics, which_stat, stat_label)
    # binding.pry
    enrollment_view = File.read "./views/economic_profile_erb_template.erb"
    erb_template = ERB.new enrollment_view
    years = statistics[which_stat].keys.map do |year| 
      if year.is_a?(Integer)
        year.to_s.split("_").join(" ").capitalize
      else
        year.join("-")    
      end
    end
    
    data1 = 

    if statistics[which_stat].values[0].is_a?(Hash)
      statistics[which_stat].values.map{|value| value[:percentage]}
    else  
      statistics[which_stat].values
    end
    
    label1 = [stat_label]
    title = ["#{stat_label} for #{name}"]
    data_set = erb_template.result(binding)

    make_dir("economic_profile", name)
    
    filename = "output/economic_profile/#{name}/#{name}_#{stat_label}economic_profile_data.html"

    write_files(filename, data_set)
    
  end

  def write_files(filename, data_set)
    File.open(filename, 'w') do |file|
      file.puts data_set
    end
  end

  def make_dir(statistic, name)
    Dir.mkdir("output") unless Dir.exists? "output"
    Dir.mkdir("output/#{statistic}") unless Dir.exists? "output/#{statistic}"
    Dir.mkdir("output/#{statistic}/#{name}") unless Dir.exists? "output/#{statistic}/#{name}"
  end

end