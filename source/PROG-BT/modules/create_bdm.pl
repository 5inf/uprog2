#!/usr/bin/perl
###############################################################################
#										#
# copyright (c) 2010-2016 Joerg Wolfram (joerg@jcwolfram.de)			#
#										#
#										#
# This program is free software; you can redistribute it and/or		#
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
# License along with this library// if not, write to the			#
# Free Software Foundation, Inc., 59 Temple Place - Suite 330,		#
# Boston, MA 02111-1307, USA.							#
#										#
###############################################################################
$base=20.0000;

use POSIX;

$frequency=$ARGV[0];
#$frequency=3;
#print "F= $frequency\n";

$fname=">bdm_sub_$frequency.asm";
$frq=$frequency + 0;
$slen_0=POSIX::floor($base / $frequency * 4 + 0.5);
$slen_d=POSIX::floor($base / $frequency * 9 + 0.5);
$slen_1=POSIX::floor($base / $frequency * 4 + 0.9);

$rlen_s=POSIX::floor($base / $frequency * 6 + 0.5);
$rlen_w=POSIX::floor($base / $frequency * 7 + 0.9);
$wlen16=POSIX::floor($base / $frequency * 17 + 0.5  - 9);
$wlen160=POSIX::floor($base / $frequency * 170 + 0.5 - 9);

#print "WL16  = $wlen16\n";
#print "WL160 = $wlen160\n";

open(FP,$fname);
printf FP ";---------------------------------------------------------------------\n";
printf FP "; generated file for frequency = $frequency MHz\n";
printf FP "; Send:\n";
printf FP "; SIZE-0 = $slen_0 clocks\n";
printf FP "; SIZE-D = $slen_d clocks\n";
printf FP "; SIZE-1 = $slen_1 clocks\n";
printf FP "; Receive:\n";
printf FP "; SIZE-0 = $slen_0 clocks\n";
printf FP "; SIZE-S = $rlen_s clocks\n";
printf FP "; SIZE-W = $rlen_w clocks\n";
printf FP ";---------------------------------------------------------------------\n";

printf FP ".org (pc + 255) & 0xff00\n";
	pline("send8","ldi","r20,8");			#num of bits
	pline("","mov","XH,XL");			#copy byte because XH will be shifted
	rjmp_line("send16_1");
printf FP "\n";

printf FP ".org (pc & 0xff00) + BDM_SUB_SWORD\n";
	pline("send16","ldi","r20,16");			#num of bits
	pline("send16_1","sbi","CTRLDDR,SIG2");		#2 set to input
	pline("","out","CTRLPORT,r0");			#1 start
	pwait($slen_0-2,"send16_2");			#n
	pline("","sbrc","XH,7");			#1 check bit
	pline("","out","CTRLPORT,r1");			#1  1-bit if available
	pwait($slen_d-1,"send16_3");			#n
	pline("","out","CTRLPORT,r1");			#1-bit
	pline("","cbi","CTRLDDR,SIG2");			#2 set to input
	pwait($slen_1-7,"send16_4");			#n
	pline("","lsl","XL");				#1 shift bit
	pline("","rol","XH");				#1 shift bit
	pline("","dec","r20");				#1 bit counter
	bneline("send16_1");				#1 bit loop
	pline("","ret");				#thats all
printf FP "\n";

printf FP ".org (pc & 0xff00) + BDM_SUB_RBYTE\n";
	pline("recv8","ldi","r20,8");			#num of bits
	rjmp_line("recv16_1");
printf FP "\n";

printf FP ".org (pc & 0xff00) + BDM_SUB_RWORD\n";
	pline("recv16","ldi","r20,16");			#num of bits
	pline("recv16_1","sbi","CTRLDDR,SIG2");		#2 set to input
	pline("","out","CTRLPORT,r0");			#1 start
	pwait($slen_0-1,"recv16_2");			#n
	pline("","cbi","CTRLDDR,SIG2");			#2 set to input
	pline("","out","CTRLPORT,r1");			#1 enable pull-up
	pwait($rlen_s-5,"recv16_3");			#n
	pline("","lsl","XL");				#1 shift bit
	pline("","rol","XH");				#1 shift bit
	pline("","sbic","CTRLPIN,SIG2");		#1 test
	pline("","inc","XL");				#1 set bit if necessary
	pwait($rlen_w-3,"recv16_4");			#n
	pline("","dec","r20");				#1 bit counter
	bneline("recv16_1");				#2 bit loop
	pline("","ret");				#1 end
printf FP "\n";


printf FP ".org (pc & 0xff00) + BDM_SUB_WAIT16\n";
	pline("wait16");
	pwait($wlen16,"wait16_1");			#n
	pline("","ret");				#1 end
printf FP "\n";

printf FP ".org (pc & 0xff00) + BDM_SUB_WAIT160\n";
	pline("wait160");
	if($wlen160 > 768)
	{
		$tlen=POSIX::floor($wlen160/8  - 2.5);
		pline("","ldi","r20,8");
		pline("wait160_1","","");
		pwait($tlen,"wait160_2");		#n
		pline("","dec","r20");
		bneline("wait160_1");
	}
	else
	{
		pwait($wlen160,"wait160_1");		#n
	}
	pline("","ret");				#1 end
printf FP "\n";

	#read byte to buffer (8bit), ADDR = R24/R25
printf FP ".org (pc & 0xff00) + BDM_SUB_BREAD8\n";
	pline("bread8","ldi","XL,0xe0");			#read byte
	rcall_line("send8");
	pline("","movw","XL,r24");
	rcall_line("send16");
	pline("","call","bdm_wait2_ack");				#wait for ack
	rcall_line("wait16");
	rcall_line("recv8");
	pline("","call","api_buf_bwrite");
	pline("","adiw","r24,1");
	pline("","ret");				#1 end
printf FP "\n";

	#write byte from buffer (8 bit), ADDR = R24/R25
printf FP ".org (pc & 0xff00) + BDM_SUB_BWRITE8\n";
	pline("bwrite8","ldi","XL,0xc0");			#write command
	rcall_line("send8");
	pline("","movw","XL,r24");
	rcall_line("send16");
	pline("","call","api_buf_bread");
	rcall_line("send8");
	pline("","call","bdm_wait2_ack");				#wait for ack
	rcall_line("wait16");
	pline("","adiw","r24,1");
	pline("","ret");				#1 end
printf FP "\n";

	#read byte from fixed address (8 bit), ADDR = R22/R23, DATA = XL
printf FP ".org (pc & 0xff00) + BDM_SUB_BREADF8\n";
	pline("breadf8","ldi","XL,0xe0");			#read byte command
	rcall_line("send8");
	pline("","movw","XL,r22");
	rcall_line("send16");
	pline("","call","bdm_wait2_ack");				#wait for ack
	rcall_line("wait16");
	rjmp_line("recv8");
printf FP "\n";

	#write byte to fixed address (8 bit), ADDR = R22/R23, DATA = XL
printf FP ".org (pc & 0xff00) + BDM_SUB_BWRITEF8\n";
	pline("","push","XL");
	pline("bwritef8","ldi","XL,0xc0");			#write command
	rcall_line("send8");
	pline("","movw","XL,r22");
	rcall_line("send16");
	pline("","pop","XL");
	rcall_line("send8");
	pline("","call","bdm_wait2_ack");				#wait for ack
	rjmp_line("wait16");
printf FP "\n";

	#read byte from fixed address (16 bit), ADDR = R22/R23, DATA = XL
printf FP ".org (pc & 0xff00) + BDM_SUB_BREADF16\n";
	pline("breadf16","ldi","XL,0xe0");			#read command
	pline("breadf16a","","");				#label for bdread
	rcall_line("send8");
	pline("","movw","XL,r22");
	rcall_line("send16");
	rcall_line("wait160");
	rcall_line("recv16");
	pline("","sbrs","r22,0");
	pline("","mov","XL,XH");
	pline("","ret");				#1 end
printf FP "\n";

	#write byte to fixed address (16 bit), ADDR = R22/R23, DATA = XL
printf FP ".org (pc & 0xff00) + BDM_SUB_BWRITEF16\n";
	pline("","push","XL");
	pline("bwritef16","ldi","XL,0xc0");			#write command
	pline("bwritef16a","","");				#label for bdwrite
	rcall_line("send8");
	pline("","movw","XL,r22");
	rcall_line("send16");
	pline("","pop","XL");
	pline("","mov","XH,XL");
	rcall_line("send16");
	rcall_line("wait160");
	pline("","ret");				#1 end
printf FP "\n";


	#read word to buffer (8bit), ADDR = R24/R25
printf FP ".org (pc & 0xff00) + BDM_SUB_WREAD\n";
	pline("wread","ldi","XL,0xe8");			#write command
	rcall_line("send8");
	pline("","movw","XL,r24");
	rcall_line("send16");
	rcall_line("wait160");
	rcall_line("recv16");
	pline("","call","api_buf_mwrite");
	pline("","adiw","r24,2");
	pline("","ret");				#1 end
printf FP "\n";

	#write word from buffer (8bit), ADDR = R24/R25
printf FP ".org (pc & 0xff00) + BDM_SUB_WWRITE\n";
	pline("wwrite","ldi","XL,0xc8");			#write command
	rcall_line("send8");
	pline("","movw","XL,r24");
	rcall_line("send16");
	pline("","call","api_buf_mread");
	rcall_line("send16");
	rcall_line("wait160");
	pline("","adiw","r24,2");
	pline("","ret");				#1 end
printf FP "\n";


	#read word from fixed address (16 bit), ADDR = R22/R23, DATA = X
printf FP ".org (pc & 0xff00) + BDM_SUB_WREADF\n";
	pline("wreadf","ldi","XL,0xe8");			#write command
	rcall_line("send8");
	pline("","movw","XL,r22");
	rcall_line("send16");
	rcall_line("wait160");
	rcall_line("recv16");
	pline("","ret");				#1 end
printf FP "\n";


	#write word to fixed address (16 bit), ADDR = R22/R23, DATA = X
printf FP ".org (pc & 0xff00) + BDM_SUB_WWRITEF\n";
	pline("wwritef","movw","r18,XL");
	pline("","ldi","XL,0xc8");			#write command
	rcall_line("send8");
	pline("","movw","XL,r22");
	rcall_line("send16");
	pline("","movw","XL,r18");
	rcall_line("send16");
	rjmp_line("wait160");
printf FP "\n";

	#read BDM status register to XL
printf FP ".org (pc & 0xff00) + BDM_SUB_RSTAT\n";
	pline("bstat16","ldi","XL,0xe4");		#read command
	pline("","ldi","r22,0x01");			#read command
	pline("","ldi","r23,0xff");			#read command
	rjmp_line("breadf16a");
printf FP "\n";

	#write BDM status register from XL
printf FP ".org (pc & 0xff00) + BDM_SUB_WSTAT\n";
	pline("","push","XL");				#read command
	pline("wstat16","ldi","XL,0xc4");		#read command
	pline("","ldi","r22,0x01");			#read command
	pline("","ldi","r23,0xff");			#read command
	rjmp_line("bwritef16a");
printf FP "\n";



printf FP "\n";


close(FP);


sub pline
{
	if($_[0] eq "")
	{
		$temp = "\t\t";
	}
	else
	{
		$temp="bdms".$frq."_".$_[0].":";
		if(length($temp) < 8)
		{
			$temp.="\t";
		}
		$temp.="\t";
	}
	$cmd=$_[1];
	$par=$_[2];
	print FP $temp;
	if($cmd ne "")
	{
		printf FP $cmd;
	}
	if($par ne "")
	{
		printf FP "\t".$par;
	}
	printf FP "\n";
}

sub bneline
{
	$temp="bdms".$frq."_".$_[0];
	printf FP "\t\tbrne\t$temp\n";
}

sub rcall_line
{
	$temp="bdms".$frq."_".$_[0];
	printf FP "\t\trcall\t$temp\n";
}

sub rjmp_line
{
	$temp="bdms".$frq."_".$_[0];
	printf FP "\t\trjmp\t$temp\n";
}

sub pwait
{
	$wtime=$_[0];
	if($wtime > 765)
	{
		print "TIME ERROR $wtime!!!\n";
	}
	$wrest=$wtime%3;
	$wloop=($wtime-$wrest)/3;
	if($wloop > 0)
	{
		pline("","ldi","r21,$wloop");			#num of bits
		pline($_[1],"dec","r21");			#num of bits
		bneline("$_[1]");				#1 shift bit
	}
	if($wrest > 1)
	{
		pline("","nop","");				#1 cycle filling
	}
	if($wrest > 0)
	{
		pline("","nop","");				#1 cycle filling
	}
}

