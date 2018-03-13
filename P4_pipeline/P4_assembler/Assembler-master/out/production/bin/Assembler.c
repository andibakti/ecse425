#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>

int executecmd(char **args)
 {
 	if (execvp(args[0], args) == -1) {
 		perror("error during child process");
 	}
 	return 1;
}

 int main(int argc, char **argv)
 {
 	if (argc < 2)
 		exit(EXIT_FAILURE);

 	char* args[3];
 	args[0] = "javac";
 	args[1] = "Driver.java";
 	args[2] = NULL;
 	
	executecmd(args);

 	args[0] = "java";
 	args[1] = "Driver";
 	args[2] = argv[1];

	executecmd(args);
	
 	puts("ran2\n");

 	return 1;
 }