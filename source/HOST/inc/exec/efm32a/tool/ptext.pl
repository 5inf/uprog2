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

$rfile=$ARGV[0];
$wfile=$ARGV[1];

open(RFILE,$rfile);
open(WFILE,">".$wfile);
while(<RFILE>)
{
	chomp();
	$line=$_;
	$line=~ s/MC1/\$device/g;
	$line=~ s/\t/\\t/g;
	$line= "\tprint TDAT \"".$line."\\n\";\n";
	print WFILE $line;
}
close(RFILE);
close(WFILE);

