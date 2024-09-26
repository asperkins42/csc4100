#include "libos.h"
#include <stdlib.h> //to use exit()

int clear_scr(int start_row, int start_col, int width, int height);	
int box(unsigned int srow, unsigned int scol, unsigned int erow, unsigned int ecol);



int main () {
	
	// u_int declarations for box function
	unsigned int u_srow = 21;
	unsigned int u_scol = 49;
	unsigned int u_erow = 27;
	unsigned int u_ecol = 79;

	// int declarations for clear_scr
	int srow = 21;
	int scol = 49;
	int erow = 27; 
	int ecol = 79;

	// variable declarations for print_to
	unsigned int char_row = 24;
	unsigned int char_col = 59;
	char text[] = "Hello World";

	// clear_scr function -- C
	clear_scr(srow, scol, erow, ecol);
	
	// call box function -- ASSEMBLY
	box(u_srow, u_scol, u_erow, u_ecol);

	// write Hello World to screen
	print_to(char_row, char_col, text);
	
	return 0;

}

// clear_scr function
int clear_scr(int srow,  int scol,  int erow,  int ecol) {

	// declare variables for loopin'
	char empty = ' ';

	// sanity check parameters
	if ((erow <= srow) || (ecol <= scol)) {

		// if invalid, return 1
		return 1;
	}

	// if parameters are valid, clear the screen then return to the function
	for (int i = srow; i < erow; i++) {
		for (int k = scol; k < ecol; k++) {

			putc_to(i, k, empty);

		}
	}

	return 0;
}

