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
cp src/liblua.a src/liblua53.a
cp src/lua src/lua53
export LUA_LIB=`pwd`/src
export LUA_BIN=`pwd`/src
cd ..
cd im
export USE_LUA53=Yes
bash config_lua_module
make
cd ..
cd cd
make
bash install_dev
cd ..
cd iup
make
cd ..
