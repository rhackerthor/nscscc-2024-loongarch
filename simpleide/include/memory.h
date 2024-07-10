#ifndef __MEMORY_H__
#define __MEMORY_H__

#include <common.h>

#define MEM_SIZE 0x800000
#define MEM_BEGIN 0x80000000
#define MEM_END (MEM_BEGIN + MEM_SIZE - 1)
#define RAM_SIZE 0x400000
#define BASE_BEGIN MEM_BEGIN
#define BASE_END (BASE_BEGIN + RAM_SIZE - 1)
#define EXT_BEGIN (BASE_BEGIN + RAM_SIZE)
#define EXT_END (EXT_BEGIN + RAM_SIZE - 1)

extern uint8_t pmem[MEM_SIZE];
word_t pmem_read(uint8_t *ram, word_t raddr);
void pmem_write(uint8_t *ram, word_t waddr, word_t wdata, state_t wmask);
void load_image(const char *filename);

#endif