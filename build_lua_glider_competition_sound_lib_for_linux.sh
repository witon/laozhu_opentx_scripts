git clone https://github.com/witon/lua_glider_competition_sound_lib.git
cd lua_glider_competition_sound_lib
cmake . -B build
cd build
cmake --build .
cp sound.so ../..
