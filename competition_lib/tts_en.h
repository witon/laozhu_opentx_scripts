
#include <stdint.h>

#ifndef __TTS_EN_H_
#define __TTS_EN_H_
typedef int32_t getvalue_t;
struct LanguagePack{
  const char * id;
  const char * name;
  void (*playNumber)(getvalue_t number, uint8_t unit, uint8_t flags, uint8_t id);
  void (*playDuration)(int seconds, uint8_t flags, uint8_t id);
} ;
void playNumber(getvalue_t number, uint8_t unit, uint8_t flags, uint8_t id);
void playDuration(int seconds, uint8_t flags, uint8_t id);

//inline PLAY_FUNCTION(playNumber, getvalue_t number, uint8_t unit, uint8_t flags) { currentLanguagePack->playNumber(number, unit, flags, id); }
//inline PLAY_FUNCTION(playDuration, int seconds, uint8_t flags) { currentLanguagePack->playDuration(seconds, flags, id); }

#endif