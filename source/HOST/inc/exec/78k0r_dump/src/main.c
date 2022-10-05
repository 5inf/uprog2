#include <upd78f1804.h>
#include <unilib.h>

#define DATA_PIN PORT_4,0		//TOOL0


void out_byte(unsigned char data)
{
	int i;
	portpin_set_low(DATA_PIN);	//start
	unilib_pause(12);
	for(i=0;i<8;i++)
	{
		if(data & 0x01)
			portpin_set_high(DATA_PIN);	//start
		else
			portpin_set_low(DATA_PIN);	//start
		data >>=1;
		unilib_pause(12);
	}
	portpin_set_high(DATA_PIN);	//stop
	unilib_pause(100);
}


int main()
{
	int bytes;
	unsigned long rptr;
	unsigned char *xptr;	

	unilib_init();

	portpin_set_output(DATA_PIN);
	portpin_set_high(DATA_PIN);
	clock_config(CLOCK_I_12);

	xptr=0xF00F1;
	*xptr=1;	//enable DF

	unilib_pause_ms(10);

	rptr=0x9800;	//start of DF

	while(1)
	{
		portpin_set_input_pullup(DATA_PIN);
		while(portpin_get(DATA_PIN) != 0);
		while(portpin_get(DATA_PIN) == 0);
		unilib_pause_ms(5);
		portpin_set_high(DATA_PIN);
		portpin_set_output(DATA_PIN);
		for(bytes=0;bytes<2048;bytes++) out_byte(get_dfbyte(rptr & 0xFFFF));
		rptr++;
	}
		
}
