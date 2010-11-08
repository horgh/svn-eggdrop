#!/usr/local/bin/tclsh8.5
#
# svn_sock_spew.tcl - 0.1
#
# Created Feb 10 2010
# Will Storey
#
# Connect to a port and output a string
#
# To be used as post-commit hook script for svn
#
# e.g. place: /home/dev/public_html/scripts/svn_sock_spew.tcl "#channel" "$REPOS" "$REV"
# in hooks/post-commit
#
# Couple with a bot running svn.tcl this will output to the given channel a string about the commit
#
# Set ip and port to those matching svn.tcl
#

set ip 127.0.0.1
set port 12345

proc spew {str} {
	set chan [socket $::ip $::port]
	puts $chan $str
	close $chan
}

# Args: IRC channel, repo (/path/to/repo), revision
proc commit_info {channel repo rev} {
	catch {exec /usr/local/bin/svnlook author $repo --revision $rev} author
	catch {exec /usr/local/bin/svnlook changed $repo --revision $rev} changed
	catch {exec /usr/local/bin/svnlook log $repo --revision $rev} log
	set changed [split $changed \n]
	set num_changed [llength $changed]

	set repo [string range $repo [expr [string last "/" $repo] + 1] end]

	set output "\[\002$repo\002\] r$rev $author ($num_changed files changed:"

	set files []
	foreach line $changed {
		set files "${files}[lindex $line 1] "
	}
	set files [string trim $files]

	set output "$output $files):"

	# comments
	foreach line [split $log \n] {
		set output "$output $line"
	}

	return [list $channel $output]
}

spew [commit_info {*}$argv]
