#!/bin/bash

# Copyright (C) 2012 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

if [ -z "$2" ]; then
  echo "Usage:  $0 <build_name> <task>"
  exit
fi

# Default options for gem commands
gem_opts='--no-rdoc --no-ri'

# Load RVM as a function so we can switch from within the script
# https://rvm.beginrescueend.com/workflow/scripting/
. "$HOME/.rvm/scripts/rvm"

# If there is an .rvmrc, grab the ruby version from it - default to 1.8.7
ruby='1.8.7'
if [ -e '.rvmrc' ]; then
	# Get ruby version from .rvmrc
	ruby=`cat .rvmrc | sed "s:.* \(.*\)@.*:\1:"`
fi

# Get gemset name NOT from .rvmrc but from build name
# This is to avoid conflicts with different builds of same
# codebase
gemset=$1
# Set up correct ruby
if ! (rvm list | grep $ruby); then
      rvm install $ruby
fi

# Use correct ruby
rvm use $ruby@$gemset --create

# If we're using bundler (i.e. there is a Gemfile)
rake='rake'
if [ -e 'Gemfile' ]; then
	# Make sure bundler is installed
	gem install bundler $gem_opts
	# Then run bundle to install dependencies
	bundle
	# Run rake through bundler
	rake='bundle exec rake'
else
	# If we're NOT using bundler, see if this is a Rails 2 app
	if [ -e 'config/environment.rb' ]; then
		# If so, install correct rails version
		rails=`grep RAILS_GEM_VERSION config/environment.rb | sed "s:.*'\(.*\)'.*:\1:"`
		gem install rails -v=$rails $gem_opts
		# Then install gems
		$rake gems:install
	fi
fi

# If this is a rails app with a db (i.e. there is a config/database.yml)
if [ -e 'config/database.yml' ]; then
	# Run the database migrations
	$rake db:migrate
fi

# Install the CI reporter gem to get JUnit output
gem install ci_reporter $gem_opts
stub=`gem contents ci_reporter | grep stub.rake`


# Get the rake task from the command line and run it
task=$2
$rake -f $stub ci:setup:rspec $task