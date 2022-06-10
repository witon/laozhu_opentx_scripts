#!/bin/bash
cd competition_lib
cmake . -B sobuild
cmake --build sobuild
cp sobuild/sound.so ../sound.so
cd ..
