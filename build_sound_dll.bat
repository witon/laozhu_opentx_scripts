cd competition_lib
cmake . -B dllbuild -G "MinGW Makefiles"
cmake --build dllbuild
copy dllbuild\sound.dll ..
cd ..
