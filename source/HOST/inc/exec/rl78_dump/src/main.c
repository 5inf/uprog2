#include <r5f10bgg.h>
#include <unilib.h>

#define DATA_PIN PORT_4,0		//PIN 5


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
	unilib_pause(100);
}


int main()
{
	int bytes;
	unsigned char *rptr;	

	unilib_init();

	portpin_set_output(DATA_PIN);
	portpin_set_high(DATA_PIN);
	clock_config(CLOCK_I_16);

	rptr=0xF0090;
	*rptr=1;	//enable DF

	rptr=0xF1000;	//start of DF

	while(1)
	{
		portpin_set_input_pullup(DATA_PIN);
		while(portpin_get(DATA_PIN) != 0);
		while(portpin_get(DATA_PIN) == 0);
		unilib_pause_ms(5);
		portpin_set_high(DATA_PIN);
		portpin_set_output(DATA_PIN);

		for(bytes=0;bytes<2048;bytes++) out_byte(*rptr++);
	}
		
}
