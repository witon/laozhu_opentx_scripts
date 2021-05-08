gcc -DBUILD_DLL -c audioQueue.cpp
gcc -DBUILD_DLL -c audio.cpp
gcc -DBUILD_DLL -c tts_en.cpp
gcc -DBUILD_DLL -c  strhelpers.cpp
gcc -DBUILD_DLL -c luaApi.cpp -Ic:\local\lua-5.3.6\dist\include 
gcc -DBUILD_DLL -c sounddll.cpp -Ic:\local\lua-5.3.6\dist\include 
gcc -shared -o sound.dll luaApi.o audioQueue.o audio.o tts_en.o strhelpers.o sounddll.o -lwinmm -LC:\msys64\mingw64\x86_64-w64-mingw32\lib -lstdc++ -llua -Lc:\local\lua-5.3.6\dist\lib\
rem copy sound.dll c:\opentxsdcard1\SCRIPTS\
