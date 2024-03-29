#!/usr/bin/perl
#################################################################################
#										#
# rom data generator								#
# copyright (c) 2010-2016 Joerg Wolfram (joerg@jcwolfram.de)			#
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
use Fcntl;

$hexfile="main.hex";
$datfile=">system.h";
$head="system_644";

&gencode;

sub gencode
{
	for($i=0;$i<65536;$i++)
	{
		$romdata[$i]="FF";
	}
	open (BREAD, $hexfile);
	$active=0;
	while (<BREAD>)
	{
		chomp;
		$line=$_;
		if(substr($line,7,2) eq "00")	#only data records
		{
			$addr=substr($line,3,4);
			$addr=sprintf("%u",hex($addr));
			$llen=substr($line,1,2);
			$llen=sprintf("%u",hex($llen));

			for($i=0;$i<$llen;$i++)
			{
				$romdata[$addr+$i]=substr($line,9+2*$i,2);
			}
			
		}
	}

	close(BREAD);

	printf("VERSION = %s %s\n",$romdata[960],$romdata[961]);

	$dlen=57344;

	open (DWRITE,$datfile);
	print DWRITE "unsigned char ".$head."[$dlen] = {";


	for($i=0;$i<$dlen;$i++)
	{
		if(($i%16)==0)
		{
			printf DWRITE "// %04X \n\t\t",$i-16;
		}
		printf DWRITE "0x%s",$romdata[$i];
		if($i<(($dlen)-1))
		{
			print DWRITE ",";
		}
	}
	print DWRITE "};\n";

	close(DWRITE);
}

