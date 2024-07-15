#include <cstd/file.h>
#include <cstd/debug.h>

File *f_open(const char *filename, const char *mode) {
  Assert(filename != NULL, "File name can not be empty!!!");
	FILE *fp = fopen(filename, mode);
	Assert(fp != NULL, "Open file: '%s' with mode: '%s' unsuccessfully", filename, mode);
  File *Fp = malloc(sizeof(File));
  Fp->fp = fp;
  strncpy(Fp->name, filename, strlen(filename));
  return Fp;
}

void f_read(void *dest, File *Fp, size_t nmemb, int offset) {
	f_seek(Fp, offset, FILE_SET);
	int readsize = fread(dest, 1, nmemb, Fp->fp);
	Assert(readsize == nmemb, "Read-out file '%s' unsuccessfully!", Fp->name);
}

void f_write(const void *src, File *Fp, size_t nmemb, int offset) {
  f_seek(Fp, offset, FILE_SET);
	int writesize = fwrite(src, 1, nmemb, Fp->fp);
	Assert(writesize == nmemb, "Write-in file '%s' unsuccessfully!", Fp->name);
}

size_t f_seek(File *Fp, size_t offset, int mode) {
  switch(mode) {
    case FILE_SET: mode = SEEK_SET; break;
    case FILE_CUR: mode = SEEK_CUR; break;
    case FILE_END: mode = SEEK_END; break;
  }
  fseek(Fp->fp, offset, mode);
	size_t position = ftell(Fp->fp);
  return position;
}

size_t f_size(File *Fp) {
  return f_seek(Fp, 0, FILE_END);
}

void f_close(File *Fp) {
  fclose(Fp->fp);
}