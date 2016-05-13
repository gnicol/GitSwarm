assets = Rails.root.join('perforce_swarm/app/assets/')
Rails.configuration.assets.paths = Dir.entries(assets)
                                      .select { |f| f != '.' && f != '..' && File.directory?(assets.join(f)) }
                                      .map { |f| assets.join(f).to_s }
                                      .concat(Rails.configuration.assets.paths)
