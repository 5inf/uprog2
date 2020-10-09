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

$devtype="STM32F0xx-64K";
$device="MC1";		# device name
$hfile="boot.s37";	# bootloader hexfile
$drive_power=1;		# driver/sensor power
$clock=5000;		# kHz
$vss_pin="1";
$vdd_pin="17";
$rst_pin="33";
$swdck_pin="49";
$swdio_pin="65";
$spxc_pin="81";
$spxd_pin="97";
$fblocks=1;
$fsize=64;


for($i=0;$i<0x1000;$i++)
{
	$memdata[$i]=0xffff;
}

$bnum=0;


$offset=0;
open(RFILE,$hfile);
while(<RFILE>)
{
	$line=$_;

	if(substr($line,0,1) eq ":")
	{
		$line=$_;
		$hlen= substr($line,1,2);
		$len = sprintf("%u", hex($hlen));
		$hadr= substr($line,3,4);
		$adr = sprintf("%u", hex($hadr));
		$htype= substr($line,7,2);
		$type = sprintf("%u", hex($htype));

		if ($type == 0)
		{
			for($i=0;$i<$len;$i++)
			{
				$pos=9+2*$i;
				$tdat=substr($line,$pos,2);
				$eaddr=$offset+$adr+$i;
				$dbyte=sprintf("%u", hex($tdat));
				if(($eaddr >=0) && ($eaddr <=$hi_addr))
				{
					$memdata[$eaddr-$lo_addr] = sprintf("%u", hex($tdat));
				}
			}
		}

		if ($type == 2)
		{
			$tdat=substr($line,9,4);
			$offset = sprintf("%u", hex($tdat));
			$offset=$offset*16;
			print "Segment=".$tdat."0\n";
		}

		if ($type == 4)
		{
			$tdat=substr($line,9,4);
			$offset = sprintf("%u", hex($tdat));
			$offset=$offset*65536;
			print "HIGH ADDR     = ".$tdat."0000\n";
		}
	}
	else
	{
		$rtyp= substr($line,0,2);
		$hlen= substr($line,2,2);
		$len = sprintf("%u", hex($hlen));
		$doffset=0;

		if ($rtyp eq "S1")
		{
			$hadr= substr($line,4,4);
			$hadr = sprintf("%u", hex($hadr));
			$doffset=8;
#			printf("%u ",$hadr);
		}
		if ($rtyp eq "S2")
		{
			$hadr= substr($line,4,6);
			$hadr = sprintf("%u", hex($hadr));
			$doffset=10;
		}

		if ($doffset > 0)
		{
			$dlen=(length($line)-$doffset-3)/2;
			{
				$offset=$hadr;
				for ($byte=0;$byte<$dlen;$byte++)
				{
					$tdat=substr($line,$doffset+$byte*2,2);
					$dbyte = sprintf("%u", hex($tdat));
					$eaddr=$offset;
					$offset++;
					$memdata[$eaddr-$lo_addr]=$dbyte;
				}
			}
		}
	}
}
close(RFILE);


open (TDAT,">BOOTLOADER.TPG");

	init_core(1);
	
	transfer_loader_tab(1,0);
	transfer_loader_tab(2,256);
	transfer_loader_tab(3,512);
	transfer_loader_tab(4,768);
	exec_loader(1);

	print TDAT "\tIF ".$device."_READNAILS($spxd_pin) THEN\n";
	print TDAT "\t[\n";
	print TDAT "\t\tWRITE '** FAILED BOOTLOADER OF $device%NL%';\n";
	print TDAT "\t\tBRANCH ".$device."_PDOWN;\n";	
	print TDAT "\t];\n";
	print TDAT "\n";
	print TDAT "\n";
	print TDAT "\t\tWRITE '** PASSED BOOTLOADER OF $device%NL%';\n";
	print TDAT "\n";

close(TDAT);


sub commbyte_t
{
	$dbyte=$_[0];
	$dhex=sprintf("%02X",$dbyte);
	$mask=1;
	print TDAT "\t";
	for($jj=0;$jj<4;$jj++)
	{
		if(($dbyte & $mask) == 0)
		{
			print TDAT "IL(".$device."_SWDIO);";
		}
		else
		{
			print TDAT "IH(".$device."_SWDIO);";
		}
		$mask*=2;
	}
	print TDAT "\t/* ".substr($dhex,1,1)." */\n";
	print TDAT "\t";
	for($jj=0;$jj<4;$jj++)
	{
		if(($dbyte & $mask) == 0)
		{
			print TDAT "IL(".$device."_SWDIO);";
		}
		else
		{
			print TDAT "IH(".$device."_SWDIO);";
		}
		$mask*=2;
	}
	print TDAT "\t/* ".substr($dhex,0,1)." */\n";
}


sub commdata
{
	$dword=$_[0];
	$dhex=sprintf("%08X",$dword);
	$parity=0;
	$mask=1;
	for($kk=0;$kk<8;$kk++)
	{
		print TDAT "\t";
		for($jj=0;$jj<4;$jj++)
		{
			if(($dword & $mask) == 0)
			{
				print TDAT "IL(".$device."_SWDIO);";
				}
			else
			{
				$parity=1-$parity;
				print TDAT "IH(".$device."_SWDIO);";
			}
			$mask*=2;
		}
		print TDAT "\t/* ".substr($dhex,7-$kk,1)." */\n";
	}
	if($parity == 0)
	{
		print TDAT "\tIL(".$device."_SWDIO); /* PARITY */\n";		
	}
	else
	{
		print TDAT "\tIH(".$device."_SWDIO); /* PARITY */\n";		
	}
}

sub commbyte_tm
{
	$dbyte=$_[0];
	$dhex=sprintf("%02X",$dbyte);
	$mask=128;
	print TDAT "\t";
	for($jj=0;$jj<4;$jj++)
	{
		if(($dbyte & $mask) == 0)
		{
			print TDAT "IL(".$device."_SWDIO);";
		}
		else
		{
			print TDAT "IH(".$device."_SWDIO);";
		}
		$mask/=2;
	}
	print TDAT "\t/* ".substr($dhex,1,1)." */\n";
	print TDAT "\t";
	for($jj=0;$jj<4;$jj++)
	{
		if(($dbyte & $mask) == 0)
		{
			print TDAT "IL(".$device."_SWDIO);";
		}
		else
		{
			print TDAT "IH(".$device."_SWDIO);";
		}
		$mask/=2;
	}
	print TDAT "\t/* ".substr($dhex,0,1)." */\n";
}

sub commbyte_r
{
	$dbyte=$_[0];
	$dhex=sprintf("%02X",$dbyte);
	$mask=1;
	print TDAT "\t";
	for($jj=0;$jj<4;$jj++)
	{
		if(($dbyte & $mask) == 0)
		{
			print TDAT "OL(".$device."_SWDIO);";
		}
		else
		{
			print TDAT "OH(".$device."_SWDIO);";
		}
		$mask*=2;
	}
	print TDAT "\t/* ".substr($dhex,1,1)." */\n";
	print TDAT "\t";
	for($jj=0;$jj<4;$jj++)
	{
		if(($dbyte & $mask) == 0)
		{
			print TDAT "OL(".$device."_SWDIO);";
		}
		else
		{
			print TDAT "OH(".$device."_SWDIO);";
		}
		$mask*=2;
	}
	print TDAT "\t/* ".substr($dhex,0,1)." */\n";
}

sub commword
{
	$dword=$_[0];
	commbyte(($dword >> 8) & 0xff);
}


sub testwait
{
	$level=$_[0];
	$twtime=$_[1];

}

sub fastsubs
{
print TDAT "\t/***************************************************/\n";
print TDAT "\t/* WRITE TO DAP AND IGNORE ACK                     */\n";
print TDAT "\t/***************************************************/\n";
print TDAT "\tFASTSUB WRITE_DAP_NA;\n";
print TDAT "\t\tIC(".$device."_SWDCK) IH(".$device."_SWDCK)\n";
print TDAT "\t\tIC(".$device."_SWDIO) IH(".$device."_SWDIO)\n";
print TDAT "\t\tHD(".$device."_SWDIO);\n";
print TDAT "\t\tFLOOP(3)=8;\n";
print TDAT "\t\t\tUSE DRIVE(1)+;\n";
print TDAT "\t\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\t\tIH(".$device."_SWDCK);\n";
print TDAT "\t\tEND FLOOP;\n";
print TDAT "\n";
print TDAT "\t\t/* TrN switch to input */\n";
print TDAT "\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\tID(".$device."_SWDIO);\n";
print TDAT "\t\tIH(".$device."_SWDCK);;;;;;;;;;;\n";
print TDAT "\n";
print TDAT "\t\t/* check acknowledge */\n";
print TDAT "\t\tIL(".$device."_SWDCK);;\t/* 1 */\n";
print TDAT "\t\t\$ OS(".$device."_SWDIO) OH(".$device."_SWDIO) FLAGFAIL;\n";
print TDAT "\t\t\$ OI(".$device."_SWDIO) IH(".$device."_SWDCK);\n";
print TDAT "\t\tIL(".$device."_SWDCK);;\t/* 0 */\n";
print TDAT "\t\t\$ OS(".$device."_SWDIO) OL(".$device."_SWDIO) FLAGFAIL;\n";
print TDAT "\t\t\$ OI(".$device."_SWDIO) IH(".$device."_SWDCK);\n";
print TDAT "\t\tIL(".$device."_SWDCK);;\t/* 0 */\n";
print TDAT "\t\t\$ OS(".$device."_SWDIO) OL(".$device."_SWDIO) FLAGFAIL;\n";
print TDAT "\t\t\$ OI(".$device."_SWDIO) IH(".$device."_SWDCK);\n";
print TDAT "\n";
print TDAT "\t\t/* TrN switch to output */\n";
print TDAT "\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\tIC(".$device."_SWDIO) IH(".$device."_SWDIO);\n";
print TDAT "\t\tIH(".$device."_SWDCK);;;;;;;;;;;\n";
print TDAT "\n";
print TDAT "\t\t/* transfer data */\n";
print TDAT "\t\tHD(".$device."_SWDIO);\n";
print TDAT "\t\tFLOOP(3)=33;\n";
print TDAT "\t\t\tUSE DRIVE(1)+;\n";
print TDAT "\t\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\t\tIH(".$device."_SWDCK);\n";
print TDAT "\t\tEND FLOOP;;;;;;;;;;;;;;;;;;;;;\n";
print TDAT "\n";
print TDAT "\tEND FASTSUB;\n";
print TDAT "\n";

print TDAT "\t/***************************************************/\n";
print TDAT "\t/* WRITE TO DAP                                    */\n";
print TDAT "\t/***************************************************/\n";
print TDAT "\tFASTSUB WRITE_DAP;\n";
print TDAT "\t\tIC(".$device."_SWDCK) IH(".$device."_SWDCK)\n";
print TDAT "\t\tIC(".$device."_SWDIO) IH(".$device."_SWDIO)\n";
print TDAT "\t\tHD(".$device."_SWDIO);\n";
print TDAT "\t\tFLOOP(3)=8;\n";
print TDAT "\t\t\tUSE DRIVE(1)+;\n";
print TDAT "\t\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\t\tIH(".$device."_SWDCK);\n";
print TDAT "\t\tEND FLOOP;\n";
print TDAT "\n";
print TDAT "\t\t/* TrN switch to input */\n";
print TDAT "\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\tID(".$device."_SWDIO);\n";
print TDAT "\t\tIH(".$device."_SWDCK);;;;;;;;;;;\n";
print TDAT "\n";
print TDAT "\t\t/* check acknowledge */\n";
print TDAT "\t\tIL(".$device."_SWDCK);;\t/* 1 */\n";
print TDAT "\t\tOS(".$device."_SWDIO) OH(".$device."_SWDIO);\n";
print TDAT "\t\tOI(".$device."_SWDIO) IH(".$device."_SWDCK);\n";
print TDAT "\t\tIL(".$device."_SWDCK);;\t/* 0 */\n";
print TDAT "\t\tOS(".$device."_SWDIO) OL(".$device."_SWDIO);\n";
print TDAT "\t\tOI(".$device."_SWDIO) IH(".$device."_SWDCK);\n";
print TDAT "\t\tIL(".$device."_SWDCK);;\t/* 0 */\n";
print TDAT "\t\tOS(".$device."_SWDIO) OL(".$device."_SWDIO);\n";
print TDAT "\t\tOI(".$device."_SWDIO) IH(".$device."_SWDCK);\n";
print TDAT "\n";
print TDAT "\t\t/* TrN switch to output */\n";
print TDAT "\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\tIC(".$device."_SWDIO) IH(".$device."_SWDIO);\n";
print TDAT "\t\tIH(".$device."_SWDCK);;;;;;;;;;;\n";
print TDAT "\n";
print TDAT "\t\t/* transfer data */\n";
print TDAT "\t\tHD(".$device."_SWDIO);\n";
print TDAT "\t\tFLOOP(3)=33;\n";
print TDAT "\t\t\tUSE DRIVE(1)+;\n";
print TDAT "\t\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\t\tIH(".$device."_SWDCK);\n";
print TDAT "\t\tEND FLOOP;;;;;;;;;;;;;;;;;;;;;\n";
print TDAT "\n";
print TDAT "\tEND FASTSUB;\n";
print TDAT "\n";

print TDAT "\t/***************************************************/\n";
print TDAT "\t/* READ FROM DAP AND CHECK                         */\n";
print TDAT "\t/***************************************************/\n";
print TDAT "\tFASTSUB READ_DAP;\n";
print TDAT "\t\tIC(".$device."_SWDCK) IH(".$device."_SWDCK)\n";
print TDAT "\t\tIC(".$device."_SWDIO) IH(".$device."_SWDIO)\n";
print TDAT "\t\tHD(".$device."_SWDIO);\n";
print TDAT "\t\tFLOOP(3)=8;\n";
print TDAT "\t\t\tUSE DRIVE(1)+;\n";
print TDAT "\t\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\t\tIH(".$device."_SWDCK);\n";
print TDAT "\t\tEND FLOOP;\n";
print TDAT "\n";
print TDAT "\t\t/* TrN switch to input */\n";
print TDAT "\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\tID(".$device."_SWDIO);\n";
print TDAT "\t\tIH(".$device."_SWDCK);;;;;;;;;;;\n";
print TDAT "\n";
print TDAT "\t\t/* check acknowledge */\n";
print TDAT "\t\tIL(".$device."_SWDCK);;\t/* 1 */\n";
print TDAT "\t\t\$ OS(".$device."_SWDIO) OH(".$device."_SWDIO) FLAGFAIL;\n";
print TDAT "\t\t\$ OI(".$device."_SWDIO) IH(".$device."_SWDCK);\n";
print TDAT "\t\tIL(".$device."_SWDCK);;\t/* 0 */\n";
print TDAT "\t\t\$ OS(".$device."_SWDIO) OL(".$device."_SWDIO) FLAGFAIL;\n";
print TDAT "\t\t\$ OI(".$device."_SWDIO) IH(".$device."_SWDCK);\n";
print TDAT "\t\tIL(".$device."_SWDCK);;\t/* 0 */\n";
print TDAT "\t\t\$ OS(".$device."_SWDIO) OL(".$device."_SWDIO) FLAGFAIL;\n";
print TDAT "\t\t\$ OI(".$device."_SWDIO) IH(".$device."_SWDCK);;;;;;;;;;;\n";
print TDAT "\n";
print TDAT "\t\t/* transfer data */\n";
print TDAT "\t\tFLOOP(3)=32;\n";
print TDAT "\t\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\t\tUSE DRIVE(2)+;\n";
print TDAT "\t\t\$ OI(".$device."_SWDIO) IH(".$device."_SWDCK);\n";
print TDAT "\t\tEND FLOOP;\n";
print TDAT "\t\t/* ignore parity */\n";
print TDAT "\t\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\t\tIH(".$device."_SWDCK);\n";

print TDAT "\t\t/* TrN switch to output */\n";
print TDAT "\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\tIC(".$device."_SWDIO) IH(".$device."_SWDIO);\n";
print TDAT "\t\tIH(".$device."_SWDCK);;;;;;;;;;;;;;;;;;;;;\n";
print TDAT "\n";
print TDAT "\tEND FASTSUB;\n";
print TDAT "\n";

print TDAT "\t/***************************************************/\n";
print TDAT "\t/* READ FROM DAP AND CHECK BIT 16                  */\n";
print TDAT "\t/***************************************************/\n";
print TDAT "\tFASTSUB READ_DRW_C16;\n";
print TDAT "\t\tIC(".$device."_SWDCK) IH(".$device."_SWDCK)\n";
print TDAT "\t\tIC(".$device."_SWDIO) IH(".$device."_SWDIO)\n";
print TDAT "\t\tIH(".$device."_SWDIO) IL(".$device."_SWDCK);IH(".$device."_SWDCK);\n";
print TDAT "\t\tIH(".$device."_SWDIO) IL(".$device."_SWDCK);IH(".$device."_SWDCK);\n";
print TDAT "\t\tIH(".$device."_SWDIO) IL(".$device."_SWDCK);IH(".$device."_SWDCK);\n";
print TDAT "\t\tIH(".$device."_SWDIO) IL(".$device."_SWDCK);IH(".$device."_SWDCK);\n";
print TDAT "\t\tIH(".$device."_SWDIO) IL(".$device."_SWDCK);IH(".$device."_SWDCK);\n";
print TDAT "\t\tIL(".$device."_SWDIO) IL(".$device."_SWDCK);IH(".$device."_SWDCK);\n";
print TDAT "\t\tIl(".$device."_SWDIO) IL(".$device."_SWDCK);IH(".$device."_SWDCK);\n";
print TDAT "\t\tIH(".$device."_SWDIO) IL(".$device."_SWDCK);IH(".$device."_SWDCK);\n";
print TDAT "\n";
print TDAT "\t\t/* TrN switch to input */\n";
print TDAT "\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\tID(".$device."_SWDIO);\n";
print TDAT "\t\tIH(".$device."_SWDCK);;;;;;;;;;;\n";
print TDAT "\n";
print TDAT "\t\t/* check acknowledge */\n";
print TDAT "\t\tIL(".$device."_SWDCK);;\t/* 1 */\n";
print TDAT "\t\t\$ OS(".$device."_SWDIO) OH(".$device."_SWDIO);\n";
print TDAT "\t\t\$ OI(".$device."_SWDIO) IH(".$device."_SWDCK);\n";
print TDAT "\t\tIL(".$device."_SWDCK);;\t/* 0 */\n";
print TDAT "\t\t\$ OS(".$device."_SWDIO) OL(".$device."_SWDIO);\n";
print TDAT "\t\t\$ OI(".$device."_SWDIO) IH(".$device."_SWDCK);\n";
print TDAT "\t\tIL(".$device."_SWDCK);;\t/* 0 */\n";
print TDAT "\t\t\$ OS(".$device."_SWDIO) OL(".$device."_SWDIO);\n";
print TDAT "\t\t\$ OI(".$device."_SWDIO) IH(".$device."_SWDCK);;;;;;;;;;;\n";
print TDAT "\n";
print TDAT "\t\t/* transfer data */\n";
print TDAT "\t\tFLOOP(3)=15;\n";
print TDAT "\t\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\t\tIH(".$device."_SWDCK);\n";
print TDAT "\t\tEND FLOOP;\n";
print TDAT "\t\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\t\$ OS(".$device."_SWDIO) OL(".$device."_SWDIO) FLAGFAIL;\n";
print TDAT "\t\t\$ OI(".$device."_SWDIO) IH(".$device."_SWDCK);\n";
print TDAT "\t\tFLOOP(3)=17;\n";
print TDAT "\t\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\t\tIH(".$device."_SWDCK);\n";
print TDAT "\t\tEND FLOOP;\n";
print TDAT "\t\t/* TrN switch to output */\n";
print TDAT "\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\tIC(".$device."_SWDIO) IH(".$device."_SWDIO);\n";
print TDAT "\t\tIH(".$device."_SWDCK);;;;;;;;;;;;;;;;;;;;;\n";
print TDAT "\n";
print TDAT "\tEND FASTSUB;\n";
print TDAT "\n";

print TDAT "\t/***************************************************/\n";
print TDAT "\t/* DUMMY READ FROM DAP                             */\n";
print TDAT "\t/***************************************************/\n";
print TDAT "\tFASTSUB DREAD_DAP;\n";
print TDAT "\t\tIC(".$device."_SWDCK) IH(".$device."_SWDCK)\n";
print TDAT "\t\tIC(".$device."_SWDIO) IH(".$device."_SWDIO)\n";
print TDAT "\t\tHD(".$device."_SWDIO);\n";
print TDAT "\t\tFLOOP(3)=8;\n";
print TDAT "\t\t\tUSE DRIVE(1)+;\n";
print TDAT "\t\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\t\tIH(".$device."_SWDCK);\n";
print TDAT "\t\tEND FLOOP;\n";
print TDAT "\n";
print TDAT "\t\t/* TrN switch to input */\n";
print TDAT "\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\tID(".$device."_SWDIO);\n";
print TDAT "\t\tIH(".$device."_SWDCK);;;;;;;;;;;\n";
print TDAT "\n";
print TDAT "\t\t/* check acknowledge */\n";
print TDAT "\t\tIL(".$device."_SWDCK);;\t/* 1 */\n";
print TDAT "\t\t\$ OS(".$device."_SWDIO) OH(".$device."_SWDIO) FLAGFAIL;\n";
print TDAT "\t\t\$ OI(".$device."_SWDIO) IH(".$device."_SWDCK);\n";
print TDAT "\t\tIL(".$device."_SWDCK);;\t/* 0 */\n";
print TDAT "\t\t\$ OS(".$device."_SWDIO) OL(".$device."_SWDIO) FLAGFAIL;\n";
print TDAT "\t\t\$ OI(".$device."_SWDIO) IH(".$device."_SWDCK);\n";
print TDAT "\t\tIL(".$device."_SWDCK);;\t/* 0 */\n";
print TDAT "\t\t\$ OS(".$device."_SWDIO) OL(".$device."_SWDIO) FLAGFAIL;\n";
print TDAT "\t\t\$ OI(".$device."_SWDIO) IH(".$device."_SWDCK);;;;;;;;;;;\n";
print TDAT "\n";
print TDAT "\t\t/* transfer data */\n";
print TDAT "\t\tFLOOP(3)=33;\n";
print TDAT "\t\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\t\tIH(".$device."_SWDCK);\n";
print TDAT "\t\tEND FLOOP;\n";

print TDAT "\t\t/* TrN switch to output */\n";
print TDAT "\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\tIC(".$device."_SWDIO) IH(".$device."_SWDIO);\n";
print TDAT "\t\tIH(".$device."_SWDCK);;;;;;;;;;;;;;;;;;;;;\n";
print TDAT "\n";
print TDAT "\tEND FASTSUB;\n";
print TDAT "\n";
}

sub init_core
{
	$ic_index=$_[0];
print TDAT "/*************************************************************************/\n";
print TDAT "/***                               INIT CORE                           ***/\n";
print TDAT "/*************************************************************************/\n";
print TDAT "\n";
print TDAT "".$device."_ICORE".$ic_index.":\n";
print TDAT "\n";
print TDAT "\n";
print TDAT "".$device."_ICORE".$ic_index."_BURST:\n";
print TDAT "\n";
print TDAT "\tBURST ACTIVE ITT=10U IST=7U NAME='$device' MAXTIME=2\n";
print TDAT "\tINTO ".$device."_READNAILS NOPROBE NOFAULT NOPRINT FAIL();\n";
print TDAT "\n";
print TDAT "\n";
print TDAT "START_MAIN:\n";
print TDAT "\n";
if($drive_power==1)
{
	print TDAT "\t/*** CONNECT POWER ***/\n";
	print TDAT "\t\$ IC(".$device."_VSS) IL(".$device."_VSS)\n";
	print TDAT "\t\$ IC(".$device."_VDD) IH(".$device."_VDD)\n";
	print TDAT "\n";
}
print TDAT "\t/*** CONNECT BOOT SIGNALS ***/\n";
print TDAT "\t\$ IC(".$device."_RST) IL(".$device."_RST)\n";
print TDAT "\t\$ IC(".$device."_SWDCK) IL(".$device."_SWDCK)\n";
print TDAT "\t\$ IC(".$device."_SWDIO) IL(".$device."_SWDIO)\n";
print TDAT "\n";
print TDAT "\t/*** CONNECT SPX SIGNALS ***/\n";
print TDAT "\t\$ IC(".$device."_SPXC) IL(".$device."_SPXC);\n";
#print TDAT "\t\$ IC(".$device."_SPXD) IL(".$device."_SPXD);\n";
print TDAT "\n";
print TDAT "\t\$ PD(".$device."_SPXD);\n";
print TDAT "\n";
print TDAT "\tFAST;\n";
print TDAT "\n";
print TDAT "\t/* WAIT UNTIL POWER IST STABLE */\n";
print TDAT "\tFLOOP(1)=50;\n";
print TDAT "\t\tFLOOP(2)=4999;\n";
print TDAT "\t\tEND FLOOP;\n";
print TDAT "\tEND FLOOP;\n";
print TDAT "\n";
print TDAT "\n";
print TDAT "\t/* TAP RESET */\n";
print TDAT "\tIC(".$device."_SWDIO) IH(".$device."_SWDIO);\n";
print TDAT "\tIH(".$device."_SWDCK);\n";
print TDAT "\tFLOOP(1)=50;\n";
print TDAT "\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\tIH(".$device."_SWDCK);\n";
print TDAT "\tEND FLOOP;\n";
print TDAT "\n";
print TDAT "\t/* SWITCH TO SWD MODE */\n";
print TDAT "\tLOAD DRIVE(1) BOOT_SWITCH;\n";
print TDAT "\tHD(".$device."_SWDIO);\n";
print TDAT "\tFLOOP(1)=16;\n";
print TDAT "\t\tUSE DRIVE(1)+;\n";
print TDAT "\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\tIH(".$device."_SWDCK);\n";
print TDAT "\tEND FLOOP;\n";
print TDAT "\n";
print TDAT "\t/* TAP RESET */\n";
print TDAT "\tIC(".$device."_SWDIO) IH(".$device."_SWDIO);\n";
print TDAT "\tFLOOP(1)=50;\n";
print TDAT "\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\tIH(".$device."_SWDCK);\n";
print TDAT "\tEND FLOOP;\n";
print TDAT "\n";
print TDAT "\t/* TAP RUNTEST-IDLE */\n";
print TDAT "\tIC(".$device."_SWDIO) IL(".$device."_SWDIO);\n";
print TDAT "\tFLOOP(1)=2;\n";
print TDAT "\t\tIL(".$device."_SWDCK);\n";
print TDAT "\t\tIH(".$device."_SWDCK);\n";
print TDAT "\tEND FLOOP;\n";
print TDAT "\n";
print TDAT "IC(129) IH(129);\n";
print TDAT "\n";
print TDAT "\t/* CHECK ID */\n";
print TDAT "\tLOAD DRIVE(1) READID_R;\n";
print TDAT "\tLOAD DRIVE(2) READID_A;\n";
print TDAT "\n";
print TDAT "\tGOSUB READ_DAP;\n";
print TDAT "\n";
print TDAT "\tLOAD DRIVE(1) DBG_INIT;\n";
print TDAT "\n";
print TDAT "\tGOSUB DREAD_DAP;\n";	#CTRLSTAT
print TDAT "\n";

print TDAT "\t/* START DEBUG PORT */\n";
print TDAT "\tFLOOP(1)=5;\n";
print TDAT "\t\tGOSUB WRITE_DAP;\n";
print TDAT "\tEND FLOOP;\n";
print TDAT "\n";

print TDAT "\t/* DEBUG CORE START */\n";
print TDAT "\tFLOOP(1)=3;\n";
print TDAT "\t\tGOSUB WRITE_DAP;\n";
print TDAT "\tEND FLOOP;\n";
print TDAT "\n";

print TDAT "\t/* SET RESET VECTOR CATCH */\n";
print TDAT "\tFLOOP(1)=3;\n";
print TDAT "\t\tGOSUB WRITE_DAP;\n";
print TDAT "\tEND FLOOP;\n";
print TDAT "\n";

print TDAT "\t/* RELEASE RESET */\n";
print TDAT "\tIH(".$device."_RST);\n";
print TDAT "\t/* WAIT FOR CPU IS OUT OF RESET */\n";
print TDAT "\tFLOOP(1)=50;\n";
print TDAT "\t\tFLOOP(2)=4999;\n";
print TDAT "\t\tEND FLOOP;\n";
print TDAT "\tEND FLOOP;\n";

print TDAT "\tEND FAST;\n";
print TDAT "\n";
print TDAT "\n";
fastsubs();

print TDAT "\n";
print TDAT "TABLE BOOT_SWITCH;\n";
print TDAT "\tIC(".$device."_SWDIO)\n";
	commbyte_t(0x9E);	#key
	commbyte_t(0xE7);
print TDAT "END TABLE;\n\n";

print TDAT "TABLE READID_R;\n";
print TDAT "\tIC(".$device."_SWDIO)\n";

print TDAT "\t/* READ ID */\n";
print TDAT "\tIC(".$device."_SWDIO)\n";
	commbyte_tm(0xa5);	#readid
print TDAT "END TABLE;\n\n";
	
print TDAT "TABLE DBG_INIT;\n";
print TDAT "\tIC(".$device."_SWDIO)\n";	
print TDAT "\t/* READ CTRL */\n";
	commbyte_tm(0xb1);
print TDAT "\t/* CLEAR ALL ERRORS */\n";
	commbyte_tm(0x81);	#write abort
	commdata(0x0000001e);
print TDAT "\t/* SWITCH TO BANK 0 */\n";
	commbyte_tm(0x8d);	#write select
	commdata(0x00000000);
print TDAT "\t/* POWER UP DEGUG-IF */\n";
	commbyte_tm(0x95);	#write ctrl
	commdata(0x50000000);
print TDAT "\t/* REQUEST DEBUG RESET */\n";
	commbyte_tm(0x95);	#write ctrl
	commdata(0x54000000);
print TDAT "\t/* INIT AP TRANSFER MODE */\n";
	commbyte_tm(0x95);	#write ctrl
	commdata(0x50000F00);

print TDAT "\t/* 32-BIT ACCESS */\n";
	commbyte_tm(0xC5);	#write csw
	commdata(0x23000002);

print TDAT "\t/* DHCSR */\n";
	commbyte_tm(0xD1);	#write TAR
	commdata(0xE000EDF0);

print TDAT "\t/* HALT */\n";
	commbyte_tm(0xDD);	#write DRW
	commdata(0xA05F0009);

print TDAT "\t/* DEMCR */\n";
	commbyte_tm(0xD1);	#write TAR
	commdata(0xE000EDFC);

print TDAT "\t/* ENABLE RESET VECTOR CATCH */\n";
	commbyte_tm(0xDD);	#write DRW
	commdata(0x00000001);
	commbyte_tm(0xDD);	#write DRW
	commdata(0x00000001);
print TDAT "END TABLE;\n\n";

print TDAT "TABLE READID_A;\n";
print TDAT "\tOS(".$device."_SWDIO)\n";
	commbyte_r(0x77);	#jtag id
	commbyte_r(0x14);
	commbyte_r(0xb1);
	commbyte_r(0x0b);
print TDAT "END TABLE;\n\n";

print TDAT "\tEND BURST;\n";
print TDAT "\n";
print TDAT "\tIF ".$device."_READNAILS($swdio_pin) THEN\n";
print TDAT "\t[\n";
print TDAT "\t\tWRITE 'FAILED INIT CORE OF $device%NL%';\n";
print TDAT "\t\tBITSET(FAIL,1);\n";
print TDAT "\t\tBITSET(".$device."_PROGFAIL,1);\n";
print TDAT "\t\tBRANCH ".$device."_PDOWN;\n";
print TDAT "\t];\n";
}

sub transfer_loader_tab
{
$ic_index=$_[0];
$startaddr=$_[1];
print TDAT "/*************************************************************************/\n";
print TDAT "/***                          TRANSFER LOADER                          ***/\n";
print TDAT "/*************************************************************************/\n";
print TDAT "\n";
print TDAT "".$device."_BLTRANS1".$ic_index.":\n";
print TDAT "\n";
print TDAT "\n";
print TDAT "".$device."_BLTRANS1".$ic_index."_BURST:\n";
print TDAT "\n";
print TDAT "\tBURST ACTIVE ITT=10U IST=7U NAME='$device' MAXTIME=2\n";
print TDAT "\tINTO ".$device."_READNAILS NOPROBE NOFAULT NOPRINT FAIL();\n";
print TDAT "\n";
print TDAT "\n";
print TDAT "START_MAIN:\n";
print TDAT "\n";
if($drive_power==1)
{
	print TDAT "\t/*** CONNECT POWER ***/\n";
	print TDAT "\t\$ IC(".$device."_VSS) IL(".$device."_VSS)\n";
	print TDAT "\t\$ IC(".$device."_VDD) IH(".$device."_VDD)\n";
	print TDAT "\n";
}
print TDAT "\t/*** CONNECT BOOT SIGNALS ***/\n";
print TDAT "\t\$ IC(".$device."_RST) IH(".$device."_RST)\n";
print TDAT "\t\$ IC(".$device."_SWDCK) IH(".$device."_SWDCK)\n";
print TDAT "\t\$ IC(".$device."_SWDIO) IH(".$device."_SWDIO)\n";
print TDAT "\n";
print TDAT "\t/*** CONNECT SPX SIGNALS ***/\n";
print TDAT "\t\$ IC(".$device."_SPXC) IL(".$device."_SPXC);\n";
#print TDAT "\t\$ IC(".$device."_SPXD) IL(".$device."_SPXD);\n";
print TDAT "\n";
print TDAT "\t\$ PD(".$device."_SPXD);\n";
print TDAT "\n";
print TDAT "\tFAST;\n";

print TDAT "\t/* TRANSFER DATA */\n";
print TDAT "\tLOAD DRIVE(1) BL_DATA1;\n";
print TDAT "\tFLOOP(1)=64;\n";
print TDAT "\t\tGOSUB WRITE_DAP;\n";
print TDAT "\tEND FLOOP;\n";
print TDAT "\n";
print TDAT "\tLOAD DRIVE(1) BL_DATA2;\n";
print TDAT "\tFLOOP(1)=64;\n";
print TDAT "\t\tGOSUB WRITE_DAP;\n";
print TDAT "\tEND FLOOP;\n";
print TDAT "\n";

print TDAT "\tEND FAST;\n";
print TDAT "\n";
print TDAT "\n";

fastsubs();
	
print TDAT "TABLE BL_DATA1;\n";
print TDAT "\tIC(".$device."_SWDIO)\n";
for($l=0;$l<32;$l++)
{
	$addr=$startaddr+0x20000000+$l*4;
	$data=$memdata[$startaddr+$l*4]; 
	$data+=($memdata[$startaddr+$l*4+1] << 8); 
	$data+=($memdata[$startaddr+$l*4+2] << 16); 
	$data+=($memdata[$startaddr+$l*4+3] << 24);
	printf TDAT ("\t/* ADDR= %08X   DATA= %08X */\n",$addr,$data); 
	commbyte_tm(0xD1);	#write tar
	commdata($addr);	#address
	commbyte_tm(0xDD);	#write drw
	commdata($data);	#data
}
print TDAT "END TABLE;\n\n";

print TDAT "TABLE BL_DATA2;\n";
print TDAT "\tIC(".$device."_SWDIO)\n";
for($l=32;$l<64;$l++)
{
	$addr=$startaddr+0x20000000+$l*4;
	$data=$memdata[$startaddr+$l*4]; 
	$data+=($memdata[$startaddr+$l*4+1] << 8); 
	$data+=($memdata[$startaddr+$l*4+2] << 16); 
	$data+=($memdata[$startaddr+$l*4+3] << 24);
	printf TDAT ("\t/* ADDR= %08X   DATA= %08X */\n",$addr,$data); 
	commbyte_tm(0xD1);	#write tar
	commdata($addr);	#address
	commbyte_tm(0xDD);	#write drw
	commdata($data);	#data
}
print TDAT "END TABLE;\n\n";

print TDAT "\tEND BURST;\n";
print TDAT "\n";
print TDAT "\tIF ".$device."_READNAILS($swdio_pin) THEN\n";
print TDAT "\t[\n";
print TDAT "\t\tWRITE 'FAILED TRANSFER BOOTLOADER OF $device%NL%';\n";
print TDAT "\t\tBITSET(FAIL,1);\n";
print TDAT "\t\tBITSET(".$device."_PROGFAIL,1);\n";
print TDAT "\t\tBRANCH ".$device."_PDOWN;\n";
print TDAT "\t];\n";
print TDAT "\n";
}

sub exec_loader
{
$ic_index=$_[0];
print TDAT "/*************************************************************************/\n";
print TDAT "/***                          EXEC LOADER                              ***/\n";
print TDAT "/*************************************************************************/\n";
print TDAT "\n";
print TDAT "".$device."_BLEXEC".$ic_index.":\n";
print TDAT "\n";
print TDAT "\n";
print TDAT "".$device."_BLEXEC".$ic_index."_BURST:\n";
print TDAT "\n";
print TDAT "\tBURST ACTIVE ITT=10U IST=7U NAME='$device' MAXTIME=1\n";
print TDAT "\tINTO ".$device."_READNAILS NOPROBE NOFAULT NOPRINT FAIL();\n";
print TDAT "\n";
print TDAT "\n";
print TDAT "START_MAIN:\n";
print TDAT "\n";
if($drive_power==1)
{
	print TDAT "\t/*** CONNECT POWER ***/\n";
	print TDAT "\t\$ IC(".$device."_VSS) IL(".$device."_VSS)\n";
	print TDAT "\t\$ IC(".$device."_VDD) IH(".$device."_VDD)\n";
	print TDAT "\n";
}
print TDAT "\t/*** CONNECT BOOT SIGNALS ***/\n";
print TDAT "\t\$ IC(".$device."_RST) IH(".$device."_RST)\n";
print TDAT "\t\$ IC(".$device."_SWDCK) IH(".$device."_SWDCK)\n";
print TDAT "\t\$ IC(".$device."_SWDIO) IH(".$device."_SWDIO)\n";
print TDAT "\n";
print TDAT "\t/*** CONNECT SPX SIGNALS ***/\n";
print TDAT "\t\$ IC(".$device."_SPXC) IL(".$device."_SPXC);\n";
#print TDAT "\t\$ IC(".$device."_SPXD) IL(".$device."_SPXD);\n";
print TDAT "\n";
print TDAT "\t\$ PD(".$device."_SPXD);\n";
print TDAT "\n";
print TDAT "\tFAST;\n";

print TDAT "\tLOAD DRIVE(1) BL_EXEC;\n";
print TDAT "\t/* WRITE SP */\n";
print TDAT "\tFLOOP(1)=8;\n";
print TDAT "\t\tGOSUB WRITE_DAP;\n";
print TDAT "\tEND FLOOP;\n";
print TDAT "\n";
print TDAT "\t/* WRITE PC */\n";
print TDAT "\tFLOOP(1)=8;\n";
print TDAT "\t\tGOSUB WRITE_DAP;\n";
print TDAT "\tEND FLOOP;\n";
print TDAT "\n";
print TDAT "\t/* CLEAR HALT */\n";
print TDAT "\tFLOOP(1)=3;\n";
print TDAT "\t\tGOSUB WRITE_DAP;\n";
print TDAT "\tEND FLOOP;\n";
print TDAT "\n";
print TDAT "\t/* WAIT FOR BL IST STARTED */\n";
print TDAT "\tFLOOP(1)=50;\n";
print TDAT "\t\tFLOOP(2)=4999;\n";
print TDAT "\t\tEND FLOOP;\n";
print TDAT "\tEND FLOOP;\n";
print TDAT "\n";
print TDAT "\t/* CHECK IF BL IST STARTED */\n";
print TDAT "\tOS(".$device."_SPXD) OH(".$device."_SPXD); OI(".$device."_SPXD);\n";
print TDAT "\tIH(".$device."_SPXC);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n";
print TDAT "\tIL(".$device."_SPXC);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n";
print TDAT "\tEND FAST;\n";
print TDAT "\n";
print TDAT "\n";

fastsubs();
	
print TDAT "TABLE BL_EXEC;\n";
print TDAT "\tIC(".$device."_SWDIO)\n";
print TDAT "\t/* WRITE SP */\n";
	commbyte_tm(0xD1);	#write tar
	commdata(0xe000edf4);	#DCRSR
	commbyte_tm(0xDD);	#write drw
	commdata(0x0001000d);	#SP index
	commbyte_tm(0xD1);	#write tar
	commdata(0xe000edf8);	#DCRDR
	commbyte_tm(0xDD);	#write drw
	commdata(0x20000FFC);	#SP value
	commbyte_tm(0xD1);	#write tar
	commdata(0xe000edf4);	#DCRSR
	commbyte_tm(0xDD);	#write drw
	commdata(0x0001000d);	#SP index
	commbyte_tm(0xD1);	#write tar
	commdata(0xe000edf8);	#DCRDR
	commbyte_tm(0xDD);	#write drw
	commdata(0x20000FFC);	#SP value
print TDAT "\t/* WRITE PC */\n";
	commbyte_tm(0xD1);	#write tar
	commdata(0xe000edf4);	#DCRSR
	commbyte_tm(0xDD);	#write drw
	commdata(0x0001000f);	#PC index
	commbyte_tm(0xD1);	#write tar
	commdata(0xe000edf8);	#DCRDR
	commbyte_tm(0xDD);	#write drw
	commdata(0x20000009);	#PC value
	commbyte_tm(0xD1);	#write tar
	commdata(0xe000edf4);	#DCRSR
	commbyte_tm(0xDD);	#write drw
	commdata(0x0001000f);	#PC index
	commbyte_tm(0xD1);	#write tar
	commdata(0xe000edf8);	#DCRDR
	commbyte_tm(0xDD);	#write drw
	commdata(0x20000009);	#PC value
print TDAT "\t/* RELEASE HALT */\n";
	commbyte_tm(0xD1);	#write TAR
	commdata(0xE000EDF0);	#DHSCR
	commbyte_tm(0xDD);	#write drw
	commdata(0xA05F0009);
	commbyte_tm(0xDD);	#write drw
	commdata(0xA05F0009);
print TDAT "END TABLE;\n\n";

print TDAT "\tEND BURST;\n";
print TDAT "\n";
print TDAT "\tIF ".$device."_READNAILS($swdio_pin) THEN\n";
print TDAT "\t[\n";
print TDAT "\t\tWRITE 'FAILED TRANSFER BOOTLOADER OF $device%NL%';\n";
print TDAT "\t\tBITSET(FAIL,1);\n";
print TDAT "\t\tBITSET(".$device."_PROGFAIL,1);\n";
print TDAT "\t\tBRANCH ".$device."_PDOWN;\n";
print TDAT "\t];\n";
print TDAT "\n";
}

sub erase_main
{
$ic_index=$_[0];
print TDAT "/*************************************************************************/\n";
print TDAT "/***                    ERASE MAIN MEMORY                              ***/\n";
print TDAT "/*************************************************************************/\n";
print TDAT "\n";
print TDAT "".$device."_MERASE".$ic_index.":\n";
print TDAT "\n";
print TDAT "\n";
print TDAT "".$device."_MERASE".$ic_index."_BURST:\n";
print TDAT "\n";
print TDAT "\tBURST ACTIVE ITT=10U IST=7U NAME='$device' MAXTIME=10\n";
print TDAT "\tINTO ".$device."_READNAILS NOPROBE NOFAULT NOPRINT FAIL();\n";
print TDAT "\n";
print TDAT "\n";
print TDAT "START_MAIN:\n";
print TDAT "\n";
if($drive_power==1)
{
	print TDAT "\t/*** CONNECT POWER ***/\n";
	print TDAT "\t\$ IC(".$device."_VSS) IL(".$device."_VSS)\n";
	print TDAT "\t\$ IC(".$device."_VDD) IH(".$device."_VDD)\n";
	print TDAT "\n";
}
print TDAT "\t/*** CONNECT BOOT SIGNALS ***/\n";
print TDAT "\t\$ IC(".$device."_RST) IH(".$device."_RST)\n";
print TDAT "\t\$ IC(".$device."_SWDCK) IH(".$device."_SWDCK)\n";
print TDAT "\t\$ IC(".$device."_SWDIO) IH(".$device."_SWDIO)\n";
print TDAT "\n";
print TDAT "\t/*** CONNECT SPX SIGNALS ***/\n";
print TDAT "\t\$ IC(".$device."_SPXC) IL(".$device."_SPXC);\n";
#print TDAT "\t\$ IC(".$device."_SPXD) IL(".$device."_SPXD);\n";
print TDAT "\n";
print TDAT "\t\$ PD(".$device."_SPXD);\n";
print TDAT "\n";
print TDAT "\tFAST;\n";
print TDAT "\n";
print TDAT "\t/* ERASE MAIN MEMORY*/\n";
print TDAT "\tLOAD DRIVE(1) MERASE_DATA;\n";
print TDAT "\tFLOOP(1)=14;\n";
print TDAT "\t\tGOSUB WRITE_DAP;\n";
print TDAT "\tEND FLOOP;\n";
print TDAT "\n";

print TDAT "\t/* WAIT UNTIL DONE */\n";
print TDAT "WLOOP:\n";
print TDAT "\tGOSUB READ_DRW_C16;\n";
print TDAT "\tGOTO WLOOP FLAG FAILS;\n";
print TDAT "\n";

print TDAT "\tEND FAST;\n";
print TDAT "\n";
print TDAT "\n";

fastsubs();

print TDAT "TABLE MERASE_DATA;\n";
print TDAT "\tIC(".$device."_SWDIO)\n";
print TDAT "\t/* CLEAR FLAGS */\n";
	commbyte_tm(0xD1);	#write tar
	commdata(0x40023C10);	#CR
	commbyte_tm(0xDD);	#write drw
	commdata(0x00000000);	#clear all flags
print TDAT "\t/* SET KEYS */\n";
	commbyte_tm(0xD1);	#write tar
	commdata(0x40023C04);	#KEYR
	commbyte_tm(0xDD);	#write drw
	commdata(0x45670123);	#KEY 1
	commbyte_tm(0xD1);	#write tar
	commdata(0x40023C04);	#KEYR
	commbyte_tm(0xDD);	#write drw
	commdata(0xCDEF89AB);	#KEY 2
print TDAT "\t/* START ERASE */\n";
	commbyte_tm(0xD1);	#write tar
	commdata(0x40023C10);	#CR
	commbyte_tm(0xDD);	#write drw
	commdata(0x00000200);	#x32

if($fblocks==2)
{	
	commbyte_tm(0xD1);	#write tar
	commdata(0x40023C10);	#CR
	commbyte_tm(0xDD);	#write drw
	commdata(0x00008204);	#x32, MER, MER1

	commbyte_tm(0xD1);	#write tar
	commdata(0x40023C10);	#CR
	commbyte_tm(0xDD);	#write drw
	commdata(0x00018204);	#x32, MER, MER1, STRT

	commbyte_tm(0xDD);	#write drw
	commdata(0x00018204);	#x32, MER, MER1, STRT
}
if($fblocks==1)
{	
	commbyte_tm(0xD1);	#write tar
	commdata(0x40023C10);	#CR
	commbyte_tm(0xDD);	#write drw
	commdata(0x00000204);	#x32, MER

	commbyte_tm(0xD1);	#write tar
	commdata(0x40023C10);	#CR
	commbyte_tm(0xDD);	#write drw
	commdata(0x00010204);	#x32, MER, STRT

	commbyte_tm(0xDD);	#write drw
	commdata(0x00010204);	#x32, MER, STRT
}

print TDAT "\t/* POLL STATUS */\n";
	commbyte_tm(0xD1);	#write tar
	commdata(0x40023C0C);	#CR

print TDAT "END TABLE;\n\n";

print TDAT "\tEND BURST;\n";
print TDAT "\n";
print TDAT "\tIF ".$device."_READNAILS($swdio_pin) THEN\n";
print TDAT "\t[\n";
print TDAT "\t\tWRITE 'FAILED ERASE MAIN MEMORY OF $device%NL%';\n";
print TDAT "\t\tBITSET(FAIL,1);\n";
print TDAT "\t\tBITSET(".$device."_PROGFAIL,1);\n";
print TDAT "\t\tBRANCH ".$device."_PDOWN;\n";
print TDAT "\t];\n";
print TDAT "\n";
}
