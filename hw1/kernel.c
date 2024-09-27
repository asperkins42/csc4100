#include "libos.h"
#include <stdio.h>

int box(unsigned int srow, unsigned int scol, unsigned int erow, unsigned int ecol); 
int clear_scr(int start_row, int start_col, int width, int height);	

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
	for (int i = srow; i <= erow; i++) {
		for (int k = scol; k <= ecol; k++) {

			putc_to(i, k, empty);

		}
	}

	return 0;
}


int main() {

	// variable declarations
	unsigned int srow = 21; 
	unsigned int scol = 49; 
	unsigned int erow = 27; 
	unsigned int ecol = 79; 

	// variables for clear screen
	int s_row = 21;
	int s_col = 49;
	int e_row = 27;
	int e_col = 79;

	// clear the screen
	clear_scr(s_row, s_col, e_row, e_col);

	// set finished to 1 or 0 depending on if errors occured drawing the box
	int finished = box(srow, scol, erow, ecol); 

		if (finished == 0) {

			// if we finish and are good...
			print_to(24, 59, "Hello World"); 

		} else {

			// if we finish and are not...
			print_to(24, 59, "Broken D:"); 
		}


	return 0;  

}
