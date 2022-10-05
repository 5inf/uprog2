
	"R7F7015303",
	26,
	0x00000000,0x00180000,		//main flash bank A
	0x00800000,0x00180000,		//main flash bank B
	0x01000000,0x00008000,		//extended code flash
	0xFF200000,0x00010000,		//data flash
	0xFEBC0000,0x00040000,		//useable RAM (CPU1)
 	0x00000000,			//ID
	0x3203,				//wait time/FLMD0-pulses for CSI mode
	0x0081,				//SOD
	0x0000,				//lock bit?
	0x3630,				//code flash blocks
	0x0800,				//data flash blocks (1K blocks * 32)
	0x0000,
	0x0000,
	0x0000,
	
	"R7F7015313",
	26,
	0x00000000,0x00200000,		//main flash bank A
	0x00800000,0x00200000,		//main flash bank B
	0x01000000,0x00008000,		//extended code flash
	0xFF200000,0x00010000,		//data flash
	0xFEBC0000,0x00040000,		//useable RAM (CPU1)
 	0x00000000,			//ID
	0x3203,				//FLMD0-pulses for CSI mode
	0x0081,				//SOD
	0x0000,				//lock bit?
	0x4640,				//code flash blocks
	0x0800,				//data flash blocks (1K blocks * 32)
	0x0000,
	0x0000,
	0x0000,
	
	"R7F7015313F",
	26,
	0x00000000,0x00200000,		//main flash bank A
	0x00800000,0x00200000,		//main flash bank B
	0x01000000,0x00008000,		//extended code flash
	0xFF200000,0x00010000,		//data flash
	0xFEBC0000,0x00040000,		//useable RAM (CPU1)
 	0x00000000,			//ID
	0x3203,				//FLMD0-pulses for CSI mode
	0x0081,				//SOD
	0x0000,
	0x4640,				//code flash blocks
	0x0800,				//data flash blocks (1K blocks * 32)
	0x0000,
	0x0000,
	0x0000,

	"R7F701371",
	26,
	0x00000000,0x00400000,		//main flash bank A
	0x00800000,0x00400000,		//main flash bank B
	0x00000000,0x00000000,		//extended code flash
	0xFF200000,0x00030000,		//data flash
	0xFEBF0000,0x00010000,		//useable RAM (CPU1)
 	0x00000000,			//ID
	0x0803,				//FLMD0-pulses for CSI mode
	0x0081,				//SOD
	0x0004,				//Config
	0x8680,				//code flash blocks
	0x1800,				//data flash blocks (1K blocks * 32)
	0x0000,
	0x0006,				//offset for frequency setting	
	0x0000,


	"R7F701372",
	26,
	0x00000000,0x00200000,		//main flash bank A
	0x00800000,0x00200000,		//main flash bank B
	0x00000000,0x00000000,		//extended code flash
	0xFF200000,0x00020000,		//data flash
	0xFEBF0000,0x00010000,		//useable RAM (CPU1)
 	0x00000000,			//ID
	0x0803,				//FLMD0-pulses for CSI mode
	0x0081,				//SOD
	0x0004,				//config
	0x4640,				//code flash blocks
	0x1000,				//data flash blocks (1K blocks * 32)
	0x0000,
	0x0006,				//offset for frequency setting	
	0x0000,


	"R7F701372A",
	26,
	0x00000000,0x00200000,		//main flash bank A
	0x00800000,0x00200000,		//main flash bank B
	0x00000000,0x00000000,		//extended code flash
	0xFF200000,0x00020000,		//data flash
	0xFEBF0000,0x00010000,		//useable RAM (CPU1)
 	0x00000000,			//ID
	0x0803,				//FLMD0-pulses for CSI mode
	0x0081,				//SOD
	0x0004,				//config
	0x4640,				//code flash blocks
	0x1000,				//data flash blocks (1K blocks * 32)
	0x0000,				//OTP available
	0x0006,				//offset for frequency setting
	0x0000,

	"R7F701396A",
	26,
	0x00000000,0x00200000,		//main flash bank A
	0x00800000,0x00200000,		//main flash bank B
	0x00000000,0x00000000,		//extended code flash
	0xFF200000,0x00020000,		//data flash
	0xFEBF0000,0x00010000,		//useable RAM (CPU1)
 	0x00000000,			//ID
	0x0803,				//FLMD0-pulses for CSI mode
	0x0081,				//SOD
	0x0004,				//data flash erase modus
	0x4640,				//code flash blocks
	0x1000,				//data flash blocks (1K blocks * 32)
	0x0000,
	0x0006,				//offset for frequency setting
	0x0000,

	"RH850-DUMP",
	26,
	0x00000000,0x00004000,		//main flash bank A
	0x00000000,0x00000000,		//main flash bank B
	0x01000000,0x00008000,		//extended code flash
	0xFF200000,0x00010000,		//data flash
	0xFEDE0000,0x00008000,		//useable RAM (CPU1)
 	0x00000000,			//ID
	0x3203,				//FLMD0-pulses for CSI mode
	0x0081,				//SOD
	0x0000,				//lock bit?
	0x0200,				//code flash blocks
	0x03FF,				//data flash blocks (1K blocks * 32)
	0x0000,
	0x0006,				//offset for frequency setting
	0x0000,

	"RH850-DUMP8",
	26,
	0x00000000,0x00002000,		//main flash bank A
	0x00000000,0x00000000,		//main flash bank B
	0x01000000,0x00008000,		//extended code flash
	0xFF200000,0x00010000,		//data flash
	0xFEDE0000,0x00008000,		//useable RAM (CPU1)
 	0x00000000,			//ID
	0x3203,				//FLMD0-pulses for CSI mode
	0x0081,				//SOD
	0x0000,				//lock bit?
	0x0100,				//code flash blocks
	0x03FF,				//data flash blocks (1K blocks * 32)
	0x0000,
	0x0006,				//offset for frequency setting
	0x0000,
	
	"RH850B-DUMP",
	26,
	0x00000000,0x00004000,		//main flash bank A
	0x00000000,0x00000000,		//main flash bank B
	0x01000000,0x00008000,		//extended code flash
	0xFF200000,0x00010000,		//data flash
	0xFEDE0000,0x00008000,		//useable RAM (CPU1)
 	0x00000000,			//ID
	0x0803,				//FLMD0-pulses for CSI mode
	0x0081,				//SOD
	0x0000,				//lock bit?
	0x0200,				//code flash blocks
	0x03FF,				//data flash blocks (1K blocks * 32)
	0x0000,
	0x0006,				//offset for frequency setting
	0x0000,

	"RH850B-DUMP8",
	26,
	0x00000000,0x00002000,		//main flash bank A
	0x00000000,0x00000000,		//main flash bank B
	0x01000000,0x00008000,		//extended code flash
	0xFF200000,0x00010000,		//data flash
	0xFEDE0000,0x00008000,		//useable RAM (CPU1)
 	0x00000000,			//ID
	0x0803,				//FLMD0-pulses for CSI mode
	0x0081,				//SOD
	0x0000,				//lock bit?
	0x0100,				//code flash blocks
	0x03FF,				//data flash blocks (1K blocks * 32)
	0x0000,
	0x0006,				//offset for frequency setting
	0x0000,
	
