#include <errno.h>
#include <limits.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/*
 * usage: realpath <path> [path [path [...]]]
 * completely expands all symlinks.  wrapper to system call realpath.
 */

int main(int argc, char** argv) {
   if(argc < 2) {
      printf("Usage: realpath <path> [path [path [...]]]\n");
      exit(1);
   }

   int ret = 0;
   int i = 1;
   char* rp = malloc(PATH_MAX);
   while(i < argc) {
      if(!(rp = realpath(argv[i], rp))) {
         ret = errno;
         fprintf(stderr, "realpath: error processing '%s': %s.\n", argv[i], strerror(ret));
      } else printf("%s\n", rp);
      i++;
   }
   return ret;
}
