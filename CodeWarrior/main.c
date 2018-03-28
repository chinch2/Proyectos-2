/* ###################################################################
**     Filename    : main.c
**     Project     : Contador
**     Processor   : MC9S08QE128CLK
**     Version     : Driver 01.12
**     Compiler    : CodeWarrior HCS08 C Compiler
**     Date/Time   : 2016-09-28, 15:13, # CodeGen: 0
**     Abstract    :
**         Main module.
**         This module contains user's application code.
**     Settings    :
**     Contents    :
**         No public methods
**
** ###################################################################*/
/*!
** @file main.c
** @version 01.12
** @brief
**         Main module.
**         This module contains user's application code.
*/         
/*!
**  @addtogroup main_module main module documentation
**  @{
*/         
/* MODULE main */


/* Including needed modules to compile this module/procedure */
#include "Cpu.h"
#include "Events.h"
#include "AS1.h"
#include "TI1.h"
#include "AD1.h"
#include "Bit1.h"
#include "Bit2.h"
/* Include shared modules, which are used for whole project */
#include "PE_Types.h"
#include "PE_Error.h"
#include "PE_Const.h"
#include "IO_Map.h"

/* User includes (#include below this line is not maintained by Processor Expert) */                      
	
	int contadorr;
	
	int i;
	unsigned char CodError;
	int dato;
	unsigned int dato2;
	unsigned char b;
	unsigned char c;
	bool digital1;
	bool digital2;
	bool digital3;
	bool digital4;
	unsigned char trama[5] = {0xF2, 0x00, 0x00, 0x00, 0x00};
	unsigned char error;
	int estado = 0;
	 
void main(void)
{
  /* Write your local variable definition here */	
  /*** Processor Expert internal initialization. DON'T REMOVE THIS CODE!!! ***/
  PE_low_level_init();
  /*** End of Processor Expert internal initialization.                    ***/
  
  /* Write your code here */

AD1_Start();
  
while (1){
	if(estado){
		// Primer canal
		
		AD1_MeasureChan(TRUE, 0);
		CodError =  AD1_GetChanValue16(0, &dato);
		dato = dato >> 4;
		c = dato & 0x007F;
		b = dato >> 7;
		b = b & 0x1F;
		digital1 = Bit1_GetVal();
		if(digital1){
			b = b | 0x40;
		}
		if(digital2){
			b = b | 0x20;
		}

		trama[1] = b;
		trama[2] = c;
		
		// Segundo canal
		AD1_MeasureChan(TRUE, 1);
		CodError =  AD1_GetChanValue16(1, &dato2);
		dato2 = dato2 >> 4;
		c = dato2 & 0x007F;
		b = dato2 >> 7;
		b = b & 0x1F;
		if(digital3){
			b = b | 0x40;
		}
		if(digital4){
			b = b | 0x20;
		}

		trama[3] = b;
		trama[4] = c;

		// Enviamos los canales por serial
		for(i = 0; i < 5; i++){
			do{
				CodError = AS1_SendChar(trama[i]);
			} while (CodError != ERR_OK);
		}
		
		/*do{
			Coderror = AS1_SendChar(trama[0]);
		}while (Coderror != ERR_OK);
		
		do{
			Coderror = AS1_SendChar(trama[1]);
		}while (Coderror != ERR_OK);
				
		do{
			Coderror = AS1_SendChar(trama[2]);
		}while (Coderror != ERR_OK);
		
		do{
			Coderror = AS1_SendChar(trama[3]);
		}while (Coderror != ERR_OK);
		
		do{
			Coderror = AS1_SendChar(trama[4]);
		}while (Coderror != ERR_OK);*/
		
		estado = 0;
		
	}
}




































  /*** Don't write any code pass this line, or it will be deleted during code generation. ***/
  /*** RTOS startup code. Macro PEX_RTOS_START is defined by the RTOS component. DON'T MODIFY THIS CODE!!! ***/
  #ifdef PEX_RTOS_START
    PEX_RTOS_START();                  /* Startup of the selected RTOS. Macro is defined by the RTOS component. */
  #endif
  /*** End of RTOS startup code.  ***/
  /*** Processor Expert end of main routine. DON'T MODIFY THIS CODE!!! ***/
  for(;;){}
  /*** Processor Expert end of main routine. DON'T WRITE CODE BELOW!!! ***/
} /*** End of main routine. DO NOT MODIFY THIS TEXT!!! ***/

/* END main */
/*!
** @}
*/
/*
** ###################################################################
**
**     This file was created by Processor Expert 10.3 [05.09]
**     for the Freescale HCS08 series of microcontrollers.
**
** ###################################################################
*/
