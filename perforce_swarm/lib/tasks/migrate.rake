# Fixes an issue where initial schema load doesn't include any our our migrations.
# This has will be fixed in rails 4.1.12 and 4.2.3 by this commit:
# https://github.com/rails/rails/commit/d670db5023e24fe1c355fca0c3ed899edfbc17cf#diff-28a5ae383b291583c513ad8eeed99a3a

Rake::Task['db:schema:load'].clear_prerequisites
Rake::Task['db:schema:load'].enhance([:environment, :load_config])
