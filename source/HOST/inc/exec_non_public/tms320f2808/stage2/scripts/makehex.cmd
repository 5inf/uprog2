result.out
-i
-o result.lsb
-o result.msb
-o result.lsb
-o result.msb
--map=result.map

SECTIONS
{
	codestart
	.text
	.cinit
	.const
	.data
	.econst
}