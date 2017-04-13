require_relative 'enrollment'
require_relative 'district'
require_relative 'statewide_test'
require_relative 'economic_profile'
require 'csv'
require 'pry'

module Repository

  class ObjectFactory
  TYPES = {
      enrollment: Enrollment,
      statewide_test: StatewideTest,
      economic_profile: EconomicProfile
    }

    def self.for(type, attributes)
      TYPES[type].new(attributes)
    end
  end

  def load_individual_study(type, repo, key, value)
    parse_csv(type, repo, key, value).each do |district|
      insert_data(repo, type, district)
    end
  end

  def parse_csv(type, repo, heading, info)
    contents = CSV.open info, headers: true, header_converters: :symbol
    divided_districts = divide_districts(contents)
    formated_districts = format_district_type(type, divided_districts)
    add_study_heading(heading, formated_districts)
  end

  def format_district_type(type, divided_districts)
    if type == :enrollment
      format_district_enrollments(divided_districts)
    elsif type == :statewide_test
      format_district_tests(divided_districts)
    elsif type == :economic_profile
      format_district_profiles(divided_districts)
    end
  end

  def add_study_heading(heading, formated_districts)
    formated_districts.collect do |k, v|
      [heading, k, v]
    end
  end

  def insert_data(repo, type, data)
    if heading_already_exists?(repo, data[1])
      add_new_statistics(repo, data[1], data[0], data[2])
    else
      district = create_new_statistic_object(type, data[1], data[0], data[2])
      add_statistic(repo, district)
    end
  end

  def heading_already_exists?(repo, heading)
    repo.keys.include?(heading)
  end

  def add_new_statistics(repo, heading, study, data)
    repo[heading].statistics[study] = data
  end

  def create_new_statistic_object(type, heading, study, data)
    ObjectFactory.for(type, {:name => heading, study => data})
  end

  def add_statistic(repo, district)
    repo[district.name] = district
  end

  def check_if_na(datum)
    if datum == "N/A" || datum == "NA"
      datum
    else
      datum.to_f
    end
  end

end
