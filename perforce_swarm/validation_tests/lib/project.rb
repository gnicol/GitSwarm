class Project
  attr_reader :name
  attr_accessor :http_url

  def initialize(name, http_url = nil)
    @name = name
    @http_url = http_url
  end

  def to_s
    "Project : #{@name}"
  end
end
