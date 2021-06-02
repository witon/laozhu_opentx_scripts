cmake . -B build -G "MinGW Makefiles"
cd build
cmake --build .
cd ..
copy build\sound.dll .
