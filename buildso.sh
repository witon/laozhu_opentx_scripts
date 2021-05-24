#!/bin/bash
rm *.o
gcc -c audioQueue.cpp -fPIC
gcc -c audio.cpp -fPIC
gcc -c tts_en.cpp -fPIC
gcc -c strhelpers.cpp -fPIC
gcc -c luaApi.cpp -I/usr/include/lua5.3/ -fPIC
gcc -c soundso.cpp -I/usr/include/lua5.3/ -fPIC
gcc -c playsound.cpp -fPIC
gcc -c WaveFile.cpp -fPIC
gcc -shared -o sound.so WaveFile.o playsound.o audioQueue.o audio.o tts_en.o strhelpers.o luaApi.o soundso.o -lstdc++ -lpthread -lasound


