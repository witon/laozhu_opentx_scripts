#include <stdint.h>

char * strAppendStringWithIndex(char * dest, const char * s, int idx);
char * strAppend(char * dest, const char * source, int len=0);
char * strAppendUnsigned(char * dest, uint32_t value, uint8_t digits=0, uint8_t radix=10);