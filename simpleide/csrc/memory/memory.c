#include <memory.h>
#include <cpu.h>

uint8_t pmem[MEM_SIZE];

static word_t guest_to_host(word_t vaddr) {
  Assert(RANGE(vaddr, MEM_BEGIN, MEM_BEGIN + MEM_SIZE), 
    "address: " FMT_WORD " is out of bound of pmem [" FMT_WORD ", " FMT_WORD "] at pc " FMT_WORD,
    vaddr, MEM_START, MEM_END, cpu_pc
  );
  return ((vaddr - MEM_BEGIN) >> 2) << 2;
}

word_t pmem_read(uint8_t *ram, word_t raddr) {
  word_t addr = guest_to_host(raddr);
	word_t rdata = 0;
	uint8_t *d = (uint8_t *) &rdata;
	for (int i = 0; i < 4; i++) {
		d[i] = ram[addr + i];
  }
	return rdata;
}

void pmem_write(uint8_t *ram, word_t waddr, word_t wdata, state_t wmask) {
  word_t addr = guest_to_host(waddr);
  uint8_t *d = (uint8_t *)&wdata;
  for (int i = 0; i < 4; i++) {
    if ((wmask >> i) & 0x1) {
      ram[addr + i] = d[i];
    }
  }
}

void load_image(uint8_t *ram, const char *filename) {
  File *Fp = f_open(filename, "rb+");
  size_t filesize = f_size(Fp);
  printf("The image is %s, size = %ld\n", filename, filesize);
  f_read(ram, Fp, filesize, 0);
  f_close(Fp);
}