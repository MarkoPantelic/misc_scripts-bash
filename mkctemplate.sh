#!/bin/bash

# make c template file


echo "creating template file $1.c"
fname=$1


touch "$fname.c"

echo -e "#include <stdlib.h>
#include <stdio.h> \n
\n\n
int main()
{ \n\n\n\n
	printf(\"end\"); \n
\n
	exit(EXIT_FAILURE); \n
}" > "$fname.c"





