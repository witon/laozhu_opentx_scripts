#include <stdlib.h>
#include <stdint.h>
#include "strhelpers.h"

char * strAppendUnsigned(char * dest, uint32_t value, uint8_t digits, uint8_t radix)
{
  if (digits == 0) {
    unsigned int tmp = value;
    digits = 1;
    while (tmp >= radix) {
      ++digits;
      tmp /= radix;
    }
  }
  uint8_t idx = digits;
  while (idx > 0) {
    div_t qr = div(value, radix);
    dest[--idx] = (qr.rem >= 10 ? 'A' - 10 : '0') + qr.rem;
    value = qr.quot;
  }
  dest[digits] = '\0';
  return &dest[digits];
}

char * strAppend(char * dest, const char * source, int len)
{
  while ((*dest++ = *source++)) {
    if (--len == 0) {
      *dest = '\0';
      return dest;
    }
  }
  return dest - 1;
}
char * strAppendStringWithIndex(char * dest, const char * s, int idx)
{
  return strAppendUnsigned(strAppend(dest, s), abs(idx));
}

