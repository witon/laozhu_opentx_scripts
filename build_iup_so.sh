cd third_part
cd iup
cd pdflib7
make
cd ..
cd ftgl
make
cd ..
cd lua53
make linux
export LUA_LIB=`pwd`/src
cd ..
cd im
export USE_LUA53=Yes
./config_lua_module
make
cd ..
cd cd
make
./install_dev
cd ..
cd iup
make
cd ..
