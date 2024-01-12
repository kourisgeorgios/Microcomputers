
#define F_CPU 16000000UL
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

volatile uint8_t refreshFlag = 0;  // Flag to indicate refresh, volatile to be accessible by anyone

ISR(INT1_vect)
{
	refreshFlag = 1;  // Set refresh flag upon INT1 activation if PD3 is pressed
}

int main()
{
	DDRB = 0xFF;  // Set PORTB pins as outputs
	PORTB = 0x00;  // Initialize PORTB with all LEDs turned off

	DDRD &= ~(1 << PD3);  // Set PD3 as input
	PORTD |= (1 << PD3);  // Enable internal pull-up resistor on PD3, logika 8a fygei

	// Configure external interrupt on rising edge for INT1
	EICRA |= ((1 << ISC11) | (0 << ISC10));   	//up to debate

	// Clear the interrupt flag for INT1
	EIFR |= (1 << INTF1);				// up to debate
	
	// Enable INT1 interrupt
	EIMSK |= (1 << INT1);

	sei();  // Enable global interrupts
	int i, time;
	
	while (1)
	{
		if (refreshFlag)				// If the PD3 is pressed 
		{
			time = 4000;  	// 4 sec
			PORTB = 0x01;  	// Turn on only PB0 LED
			refreshFlag = 0;
			
  			while (time != 0)
  			{
   				_delay_ms(500);	// Delay for 0.5 seconds
				time = time - 500;
				
				if (refreshFlag) 
				{	
					refreshFlag = 0;
					PORTB = 0xFF;  	// Turn on all LEDs connected to PORTB for 0.5 sec
					_delay_ms(500);
					PORTB = 0x01;	// Leave just PB0 on
					time = 4000;	// Refresh time
				}
  			}
                        PORTB = 0x00; 
		}
	}

	return 0;
}
