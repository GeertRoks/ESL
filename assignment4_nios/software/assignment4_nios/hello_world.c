/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <io.h>
#include "system.h"

int main()
{
  printf("Hello from Nios II!\n");
  // Put 0x08 in the memory of the IP and enable the count down
  	//IOWR(ASSIGNMENT4_QUAD_DEMONSTRATOR_0_BASE, 0x00, 1 << 31 | 0x08);

  	// Verify that it is there
  	int nReadOut = IORD(ASSIGNMENT4_QUAD_DEMONSTRATOR_0_BASE, 0x00);
  	printf("From the IP: %u \n\r", nReadOut);

  	// Now loop forever ...
  	while(1){
  		nReadOut = IORD(ASSIGNMENT4_QUAD_DEMONSTRATOR_0_BASE, 0x00);
  		 printf("From the IP: %u \n\r", nReadOut);

  		usleep(1000000);
  	}

  return 0;
}
