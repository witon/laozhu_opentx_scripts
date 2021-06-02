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

#include "./audio.h"
#include "tts_en.h"
#include <string.h> 
#include "strhelpers.h"
#include "audioQueue.h"
#include <stdio.h>

//#define ROOT_PATH           "c:/opentxsdcard1/"
//#define ROOT_PATH     "/home/witon/code/"
char soundPath[MAX_SOUND_PATH_LEN + 1] = {0};
int soundPathLngOfs = 0;
//#define SOUNDS_PATH         ROOT_PATH "SOUNDS/en"
//#define SOUNDS_PATH_LNG_OFS (sizeof(SOUNDS_PATH)-3)

#if !defined(DIM)
  #define DIM(__arr) (sizeof((__arr)) / sizeof((__arr)[0]))
#endif


const char * const unitsFilenames[] = {
  "",
  "volt",
  "amp",
  "mamp",
  "knot",
  "mps",
  "fps",
  "kph",
  "mph",
  "meter",
  "foot",
  "celsius",
  "fahr",
  "percent",
  "mamph",
  "watt",
  "mwatt",
  "db",
  "rpm",
  "g",
  "degree",
  "radian",
  "ml",
  "founce",
  "mlpm",
  "hertz",
  "ms",
  "us",
  "spare4",
  "spare5",
  "spare6",
  "spare7",
  "spare8",
  "spare9",
  "spare10",
  "hour",
  "minute",
  "second",
};

AudioQueue audioQueue;

const char * const audioFilenames[] = {
  "hello",
  "bye",
  "thralert",
  "swalert",
  "baddata",
  "lowbatt",
  "inactiv",
  "rssi_org",
  "rssi_red",
  "swr_red",
  "telemko",
  "telemok",
  "trainko",
  "trainok",
  "sensorko",
  "servoko",
  "rxko",
  "modelpwr",
#if defined(PCBSKY9X)
  "highmah",
  "hightemp",
#endif
  "error",
  "warning1",
  "warning2",
  "warning3",
  "midtrim",
  "mintrim",
  "maxtrim",
  "midstck1",
  "midstck2",
  "midstck3",
  "midstck4",
#if defined(PCBTARANIS) || defined(PCBHORUS)
  "midpot1",
  "midpot2",
#if defined(PCBX9E)
  "midpot3",
  "midpot4",
#endif
  "midslid1",
  "midslid2",
#if defined(PCBX9E)
  "midslid3",
  "midslid4",
#endif
#else
  "midpot1",
  "midpot2",
  "midpot3",
#endif
  "mixwarn1",
  "mixwarn2",
  "mixwarn3",
  "timovr1",
  "timovr2",
  "timovr3"
};

//TODO: 文件路径过长有越界风险。
char * getAudioPath(char * path)
{
  strncpy(path, soundPath, MAX_SOUND_PATH_LEN-1);
  strncpy(path+soundPathLngOfs, currentLanguagePack->id, 3);
  strncat(path, "/", MAX_SOUND_PATH_LEN-strlen(path));
  return path + strlen(path);
}

char * strAppendSystemAudioPath(char * path)
{
  char * str = getAudioPath(path);
  strncpy(str, SYSTEM_SUBDIR "/", MAX_SOUND_PATH_LEN - strlen(path));
  return str + sizeof(SYSTEM_SUBDIR);
}

/*
void getSystemAudioFile(char * filename, int index)
{
  printf("get SystemAudioFile input filename:%s\n", filename);
  char * str = strAppendSystemAudioPath(filename);
  strcpy(str, audioFilenames[index]);
  strcat(str, SOUNDS_EXT);
}
*/



void pushUnit(uint8_t unit, uint8_t idx, uint8_t id)
{
  if (unit < DIM(unitsFilenames)) {
    char path[AUDIO_FILENAME_MAXLEN+1];
    char * tmp = strAppendSystemAudioPath(path);
    tmp = strAppendStringWithIndex(tmp, unitsFilenames[unit], idx);
    strcpy(tmp, SOUNDS_EXT);
    audioQueue.playFile(path, 0, id);
  }
  else {
    printf("pushUnit: out of bounds unit : %d", unit); // We should never get here, but given the nature of TTS files, this prevent segfault in case of bug there.
  }
}

void pushPrompt(uint16_t prompt, uint8_t id)
{
  char filename[AUDIO_FILENAME_MAXLEN+1];
  char * str = strAppendSystemAudioPath(filename);
  strcpy(str, "0000" SOUNDS_EXT);
  for (int8_t i=3; i>=0; i--) {
    str[i] = '0' + (prompt%10);
    prompt /= 10;
  }
  audioQueue.playFile(filename, 0, id);
}
