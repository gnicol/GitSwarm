class Project
  attr_reader :name, :namespace
  attr_accessor :http_url

  def initialize(name, namespace, http_url = nil)
    @name = name
    @namespace = namespace
    @http_url = http_url
  end

  def to_s
    "Project : #{@name}"
  end
end
