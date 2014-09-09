osxmon-dashing
==============

WARNING: very much a Work In Progress. Please don't expect this to be awesome.
Instructions below are more for me than anything, if they don't make sense to
you that's probably why. :)

Details
==============
Very basic osx system monitors displayed in dashing.

This is a personal project for me to learn about ruby, coffee, and dashing.
So much for learning one thing at a time...
Once I complete this, I'm hoping to use the knowledge to build other dashing
boards.

Display panels:

clock: time/date
list: system name & network addresses/interfaces
list: top 10 procs by cpu %
list: top 10 procs by mem %
graph: net rx MB
graph: net tx MB
graph: system load
meter: disk % used
meter: mem % used

Dependencies:

ruby gems:
gem 'dashing'
gem 'usagewatch_ext'
gem 'nokogiri'
gem 'htmlentities'
gem 'system-getifaddrs'

Dashing:
  see: http://dashing.io/

Install/Run:
  Install Dashing per the instructions at the link above.
  Go to the dashing directory you created, and generate a new dashboard per
    the Dashing docs.
  Clone this repo in the new dashboard directory.
  Add the ruby gems above to the Gemfile.
  Run "bundle install"
  Run "dashing start"

  You'll then be able to reach this board at http://localhost:3030/system


TODO:
  - add system load graph
