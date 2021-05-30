cd ../../
git clone https://github.com/google/googletest.git
cd googletest
cmake . -B build -G "MinGW Makefiles"
cd build
cmake --build .
cmake --install .
