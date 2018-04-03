Build bitcoin/secp256k1
Copy library to libs directory somewhere
Compile using g++ as below
Mac
g++ libs/libsecp256k1.a -shared  -dynamiclib -o secp256k1Lib.dylib secp256k1Lib.cpp
Linux
g++ -v -fPIC -Llibs -shared -Wl,--no-undefined -o secp256k1Lib.o secp256k1Lib.cpp -lsecp256k1
