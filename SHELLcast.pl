#!/usr/local/bin/perl -w

# SHELLcast
# by ntheory
#
# March 22nd, 2003 - Started development.
# April 3rd, 2003  - Posted to SourceForge.

# -- <BEHOLD> THE GPL! --
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
# -- </BEHOLD> --

require 5.002;
use IO::Socket;
use IO::Select;
use Term::ReadKey;

# Create a socket to listen to a port
my $Listen = IO::Socket::INET->new(Proto => 'tcp',
				   LocalPort => 2323,
				   Listen => 1,
				   Reuse => 1) or die $!;

# To start with, $select contains only the socket we're listening on
my $Select = IO::Select->new ($Listen);

# Autoflush STDOUT.
$| = 1;

# Read raw data from STDIN
ReadMode 4;

my $Character;

my @Ready;

my $IAC         = chr (0xFF);
my $WILL        = chr (0xFB);

my $ECHO        = chr (0x01);

# Tell the client we'll echo their characters (but we won't).  This
# is just like entering a password on a telnet session.  This way
# the client doesn't echo the characters themselves and make it look
# like they're successfully typing over us.
my $TelnetWillEcho        = $IAC . $WILL . $ECHO;

# wait until there's something to do 
while (1) {
  $Character = ReadKey (0, STDIN);
  @Ready = $Select->can_read (0);

  if (defined ($Character)) {
    # Send this data to our clients.
    if ($Character eq "\n") {
      # Slap an extra CR on there in case the incoming program doesn't send
      # CRLF (just LF).
      $Character .= "\r";
    }

    print $Character;

    for $Socket ($Select->handles) {
      # Skip the listening socket.
      next if ($Socket == $Listen);

      if ($Socket->peername) {
        $Socket->send ($Character);
      }
      else {
        print $Socket->fileno . ": disconnected\n\r";		
        $Select->remove ($Socket);
        $Socket->close;
      }
    }
  }
  
  if (@Ready) {
    my $Socket;

    # Handle each socket that's ready
    for $Socket (@Ready) {
      if ($Socket == $Listen) {
        # Accepts a new connection.
        my $New = $Listen->accept;
        $Select->add ($New);
        print $New->fileno . ": connected\n\r";

	$New->send ($TelnetWillEcho);
      }
    }
  }
}
