/*
 * Copyright (C) OpenTX
 *
 * Based on code named
 *   th9x - http://code.google.com/p/th9x
 *   er9x - http://code.google.com/p/er9x
 *   gruvin9x - http://code.google.com/p/gruvin9x
 *
 * License GPLv2: http://www.gnu.org/licenses/gpl-2.0.html
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

#ifndef _AUDIO_H_
#define _AUDIO_H_

#include <stddef.h>
#include <stdint.h>

#define SYSTEM_SUBDIR       "SYSTEM"
#define SOUNDS_EXT          ".wav"

enum AUDIO_SOUNDS {
  AUDIO_HELLO,
  AU_BYE,
  AU_THROTTLE_ALERT,
  AU_SWITCH_ALERT,
  AU_BAD_RADIODATA,
  AU_TX_BATTERY_LOW,
  AU_INACTIVITY,
  AU_RSSI_ORANGE,
  AU_RSSI_RED,
  AU_RAS_RED,
  AU_TELEMETRY_LOST,
  AU_TELEMETRY_BACK,
  AU_TRAINER_LOST,
  AU_TRAINER_BACK,
  AU_SENSOR_LOST,
  AU_SERVO_KO,
  AU_RX_OVERLOAD,
  AU_MODEL_STILL_POWERED,
#if defined(PCBSKY9X)
  AU_TX_MAH_HIGH,
  AU_TX_TEMP_HIGH,
#endif
  AU_ERROR,
  AU_WARNING1,
  AU_WARNING2,
  AU_WARNING3,
  AU_TRIM_MIDDLE,
  AU_TRIM_MIN,
  AU_TRIM_MAX,
  AU_STICK1_MIDDLE,
  AU_STICK2_MIDDLE,
  AU_STICK3_MIDDLE,
  AU_STICK4_MIDDLE,
#if defined(PCBTARANIS) || defined(PCBHORUS)
  AU_POT1_MIDDLE,
  AU_POT2_MIDDLE,
#if defined(PCBX9E)
  AU_POT3_MIDDLE,
  AU_POT4_MIDDLE,
#endif
  AU_SLIDER1_MIDDLE,
  AU_SLIDER2_MIDDLE,
#if defined(PCBX9E)
  AU_SLIDER3_MIDDLE,
  AU_SLIDER4_MIDDLE,
#endif
#else
  AU_POT1_MIDDLE,
  AU_POT2_MIDDLE,
  AU_POT3_MIDDLE,
#endif
  AU_MIX_WARNING_1,
  AU_MIX_WARNING_2,
  AU_MIX_WARNING_3,
  AU_TIMER1_ELAPSED,
  AU_TIMER2_ELAPSED,
  AU_TIMER3_ELAPSED,

  AU_SPECIAL_SOUND_FIRST,
  AU_SPECIAL_SOUND_BEEP1 = AU_SPECIAL_SOUND_FIRST,
  AU_SPECIAL_SOUND_BEEP2,
  AU_SPECIAL_SOUND_BEEP3,
  AU_SPECIAL_SOUND_WARN1,
  AU_SPECIAL_SOUND_WARN2,
  AU_SPECIAL_SOUND_CHEEP,
  AU_SPECIAL_SOUND_RATATA,
  AU_SPECIAL_SOUND_TICK,
  AU_SPECIAL_SOUND_SIREN,
  AU_SPECIAL_SOUND_RING,
  AU_SPECIAL_SOUND_SCIFI,
  AU_SPECIAL_SOUND_ROBOT,
  AU_SPECIAL_SOUND_CHIRP,
  AU_SPECIAL_SOUND_TADA,
  AU_SPECIAL_SOUND_CRICKET,
  AU_SPECIAL_SOUND_ALARMC,
  AU_SPECIAL_SOUND_LAST,

  AU_NONE=0xff
};

enum {
  // IDs for special functions [0:64]
  // IDs for global functions [64:128]
  ID_PLAY_PROMPT_BASE = 128,
  ID_PLAY_FROM_SD_MANAGER = 255,
};
struct LanguagePack;
extern const LanguagePack enLanguagePack;
extern const LanguagePack * currentLanguagePack;

void pushPrompt(uint16_t prompt, uint8_t id=0);
void pushUnit(uint8_t unit, uint8_t idx, uint8_t id);
void playModelName();
char * getAudioPath(char * path);

#define LEN_MODEL_NAME               10
#define LEN_FLIGHT_MODE_NAME         6

#define MAX_SOUND_PATH_LEN 256

constexpr uint16_t AUDIO_LUA_FILENAME_MAXLEN = MAX_SOUND_PATH_LEN; // Some scripts use long audio paths, even on 128x64 boards
constexpr uint16_t AUDIO_FILENAME_MAXLEN = MAX_SOUND_PATH_LEN; //(AUDIO_LUA_FILENAME_MAXLEN > AUDIO_MODEL_FILENAME_MAXLEN ? AUDIO_LUA_FILENAME_MAXLEN : AUDIO_MODEL_FILENAME_MAXLEN);

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

#endif // _AUDIO_H_
