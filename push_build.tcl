#!/usr/local/bin/tclsh8.5
#
# push_build.tcl
#
# by cd
# feb 11 2010
#
# This updates a checked out version of repository to the latest version
#
# called with argument "myquote" if dir is called /home/dev/public_html/myquote
# and repo is called /home/dev/repo/someshit/myquote
#

set repo $argv
set repo [string range $repo [expr [string last "/" $repo] + 1] end]

catch {exec /usr/local/bin/svn update --username cd --password h3ll0 /home/dev/public_html/${repo}} output
#puts $output
