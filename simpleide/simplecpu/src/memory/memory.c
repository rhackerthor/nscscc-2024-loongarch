#include <cpu/cpu.h>
#include <memory.h>

uint8_t pmem[MEM_SIZE];

static word_t guest_to_host(word_t vaddr) {
  Assert(RANGE(vaddr, MEM_BEGIN, MEM_BEGIN + MEM_SIZE), 
    "address: " FMT_WORD " is out of bound of pmem [" FMT_WORD ", " FMT_WORD "] at pc " FMT_WORD,
    vaddr, MEM_BEGIN, MEM_END, cpu_pc
  );
  return ((vaddr - MEM_BEGIN) >> 2) << 2;
}

word_t pmem_read(word_t raddr, state_t rmask) {
  /* 串口 */
  if (raddr == 0xbfd003fc) return 0x3;
  if (raddr == 0xbfd003f8) {
    Waring("uart rdata:");
    char c = getchar();
    return c;
  }
  /* 正常访存 */
  word_t addr = guest_to_host(raddr);
	word_t rdata = 0;
	uint8_t *d = (uint8_t *) &rdata;
	for (int i = 0; i < 4; i++) {
		d[i] = pmem[addr + i];
  }
  switch (rmask) {
    case 0b0001: rdata = BITS(rdata,  7,  0); break;
    case 0b0010: rdata = BITS(rdata, 15,  8); break;
    case 0b0100: rdata = BITS(rdata, 23, 16); break;
    case 0b1000: rdata = BITS(rdata, 31, 24); break;
    default:     rdata = rdata;               break;
  }
	return rdata;
}

void pmem_write(word_t waddr, word_t wdata, state_t wmask) {
  /* 串口 */
  if (waddr == 0xbfd003fc) return;
  if (waddr == 0xbfd003f8) {
    Waring("at pc: " FMT_WORD " uart wdata: %c", cpu_pc, wdata);
    return;
  }
  /* 正常访存 */
  word_t addr = guest_to_host(waddr);
  uint8_t *d = (uint8_t *)&wdata;
  for (int i = 0; i < 4; i++) {
    if ((wmask >> i) & 0x1) {
      pmem[addr + i] = d[i];
    }
  }
}

void load_image(const char *filename) {
  File *Fp = f_open(filename, "rb+");
  size_t filesize = f_size(Fp);
  printf("The image is %s, size = %ld\n", filename, filesize);
  f_read(pmem, Fp, filesize, 0);
  f_close(Fp);
}