#!/usr/bin/perl
#################################################################################
#										#
# BDM frequency table generator							#
# copyright (c) 2010-2016 Joerg Wolfram (joerg@jcwolfram.de)			#
#										#
#										#
# This program is free software; you can redistribute it and/or			#
# modify it under the terms of the GNU General Public License			#
# as published by the Free Software Foundation; either version 3		#
# of the License, or (at your option) any later version.			#
#										#
# This program is distributed in the hope that it will be useful,		#
# but WITHOUT ANY WARRANTY; without even the implied warranty of		#
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the GNU		#
# General Public License for more details.					#
#										#
# You should have received a copy of the GNU General Public			#
# License along with this library; if not, write to the				#
# Free Software Foundation, Inc., 59 Temple Place - Suite 330,			#
# Boston, MA 02111-1307, USA.							#
#										#
#################################################################################
use POSIX;

for($i=0;$i<256;$i++)
{
	$inval=$i;
	if($inval<1)
	{
		$inval=1
	};
	$value=floor(2831/$inval+0.3);
	if($value > 255)
	{
		$value=255;
	}
	$scell[$i]=$value;
}


###############################################################################
# write table
###############################################################################
open (WTAB, ">bdmftable.inc");
	print WTAB ".org (PC+127) & 0xff80\n\n";
	for($i=0;$i<16;$i++)
	{
		print WTAB "        .db "; 
		for($j=0;$j<16;$j++)
		{
			$cellpos=$i*16+$j;
			$y=$scell[$cellpos];
			#$y=258;
			$low=$y%256;
			if ($low<1) {printf WTAB "0x00"} 
			else {printf WTAB "%#2.2x",$low};
			if ($j<15) {print WTAB ","}
			else {print WTAB "\n"};
		}
	}
close(WTAB);

