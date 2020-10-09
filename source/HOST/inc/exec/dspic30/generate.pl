#!/usr/bin/perl
#################################################################################
#										#
# rom data generator/patcher for AX81						#
# copyright (c) 2010-2011 Joerg Wolfram (joerg@jcwolfram.de)			#
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

$binfile="exec.bin";
$datfile=">exec_dspic30.h";
$head="exec_dspic30";

&gencode;



sub gencode
{
	for($i=0;$i<8192;$i++)
	{
		$romdata[$i]=chr(255);
	}
	$dlen = -s $binfile;
	open (BREAD, $binfile);
	binmode(BREAD);
	for($i=0;$i<$dlen;$i++)
	{
		read(BREAD,$romdata[$i],1);
	}
	close(BREAD);

	$dlen=8192;

	open (DWRITE,$datfile);
	print DWRITE "unsigned char ".$head."[$dlen] = {";


	for($i=0;$i<$dlen;$i++)
	{
		if(($i%16)==0)
		{
			printf DWRITE "// %04X \n\t\t",$i;
		}
		$ibyte=$romdata[$i];
		$iwert=ord($ibyte);
		if($iwert==0)
		{
			print DWRITE "0x00";
		}
		else
		{
			printf DWRITE "%#2.2x",$iwert;
		}
		if($i<($dlen-1))
		{
			print DWRITE ",";
		}
	}
	print DWRITE "};\n";

	close(DWRITE);
}

