# svn.tcl - 0.1
#
# Will Storey
# Created Feb 10 2010
#
# Socket -> channel output
#
# Listen for conn on given port and spew output to given channel
#
# Format of string from connection is [list $channel $output]
#
# Setup:
# - Set svn::port, svn::ip as which you want bot to listen for commit info on
# - By default we listen on all 127.0.0.1. I recommend filtering outside
#   connections to this ip and port as we don't check whether input is valid
#

namespace eval svn {
	variable ip 127.0.0.1
	variable port	12345
	variable server_chan
	variable output_cmd "putserv"

	bind evnt -|- "prerehash" svn::svn_reload
}

# Split long line into list of strings for multi line output to irc
# Splits into strings of ~max
# by fedex
proc svn::split_line {max str} {
  set last [expr {[string length $str] -1}]
  set start 0
  set end [expr {$max -1}]

  set lines []

  while {$start <= $last} {
    if {$last >= $end} {
      set end [string last { } $str $end]
    }

    lappend lines [string trim [string range $str $start $end]]
    set start $end
    set end [expr {$start + $max}]
  }

  return $lines
}

proc svn::svn_listen {chan addr port} {
	set output [gets $chan]
	close $chan

	set channel [lindex $output 0]
	set commit [lindex $output 1]

	foreach line [svn::split_line 400 $commit] {
		$svn::output_cmd "PRIVMSG $channel :$line"
	}
}

# As we need to free listening port to relisten, close on rehash
proc svn::svn_reload {args} {
	close $svn::server_chan
}

set svn::server_chan [socket -server svn::svn_listen -myaddr $svn::ip $svn::port]
