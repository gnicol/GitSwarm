Rails.application.routes.draw do
  # Help
  # Overrides the key route for help to handle images at any depth
  # within the /doc path (as well as doc files at any depth)
  get 'help/*category/:file'  => 'help#show'
end
