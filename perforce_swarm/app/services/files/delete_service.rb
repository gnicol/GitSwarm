# The file we are overwriting relative_requires its base_service, so we override it here
# without adding any code for the sole purpose of getting our base service in as well
require_relative 'base_service'
require Rails.root.join('app', 'services', 'files', 'delete_service')
