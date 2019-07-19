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

use Time::HiRes qw(gettimeofday);

for($i=0;$i<0x0400;$i++)
{
	$memdata[$i]=0xffff;
}

$lname=$ARGV[0];
$type=$ARGV[1];
$maxaddr=0;
$comm_nr=0;

open(LISTFILE,$lname);
while(<LISTFILE>)
{
	chomp;
	$line=$_;
	$line=~ s/\s{1,50}/ /g;
	@lpar=split(" ",$line);
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

open (TDAT,">BOOTLOADER.TPG");


	printf TDAT "\t/** created using key $type **/\n\n";
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
		printf TDAT "\t/** ADDR= %04X   DATA= %04X **/\n",$i,$memdata[$i];
		commbyte($low);
		commbyte($high);
#		printf "ADDR= 0x%06X  DATA=0x%04X\n",$i,$memdata[$i];
	}

	commbyte(0x00);			#no more data blocks
	commbyte(0x00);


close(TDAT);

sub commbyte
{
	$dbyte=$_[0];
	print TDAT "\tIL(IC7_BSLRX);   /*** Start bit **/\n";
	$mask=1;
	for($jj=0;$jj<8;$jj++)
	{
		if(($dbyte & $mask) == 0)
		{
			print TDAT "\tIL(IC7_BSLRX);   /*** 0 bit **/\n";
		}
		else
		{
			print TDAT "\tIH(IC7_BSLRX);   /*** 1 bit **/\n";
		}
		$mask*=2;
	}
	print TDAT "\tIH(IC7_BSLRX);   /*** Stop bit **/\n";
	print TDAT "\t;;;;;;;;;;;;;;;;;\n\n";
}

