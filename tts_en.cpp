/*
 * Authors (alphabetical order)
 * - Andre Bernet <bernet.andre@gmail.com>
 * - Andreas Weitl
 * - Bertrand Songis <bsongis@gmail.com>
 * - Bryan J. Rentoul (Gruvin) <gruvin@gmail.com>
 * - Cameron Weeks <th9xer@gmail.com>
 * - Erez Raviv
 * - Gabriel Birkus
 * - Jean-Pierre Parisy
 * - Karl Szmutny
 * - Michael Blandford
 * - Michal Hlavinka
 * - Pat Mackenzie
 * - Philip Moss
 * - Rob Thomson
 * - Romolo Manfredini <romolo.manfredini@gmail.com>
 * - Thomas Husterer
 *
 * opentx is based on code named
 * gruvin9x by Bryan J. Rentoul: http://code.google.com/p/gruvin9x/,
 * er9x by Erez Raviv: http://code.google.com/p/er9x/,
 * and the original (and ongoing) project by
 * Thomas Husterer, th9x: http://code.google.com/p/th9x/
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 */
#include "tts_en.h"
#include "./audio.h"
#include <stdlib.h>
enum TelemetryUnit {
  UNIT_RAW,
  UNIT_VOLTS,
  UNIT_AMPS,
  UNIT_MILLIAMPS,
  UNIT_KTS,
  UNIT_METERS_PER_SECOND,
  UNIT_FEET_PER_SECOND,
  UNIT_KMH,
  UNIT_SPEED = UNIT_KMH,
  UNIT_MPH,
  UNIT_METERS,
  UNIT_DIST = UNIT_METERS,
  UNIT_FEET,
  UNIT_CELSIUS,
  UNIT_TEMPERATURE = UNIT_CELSIUS,
  UNIT_FAHRENHEIT,
  UNIT_PERCENT,
  UNIT_MAH,
  UNIT_WATTS,
  UNIT_MILLIWATTS,
  UNIT_DB,
  UNIT_RPMS,
  UNIT_G,
  UNIT_DEGREE,
  UNIT_RADIANS,
  UNIT_MILLILITERS,
  UNIT_FLOZ,
  UNIT_MILLILITERS_PER_MINUTE,
  UNIT_HERTZ,
  UNIT_MS,
  UNIT_US,
  UNIT_MAX = UNIT_US,
  UNIT_SPARE4,
  UNIT_SPARE5,
  UNIT_SPARE6,
  UNIT_SPARE7,
  UNIT_SPARE8,
  UNIT_SPARE9,
  UNIT_SPARE10,
  UNIT_HOURS,
  UNIT_MINUTES,
  UNIT_SECONDS,
  // FrSky format used for these fields, could be another format in the future
  UNIT_FIRST_VIRTUAL,
  UNIT_CELLS = UNIT_FIRST_VIRTUAL,
  UNIT_DATETIME,
  UNIT_GPS,
  UNIT_BITFIELD,
  UNIT_TEXT,
  // Internal units (not stored in sensor unit)
  UNIT_GPS_LONGITUDE,
  UNIT_GPS_LATITUDE,
  UNIT_DATETIME_YEAR,
  UNIT_DATETIME_DAY_MONTH,
  UNIT_DATETIME_HOUR_MIN,
  UNIT_DATETIME_SEC
};

#if defined(SIMU)
  #define LANGUAGE_PACK_DECLARE(lng, name) const LanguagePack lng ## LanguagePack = { #lng, name, lng ## _ ## playNumber, lng ## _ ## playDuration }
#else
  #define LANGUAGE_PACK_DECLARE(lng, name) extern const LanguagePack lng ## LanguagePack = { #lng, name, lng ## _ ## playNumber, lng ## _ ## playDuration }
#endif

extern const LanguagePack enLanguagePack;
extern const LanguagePack * currentLanguagePack;

#define LANGUAGE_PACK_DECLARE_DEFAULT(lng, name) LANGUAGE_PACK_DECLARE(lng, name); const LanguagePack * currentLanguagePack = & lng ## LanguagePack; uint8_t currentLanguagePackIdx
#define MODE(flags)                    ((((int8_t)(flags) & 0x30) - 0x10) >> 4)
PLAY_FUNCTION(playNumber, getvalue_t number, uint8_t unit, uint8_t flags) { currentLanguagePack->playNumber(number, unit, flags, id); }
PLAY_FUNCTION(playDuration, int seconds, uint8_t flags) { currentLanguagePack->playDuration(seconds, flags, id); }


#define I18N_PLAY_FUNCTION(lng, x, ...) void lng ## _ ## x(__VA_ARGS__, uint8_t id)
#define PLAY_FUNCTION(x, ...)    void x(__VA_ARGS__, uint8_t id)
#define PUSH_NUMBER_PROMPT(p)    pushPrompt((p), id)
#define PUSH_UNIT_PROMPT(p, i)   pushUnit((p), (i), id)
#define PLAY_NUMBER(n, u, a)     playNumber((n), (u), (a), id)
#define PLAY_DURATION(d, att)    playDuration((d), (att), id)
#define PLAY_DURATION_ATT        , uint8_t flags
#define PLAY_TIME                1
#define IS_PLAY_TIME()           (flags&PLAY_TIME)
#define IS_PLAYING(id)           audioQueue.isPlaying((id))
#define PLAY_VALUE(v, id)        playValue((v), (id))
#define PLAY_FILE(f, flags, id)  audioQueue.playFile((f), (flags), (id))
#define STOP_PLAY(id)            audioQueue.stopPlay((id))
#define AUDIO_RESET()            audioQueue.stopAll()
#define AUDIO_FLUSH()            audioQueue.flush()

enum EnglishPrompts {
  EN_PROMPT_NUMBERS_BASE = 0,
  EN_PROMPT_ZERO = EN_PROMPT_NUMBERS_BASE+0,       //02-99
  EN_PROMPT_HUNDRED = EN_PROMPT_NUMBERS_BASE+100,  //100,200 .. 900
  EN_PROMPT_THOUSAND = EN_PROMPT_NUMBERS_BASE+109, //1000
  EN_PROMPT_AND = EN_PROMPT_NUMBERS_BASE+110,
  EN_PROMPT_MINUS = EN_PROMPT_NUMBERS_BASE+111,
  EN_PROMPT_POINT = EN_PROMPT_NUMBERS_BASE+112,
  EN_PROMPT_UNITS_BASE = 113,
  EN_PROMPT_POINT_BASE = 167, //.0 - .9
};


  #define EN_PUSH_UNIT_PROMPT(u, p) en_pushUnitPrompt((u), (p), id)

I18N_PLAY_FUNCTION(en, pushUnitPrompt, uint8_t unitprompt, int16_t number)
{
  if (number == 1)
    PUSH_UNIT_PROMPT(unitprompt, 0);
  else
    PUSH_UNIT_PROMPT(unitprompt, 1);
}

I18N_PLAY_FUNCTION(en, playNumber, getvalue_t number, uint8_t unit, uint8_t att)
{
  if (number < 0) {
    PUSH_NUMBER_PROMPT(EN_PROMPT_MINUS);
    number = -number;
  }


  int8_t mode = MODE(att);
  if (mode > 0) {
    if (mode == 2) {
      number /= 10;
    }
    div_t qr = div((int)number, 10);
    if (qr.rem) {
      PLAY_NUMBER(qr.quot, 0, 0);
      PUSH_NUMBER_PROMPT(EN_PROMPT_POINT_BASE + qr.rem);
      number = -1;
    }
    else {
      number = qr.quot;
    }
  }

  int16_t tmp = number;

  if (number >= 1000) {
    PLAY_NUMBER(number / 1000, 0, 0);
    PUSH_NUMBER_PROMPT(EN_PROMPT_THOUSAND);
    number %= 1000;
    if (number == 0)
      number = -1;
  }
  if (number >= 100) {
    PUSH_NUMBER_PROMPT(EN_PROMPT_HUNDRED + (number/100)-1);
    number %= 100;
    if (number == 0)
      number = -1;
  }
  if (number >= 0) {
    PUSH_NUMBER_PROMPT(EN_PROMPT_ZERO + number);
  }

  if (unit) {
    EN_PUSH_UNIT_PROMPT(unit, tmp);
  }
}

I18N_PLAY_FUNCTION(en, playDuration, int seconds PLAY_DURATION_ATT)
{
  if (seconds == 0) {
    PLAY_NUMBER(seconds, 0, 0);
    return;
  }

  if (seconds < 0) {
    PUSH_NUMBER_PROMPT(EN_PROMPT_MINUS);
    seconds = -seconds;
  }

  uint8_t tmp = seconds / 3600;
  seconds %= 3600;
  if (tmp > 0 || IS_PLAY_TIME()) {
    PLAY_NUMBER(tmp, UNIT_HOURS, 0);
  }

  tmp = seconds / 60;
  seconds %= 60;
  if (tmp > 0) {
    PLAY_NUMBER(tmp, UNIT_MINUTES, 0);
    if (seconds > 0)
      PUSH_NUMBER_PROMPT(EN_PROMPT_AND);
  }

  if (seconds > 0) {
    PLAY_NUMBER(seconds, UNIT_SECONDS, 0);
  }
}

LANGUAGE_PACK_DECLARE_DEFAULT(en, "English");
