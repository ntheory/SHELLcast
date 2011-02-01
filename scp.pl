#!/usr/local/bin/perl -w

# SHELLcast Playback -- scp
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

use Time::HiRes;

# Autoflush STDOUT
$| = 1;

my $StartTime = Time::HiRes::time;

while (<>) {
  $Input = $_;

  if ($Input =~ m/(.*)\|(.*)$/) {
    $DeliveryTime = $1;
    $Output       = $2;
    $CurrentTime  = Time::HiRes::time - $StartTime;

    while ($CurrentTime < $DeliveryTime) {
      Time::HiRes::usleep ($DeliveryTime - $CurrentTime);
      $CurrentTime = Time::HiRes::time - $StartTime;
    }

    $Pos = 0;

    while ($Pos < length ($Output)) {
      print chr (hex (substr ($Output, $Pos, 2)));
      $Pos += 2;
    }
  }
}
