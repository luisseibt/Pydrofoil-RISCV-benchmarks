#include <sys/types.h>
extern char _end[];
static char *heap_ptr = _end;
void *_sbrk(ptrdiff_t incr) { char *p = heap_ptr; heap_ptr += incr; return p; }
int _read(int f, char *p, int n) { return 0; }
int _write(int f, char *p, int n) { return n; }
int _close(int f) { return -1; }
int _lseek(int f, int p, int d) { return 0; }
int _fstat(int f, void *st) { return -1; }
int _isatty(int f) { return 1; }