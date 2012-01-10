== rvm-bamboo

Build script to help run Ruby builds under RVM with Atlassian Bamboo

Licensed under the BSD 3-Clause license (See LICENSE.txt for details)

Authors: James Smith

Copyright: Copyright (c) 2012 AMEE UK Ltd

Homepage: http://github.com/AMEE/rvm-bamboo

== INSTALLATION

 > git checkout https://github.com/AMEE/rvm-bamboo.git

== REQUIREMENTS

 * RVM
 * Atlassian Bamboo (though this would work with any CI system expecting JUnit output)

== USAGE

1. Set up rvm for your build user
 
See https://rvm.beginrescueend.com/rvm/install/ for details. Don't install as root,
just do the single-user install while logged in as your build user.

 > bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer )
  
Don't worry about adding to the path or sourcing the functions - the script takes care 
of that. You will want to run 

 > rvm requirements
  
and make sure everything you need is installed before proceeding.
 
2. For each build, enter the following as the build command:

 /path/to/build.sh <build_name> <task>
  
For instance, if you are configuring the RUBY-DEV build to run the 'rake spec' task,
you would enter:

 /path/to/build.sh RUBY-DEV spec

3. Check 'this build will produce test results' and enter the following in the box below:

 **/spec/reports/*.xml
 
4. Hit 'save', run your build, and it should just work.

== DETAILS

 * The Ruby version is grabbed from .rvmrc in your source directory, so be sure to check 
   that in.
 * The script creates a gemset for each configuration, named after the build name. The 
   gemset in .rvmrc is ignored.
 * The CI::Reporter gem is automatically included in the build command for JUnit output.
 * Anything that uses bundler will work out of the box, as should Rails 2 apps that use 
   'rake gems:install'