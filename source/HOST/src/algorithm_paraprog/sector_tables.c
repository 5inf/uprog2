#include "main.h"

//###############################################################################
//# sector statrt addresses for different models
//###############################################################################
unsigned long pflash1_sector_bottom_8m[67]={
	//2M
	0x00000000,0x00004000,0x00008000,0x0000C000,	//boot blocks
	0x00010000,0x00020000,0x00030000,
	0x00040000,0x00050000,0x00060000,0x00070000,
	0x00080000,0x00090000,0x000A0000,0x000B0000,
	0x000C0000,0x000D0000,0x000E0000,0x000F0000,
	
	//2M
	0x00100000,0x00110000,0x00120000,0x00130000,
	0x00140000,0x00150000,0x00160000,0x00170000,
	0x00180000,0x00190000,0x001A0000,0x001B0000,
	0x001C0000,0x001D0000,0x001E0000,0x001F0000,

	//2M
	0x00200000,0x00210000,0x00220000,0x00230000,
	0x00240000,0x00250000,0x00260000,0x00270000,
	0x00280000,0x00290000,0x002A0000,0x002B0000,
	0x002C0000,0x002D0000,0x002E0000,0x002F0000,

	//2M
	0x00300000,0x00310000,0x00320000,0x00330000,
	0x00340000,0x00350000,0x00360000,0x00370000,
	0x00380000,0x00390000,0x003A0000,0x003B0000,
	0x003C0000,0x003D0000,0x003E0000,0x003F0000};

unsigned long pflash1_sector_top_8m[67]={
	//2M
	0x00000000,0x00010000,0x00020000,0x00030000,
	0x00040000,0x00050000,0x00060000,0x00070000,
	0x00080000,0x00090000,0x000A0000,0x000B0000,
	0x000C0000,0x000D0000,0x000E0000,0x000F0000,
	
	//2M
	0x00100000,0x00110000,0x00120000,0x00130000,
	0x00140000,0x00150000,0x00160000,0x00170000,
	0x00180000,0x00190000,0x001A0000,0x001B0000,
	0x001C0000,0x001D0000,0x001E0000,0x001F0000,

	//2M
	0x00200000,0x00210000,0x00220000,0x00230000,
	0x00240000,0x00250000,0x00260000,0x00270000,
	0x00280000,0x00290000,0x002A0000,0x002B0000,
	0x002C0000,0x002D0000,0x002E0000,0x002F0000,

	//2M
	0x00300000,0x00310000,0x00320000,0x00330000,
	0x00340000,0x00350000,0x00360000,0x00370000,
	0x00380000,0x00390000,0x003A0000,0x003B0000,
	0x003C0000,0x003D0000,0x003E0000,
	0x003F0000,0x003F4000,0x003F8000,0x003FC000	//boot blocks
};

unsigned long pflash1_sector_bottom_16m[131]={
	//2M
	0x00000000,0x00004000,0x00008000,0x0000C000,	//boot blocks
	0x00010000,0x00020000,0x00030000,
	0x00040000,0x00050000,0x00060000,0x00070000,
	0x00080000,0x00090000,0x000A0000,0x000B0000,
	0x000C0000,0x000D0000,0x000E0000,0x000F0000,
	
	//2M
	0x00100000,0x00110000,0x00120000,0x00130000,
	0x00140000,0x00150000,0x00160000,0x00170000,
	0x00180000,0x00190000,0x001A0000,0x001B0000,
	0x001C0000,0x001D0000,0x001E0000,0x001F0000,

	//2M
	0x00200000,0x00210000,0x00220000,0x00230000,
	0x00240000,0x00250000,0x00260000,0x00270000,
	0x00280000,0x00290000,0x002A0000,0x002B0000,
	0x002C0000,0x002D0000,0x002E0000,0x002F0000,

	//2M
	0x00300000,0x00310000,0x00320000,0x00330000,
	0x00340000,0x00350000,0x00360000,0x00370000,
	0x00380000,0x00390000,0x003A0000,0x003B0000,
	0x003C0000,0x003D0000,0x003E0000,0x003F0000,

	//2M
	0x00400000,0x00410000,0x00420000,0x00430000,
	0x00440000,0x00450000,0x00460000,0x00470000,
	0x00480000,0x00490000,0x004A0000,0x004B0000,
	0x004C0000,0x004D0000,0x004E0000,0x004F0000,

	//2M
	0x00500000,0x00510000,0x00520000,0x00530000,
	0x00540000,0x00550000,0x00560000,0x00570000,
	0x00580000,0x00590000,0x005A0000,0x005B0000,
	0x005C0000,0x005D0000,0x005E0000,0x005F0000,

	//2M
	0x00600000,0x00610000,0x00620000,0x00630000,
	0x00640000,0x00650000,0x00660000,0x00670000,
	0x00680000,0x00690000,0x006A0000,0x006B0000,
	0x006C0000,0x006D0000,0x006E0000,0x006F0000,

	//2M
	0x00700000,0x00710000,0x00720000,0x00730000,
	0x00740000,0x00750000,0x00760000,0x00770000,
	0x00780000,0x00790000,0x007A0000,0x007B0000,
	0x007C0000,0x007D0000,0x007E0000,0x007F0000
};

unsigned long pflash1_sector_top_16m[131]={
	//2M
	0x00000000,0x00010000,0x00020000,0x00030000,
	0x00040000,0x00050000,0x00060000,0x00070000,
	0x00080000,0x00090000,0x000A0000,0x000B0000,
	0x000C0000,0x000D0000,0x000E0000,0x000F0000,
	
	//2M
	0x00100000,0x00110000,0x00120000,0x00130000,
	0x00140000,0x00150000,0x00160000,0x00170000,
	0x00180000,0x00190000,0x001A0000,0x001B0000,
	0x001C0000,0x001D0000,0x001E0000,0x001F0000,

	//2M
	0x00200000,0x00210000,0x00220000,0x00230000,
	0x00240000,0x00250000,0x00260000,0x00270000,
	0x00280000,0x00290000,0x002A0000,0x002B0000,
	0x002C0000,0x002D0000,0x002E0000,0x002F0000,

	//2M
	0x00300000,0x00310000,0x00320000,0x00330000,
	0x00340000,0x00350000,0x00360000,0x00370000,
	0x00380000,0x00390000,0x003A0000,0x003B0000,
	0x003C0000,0x003D0000,0x003E0000,0x003F0000,

	//2M
	0x00400000,0x00410000,0x00420000,0x00430000,
	0x00440000,0x00450000,0x00460000,0x00470000,
	0x00480000,0x00490000,0x004A0000,0x004B0000,
	0x004C0000,0x004D0000,0x004E0000,0x004F0000,

	//2M
	0x00500000,0x00510000,0x00520000,0x00530000,
	0x00540000,0x00550000,0x00560000,0x00570000,
	0x00580000,0x00590000,0x005A0000,0x005B0000,
	0x005C0000,0x005D0000,0x005E0000,0x005F0000,

	//2M
	0x00600000,0x00610000,0x00620000,0x00630000,
	0x00640000,0x00650000,0x00660000,0x00670000,
	0x00680000,0x00690000,0x006A0000,0x006B0000,
	0x006C0000,0x006D0000,0x006E0000,0x006F0000,

	//2M
	0x00700000,0x00710000,0x00720000,0x00730000,
	0x00740000,0x00750000,0x00760000,0x00770000,
	0x00780000,0x00790000,0x007A0000,0x007B0000,
	0x007C0000,0x007D0000,0x007E0000,
	0x007F0000,0x007F4000,0x007F8000,0x007FC000};	//boot blocks
