#!/usr/bin/perl
#################################################################################
#										#
# transfer tool for chipbasic verion 1.10					#
# copyright (c) 2006 Joerg Wolfram (joerg@jcwolfram.de)				#
#										#
#										#
# This program is free software; you can redistribute it and/or			#
# modify it under the terms of the GNU General Public License			#
# as published by the Free Software Foundation; either version 2		#
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
no encoding;

$ser_port ="/dev/ttyUSB1";

use Time::HiRes qw(gettimeofday);

for($i=0;$i<0x0400;$i++)
{
	$memdata[$i]=0xffff;
}

$lname="boot_stage1.lst";
$maxaddr=0;
$comm_nr=0;

open(LISTFILE,$lname);
while(<LISTFILE>)
{
	chomp;
	$line=$_;
	$line=~ s/\s{1,50}/ /g;
	@lpar=split(" ",$line);

	if((length($lpar[1]) == 8)  && (substr($lpar[1],0,1) eq "0"))
	{
		$addr= sprintf ("%u",hex($lpar[1]));
		$data= sprintf ("%u",hex($lpar[2]));
		$memdata[$addr]=$data;
		if($addr > $maxaddr)
		{
			$maxaddr=$addr;
		}
	}

	if((length($lpar[2]) == 8)  && (substr($lpar[2],0,1) eq "0"))
	{
		$addr= sprintf ("%u",hex($lpar[2]));
		$data= sprintf ("%u",hex($lpar[3]));
		$memdata[$addr]=$data;
		if($addr > $maxaddr)
		{
			$maxaddr=$addr;
		}
	}

	if((length($lpar[0]) == 8)  && (substr($lpar[0],0,1) eq "0"))
	{
		$addr= sprintf ("%u",hex($lpar[0]));
		$data= sprintf ("%u",hex($lpar[1]));
		$memdata[$addr]=$data;
		if($addr > $maxaddr)
		{
			$maxaddr=$addr;
		}
	}


$words = $maxaddr-63;

}
close(LISTFILE);

#system `stty 38400 cs8 -onlcr -onlret -parenb -echo -crtscts -ixon < $ser_port`;
system `stty 38400 cs8 -onlcr -onlret -parenb -echo -crtscts -ixon < $ser_port`;

open (SER, ">".$ser_port);
open (SERI, $ser_port);
SER->autoflush(1);
SERI->autoflush(1);
	binmode (SER);
	binmode (SERI);
	
	commbyte(0x41);
	commbyte(0xaa);
	commbyte(0x08);	#8 bit
	for($i=0;$i<16;$i++)
	{
		commbyte(0x00);	#reserved
	}
	commbyte(0x00);	#start address = 0x00000040
	commbyte(0x00);
	commbyte(0x40);
	commbyte(0x00);

	commbyte($words & 0xff);	#number of words in data block
	commbyte(($words >> 8) & 0xff);

	commbyte(0x00);	#address of first data block = 0x00000040
	commbyte(0x00);
	commbyte(0x40);
	commbyte(0x00);

	for($i=0x0040;$i<$words+64;$i++)
	{
		$low=$memdata[$i] & 0xff;
		$high=($memdata[$i] >> 8) & 0xff;
		commbyte($low);
		commbyte($high);
#		printf "ADDR= 0x%06X  DATA=0x%04X\n",$i,$memdata[$i];
	}

	commbyte(0x00);			#no more data blocks
	commbyte(0x00);

close(SER);
close(SERI);

sub commbyte
{
#	printf "send %02X,$dbyte\n";
	$dbyte=$_[0];
	print SER chr($dbyte);
	read(SERI,$rbyte,1);
	$rbyte=ord($rbyte);
	$comm_nr++;
	if($dbyte != $rbyte)
	{
		printf "NR: %4d  SEND= 0x%02X  RECV=0x%02X\n",$comm_nr,$dbyte,$rbyte;
	}
}


