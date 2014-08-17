osxmon-dashing
==============

WARNING: very much a Work In Progress. Please don't expect this to be awesome.

Very basic osx system monitors displayed in dashing.

This is a personal project for me to learn about ruby, coffee, and dashing. So much for learning one thing at a time...
Once I complete this, I'm hoping to use the knowledge to build other dashing boards.

Display panels:

clock: time/date
list: system name & network addresses/interfaces
list: top 10 procs by cpu %
list: top 10 procs by mem %
graph: net rx
graph: net tx
graph: system load
meter: disk % used

Dependencies:

ruby gems:
  - socket
  - usagewatch_ext

Dashing:
  see: http://dashing.io/
  
