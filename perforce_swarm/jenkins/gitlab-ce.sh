#!/bin/bash
#
# Gitlab-ce Integration Script
#
# Merges Community master into our integration-ce branch,
# does a diff of the Gemfile and Gemfile.lock,
# then runs a bundle install to regenerate the Gemfile.lock
# with our stuff.  It then repeats this, but using the
# integration-prep-ce branch.
#
# Finishes by pushing the lot to origin so Jenkins tests can be run
# See docs/integration_steps.txt for additional details.
#

# Make sure we use the Ruby version in rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

function bomb_if_bad {
	"$@" 2>&1
	local status=$?
	if [ $status -ne 0 ]; then
		echo "::: CONFLICT!!! :::"
		exit 1
	fi
	return $status
}

REPO="gitlab-ce"

# passed in by Jenkins, set if running manually
# STABLE_BRANCH=
# DB_USER=
# DB_PASS=
# DB_NAME=

# Logs
now=$(date "+%Y-%m-%d-%H%M")
ruby_loc=`which ruby`
ruby_ver=`ruby -v`
bundle_loc=`which bundle`
echo "::: ${now} Integrating Community master/stable into ${REPO} :::"
echo "::: Using ${ruby_ver} from ${ruby_loc} :::"
echo "::: Bundler is at: ${bundle_loc} :::"

# Update the master, prep, integration-ce and integration-prep-ce
# branches from origin
echo "::: Fetching from remotes :::"
git fetch --all
echo "::: Merging origin changes, Should only be fast-forwards :::"
echo "::: Merging origin/master -> master :::"
git checkout master
git merge origin/master
echo "::: Merging origin/prep -> prep :::"
git checkout prep
git merge origin/prep
echo "::: Merging origin/integration-ce -> integration-ce :::"
git checkout integration-ce
git merge origin/integration-ce
echo "::: Merging origin/integration-prep-ce -> integration-prep-ce :::"
git checkout integration-prep-ce
git merge origin/integration-prep-ce

# Copy-up master into integration-ce
echo "::: Copy-up (aka merge-theirs) master -> integration-ce :::"
git checkout integration-ce
bomb_if_bad git merge --strategy-option theirs master -m "Copying master into integration-ce"

# Copy-up prep into integration-prep-ce
echo "::: Copy-up (aka merge-theirs) prep -> integration-prep-ce :::"
git checkout integration-prep-ce
bomb_if_bad git merge --strategy-option theirs prep -m "Copying prep into integration-prep-ce"

git checkout integration-ce

# Checkout the Gemfile.lock and db/schema.rb from community to serve as the base for master
echo "::: Checking out Gemfile.lock and db/schema.rb from community master :::"
git checkout origin/community-master -- Gemfile.lock db/schema.rb
git add Gemfile.lock db/schema.rb
git commit -m "Cleanup Gemfile.lock and db/shema.rb changes"

# Now merge the Community master into integration-ce
echo "::: merge origin/community-master -> integration-ce :::"
bomb_if_bad git merge origin/community-master -m "Merging community into master"

# Get the gemfile diffs and store them
echo "::: Diff for community Gemfile, vs master :::"
git diff origin/community-master master -- Gemfile

# Run bundle install
echo "::: Running bundle install on integration-ce :::"
bundle install

# Load the db scheme
echo "::: Load the database schema :::"
cp config/database.yml.postgresql  config/database.yml
sed "s/username\:.*$/username\: ${DB_USER}/" -i config/database.yml
sed "/test\: \&test/a \  host: localhost" -i config/database.yml
sed "s/password\:.*$/password\: ${DB_PASS}/" -i config/database.yml
sed "s/gitlabhq_test/${DB_NAME}/" -i config/database.yml
bundle exec rake db:setup

# Run db migrate
echo "::: Running db:migrate on ${DB_NAME} :::"
bundle exec rake db:migrate

# Clear datebase
echo "::: Clearing Database ${DB_NAME} :::"
bundle exec rake db:drop
rm config/database.yml

# Run a diff of resulting Gemfile.lock with master
echo "::: Diff for master Gemfile.lock and db/schema.rb :::"
git diff --staged Gemfile.lock db/schema.rb

# Add the modified Gemfile.lock and db/schema.rb.  This should happen cleanly.
echo "::: Adding modified Gemfile.lock and db/schema, if present :::"
git add Gemfile.lock db/schema.rb
git commit -m "Gemfile.lock and db/schema.rb changes"

# Push the integration-ce branch to origin for testing
echo "::: Pushing integration-ce to origin for testing :::"
git push origin integration-ce

git checkout integration-prep-ce

# Checkout the Gemfile.lock and db/schema.rb from community to serve as a base
echo "::: Checking out Gemfile.lock from ${STABLE_BRANCH} :::"
git checkout origin/${STABLE_BRANCH} -- Gemfile.lock db/schema.rb
git add Gemfile.lock db/schema.rb
git commit -m "Cleanup Gemfile.lock and db/shema.rb changes"

# Merge the community-stable branch into integration-prep-ce
echo "::: Merging origin/${STABLE_BRANCH} -> integration-prep-ce :::"
bomb_if_bad git merge origin/${STABLE_BRANCH} -m "Merging ${STABLE_BRANCH} into integration-prep-ce"

# Get the gemfile diffs and store them
echo "::: Diff for ${STABLE_BRANCH} Gemfile, vs prep :::"
git diff origin/${STABLE_BRANCH} prep -- Gemfile

# Run bundle install
echo "::: Running bundle install on integration-prep-ce :::"
bundle install

# Load the db scheme
echo "::: Load the database schema :::"
cp config/database.yml.postgresql  config/database.yml
sed "s/username\:.*$/username\: ${DB_USER}/" -i config/database.yml
sed "/test\: \&test/a \  host: localhost" -i config/database.yml
sed "s/password\:.*$/password\: ${DB_PASS}/" -i config/database.yml
sed "s/gitlabhq_test/${DB_NAME}/" -i config/database.yml
bundle exec rake db:setup

# Run db migrate
echo "::: Running db:migrate on ${DB_NAME} :::"
bundle exec rake db:migrate

# Clear database
echo "::: Clearing Database ${DB_NAME} :::"
bundle exec rake db:drop
rm config/database.yml

# Run a diff of the resulting Gemfile.lock with prep
echo "::: Diff for prep Gemfile.lock :::"
git diff --staged Gemfile.lock db/schema.rb

# Add the modified Gemfile.lock and db/schema.rb.  This should happen cleanly
git add Gemfile.lock db/schema.rb
git commit -m "Adding modified Gemfile.lock and db/schema.rb"

# Push integration-prep-ce to origin for testing
echo "::: Pushing integration-prep-ce to origin for testing :::"
git push origin integration-prep-ce

# Reset to master branch
git checkout master
echo $now












