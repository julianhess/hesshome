#include <limits.h>
#include <stdlib.h>
#include <stdio.h>

/*
 * usage: realpath <path>
 * completely expands all symlinks.  wrapper to system call realpath.
 * 2015-04-27//Julian Hess
 */

int main(int argc, char** argv) {
   char* rp;

   if(argc < 2) {
      printf("Usage: realpath <path>\n");
      exit(1);
   }

   if(!(rp = realpath(argv[1], rp))) {
      printf("Error: %s does not exist.\n", argv[1]);
      exit(1);
   } else printf("%s\n", rp);
}
