/* main.cc */

#include "heading.h"
#include<string.h>

// prototype of bison-generated parser function
int yyparse();

int main(int argc, char **argv)
{
	if ((argc > 1) && (freopen(argv[1], "r", stdin) == NULL))
	  {
	    cerr << argv[0] << ": File " << argv[1] << " cannot be opened.\n";
	    return(0);
	  }
	int a=0;
	while(a != 4) {
		printf("\r> ");
		a = yyparse();
	}

  return 0;
}
