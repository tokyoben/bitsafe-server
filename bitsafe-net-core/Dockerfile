#the .net target is debian so build dependencies using this
FROM debian:jessie AS secp256k1-build

#install build tools etc.
RUN apt-get update && apt-get install -y build-essential autoconf libtool gcc wget git libstdc++6
#get the lib
RUN git clone https://github.com/bitcoin-core/secp256k1.git
#build it
WORKDIR /secp256k1
RUN ls
RUN ./autogen.sh
RUN ./configure
RUN make 
RUN make install

#copy over the c++ wrapper
WORKDIR /secp256k1-cpp-wrapper
COPY secp256k1-cpp-wrapper/* ./

RUN mkdir /secp256k1-cpp-wrapper/libs
#copy over the secp256k1 libs for linking
RUN cp /secp256k1/.libs/* libs/
#build the wrapper
RUN g++ -v -fPIC -Llibs -shared -Wl,--no-undefined -o secp256k1Lib.o secp256k1Lib.cpp -lsecp256k1

#now get the build environment ofr the .net project
FROM microsoft/aspnetcore-build:1.1.1 AS build-env
WORKDIR /app
# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM microsoft/aspnetcore:1.1.1
WORKDIR /app
COPY --from=build-env /app/out .
COPY --from=secp256k1-build /secp256k1-cpp-wrapper/secp256k1Lib.o .
COPY --from=secp256k1-build /secp256k1-cpp-wrapper/libs/libsecp256k1.so.0 .
#set the lib path so the secp256k1 wrapper can find secp256k1
ENV LD_LIBRARY_PATH /app

ENTRYPOINT ["dotnet", "bitsafe-net-core.dll"]

