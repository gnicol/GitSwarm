Adding a migration will bump the db/schema.rb version. We don't want to have
our migration timestamps newer than the community ones, since we could end up
skipping some of their migrations.

Please ensure that the timestamps on your migrations in this directory are
older than the newest community migration.
