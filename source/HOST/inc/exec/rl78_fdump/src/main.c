#include <r5f10a6a.h>
#include <unilib.h>

#define DATA_PIN PORT_4,0		//PIN 5

extern unsigned char get_fbyte0(unsigned int);
extern unsigned char get_fbyte1(unsigned int);
extern unsigned char get_fbyte2(unsigned int);
extern unsigned char get_fbyte3(unsigned int);
 
void out_byte(unsigned char data)
{
	int i;
	portpin_set_low(DATA_PIN);	//start
	unilib_pause(18);
	for(i=0;i<8;i++)
	{
		if(data & 0x01)
			portpin_set_high(DATA_PIN);	//start
		else
			portpin_set_low(DATA_PIN);	//start
		data >>=1;
		unilib_pause(18);
	}
	portpin_set_high(DATA_PIN);	//stop
	unilib_pause(36);
}


int main()
{
	int bytes;
	unsigned long ptr;
	unsigned char c;

	unilib_init();

	portpin_set_output(DATA_PIN);
	portpin_set_high(DATA_PIN);
	clock_config(CLOCK_I_16);

	ptr=0;		//start of Flash

	while(1)
	{
		portpin_set_input_pullup(DATA_PIN);
		while(portpin_get(DATA_PIN) != 0);
		while(portpin_get(DATA_PIN) == 0);
		unilib_pause_ms(1);
		portpin_set_high(DATA_PIN);
		portpin_set_output(DATA_PIN);

		for(bytes=0;bytes<2048;bytes++)
		{
			if(ptr < 0x10000) c=get_fbyte0(ptr & 0xFFFF);
			else if(ptr < 0x20000) c=get_fbyte1(ptr & 0xFFFF);
			else if(ptr < 0x30000) c=get_fbyte2(ptr & 0xFFFF);
			else c=get_fbyte3(ptr & 0xFFFF);
			
			ptr++;
			out_byte(c);
			//out_byte(170);
			//out_byte(get_fbyte(ptr++));
		}
	}
		
}
