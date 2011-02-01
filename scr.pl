#!/usr/local/bin/perl -w

# SHELLcast Recorder -- scr
# by ntheory
#
# April 23rd, 2003 - Started development.

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

use IO::Socket;
use IO::Select;
use Time::HiRes;

$Address = $ARGV [0];
$Port    = $ARGV [1];

# Create a socket and connect to the SHELLcast
my $Socket = IO::Socket::INET->new(Proto => 'tcp',
				   PeerAddr => $Address,
				   PeerPort => $Port) or die $!;

die "Couldn't connect: $!\n" unless $Socket;

# Autoflush STDOUT and socket
$| = 1;
$Socket->autoflush (1);

my $StartTime = Time::HiRes::time;

while (sysread ($Socket, $Input, 1)) {
  $CurrentTime = Time::HiRes::time;

  print ($CurrentTime - $StartTime);
  print "|";

  for ($Loop = 0; $Loop < length ($Input); $Loop++) {
    printf ("%02x", ord (substr ($Input, $Loop, 1)));
  }

  print "\n";
}
