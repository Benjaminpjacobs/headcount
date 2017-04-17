class District
  attr_accessor :name, :repo

  def initialize(args)
    @name = args[:name]
    @repo = args[:repo]
  end

  def statewide_test
    @repo.statewide_test_repository.tests[@name]
  end

  def enrollment
    @repo.enrollment_repository.enrollment[@name]
  end

  def economic_profile
    @repo.economic_profile_repository.profiles[@name]
  end

end