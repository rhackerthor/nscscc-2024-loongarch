#ifndef __CSTD_FILE_H__
#define __CSTD_FILE_H__

#include <cstd/cstd.h>

#define MAX_FILENAME_LEN 128
enum {FILE_SET, FILE_CUR, FILE_END};

typedef struct {
  FILE *fp;
  char name[MAX_FILENAME_LEN];
} File;

File *f_open(const char *filename, const char *mode);
void f_read(void *dest, File *Fp, size_t nmemb, int offset);
void f_write(const void *src, File *Fp, size_t nmemb, int offset);
void f_seek(File *Fp, int offset, int mode);
size_t f_size(File *Fp);
void f_colse(File *Fp);

#endif