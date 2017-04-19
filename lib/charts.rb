require 'erb'
require 'pry'

class Chart

  def initialize
    @data = {}
  end

  def make_chart(args)
    erb_template = erb_object(args[:directory])
    study = args[:repo][args[:study_heading]]
    which_add_data(study, args)
    data_set = erb_template.result(binding)
    make_dir(args[:directory], args[:name])
    filename = file_name(args[:name], args[:stat_label], args[:directory])
    write_files(filename, data_set)
  end

  private

  def which_add_data(study, args)
    if args[:directory] == "enrollment"
      add_enrollment_to_data(study, args[:stat_label], args[:name])
    elsif args[:directory] == "economic_profile"
      add_economic_profile_to_data(study, args[:stat_label], args[:name])
    elsif args[:directory] == "statewide_test"
      add_tests_to_data(study, args[:stat_label], args[:name])
    end
  end

  def add_tests_to_data(study, stat_label, name)
    @data =
    {
    st_years: study.keys.map{|year| year.to_s.split("_").join(" ").capitalize},
    st_data1: study.values.map{|value| value[0][1]},
    st_data2: study.values.map{|value| value[1][1]},
    st_data3: study.values.map{|value| value[2][1]},
    st_label1: [study.values[0][0][0].to_s],
    st_label2: [study.values[0][1][0].to_s],
    st_label3: [study.values[0][2][0].to_s],
    st_title: ["#{stat_label} Proficiency for #{name}"],
    }
  end

  def add_economic_profile_to_data(study, stat_label, name)
    @data =
    {
    economic_years: format_years(study),
    economic_data: format_data(study),
    economic_label: [stat_label],
    economic_title:["#{stat_label} for #{name}"]
    }
  end

  def add_enrollment_to_data(study, stat_label, name)
    @data =
    {
    enrollment_data: study.values,
    enrollment_years: study.keys.map{|year| year.to_s},
    enrollment_label: [stat_label],
    enrollment_title: ["#{stat_label} for #{name}"],
    }
  end

  def format_years(study)
    study.keys.map do |year|
      year_or_range(year)
    end
  end

  def year_or_range(year)
    if year.is_a?(Integer)
      year.to_s.split("_").join(" ").capitalize
    else
      year.join("-")
    end
  end

  def format_data(study)
    if data_is_hash(study)
      study.values.map{|value| value[:percentage]}
    else
      study.values
    end
  end

  def data_is_hash(study)
    study.values[0].is_a?(Hash)
  end

  def erb_object(study_heading)
    enrollment_view = File.read "./views/#{study_heading}_erb_template.erb"
    ERB.new enrollment_view
  end

  def file_name(name, stat_label, directory)
    "output/#{name}/#{directory}/#{name}_#{stat_label}_#{directory}_data.html"
  end

  def write_files(filename, data_set)
    File.open(filename, 'w') do |file|
      file.puts data_set
    end
  end

  def make_dir(statistic, name)
    Dir.mkdir("output") unless Dir.exists? "output"
    Dir.mkdir("output/#{name}") unless Dir.exists? "output/#{name}"
    Dir.mkdir("output/#{name}/#{statistic}") unless
    Dir.exists? "output/#{name}/#{statistic}"
  end

end