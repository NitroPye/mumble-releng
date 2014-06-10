#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://www.openssl.org/source/openssl-1.0.0m.tar.gz"
expect_sha1 "openssl-1.0.0m.tar.gz" "039041fd00f45a0f485ca74f85209b4101a43a0f"
expect_sha256 "openssl-1.0.0m.tar.gz" "224dbbfaee3ad7337665e24eab516c67446d5081379a40b2f623cf7801e672de"

tar -zxf openssl-1.0.0m.tar.gz

rm -rf openssl-1.0.0m-ppc
cp -R openssl-1.0.0m openssl-1.0.0m-ppc
cd openssl-1.0.0m-ppc
./Configure darwin-ppc-cc no-shared --prefix=${MUMBLE_PREFIX} --openssldir=${MUMBLE_PREFIX}/openssl
make
make install

cp ${MUMBLE_PREFIX}/lib/libcrypto.a ${MUMBLE_PREFIX}/lib/libcrypto-ppc.a
cp ${MUMBLE_PREFIX}/lib/libssl.a ${MUMBLE_PREFIX}/lib/libssl-ppc.a
cp ${MUMBLE_PREFIX}/include/openssl/opensslconf.h ${MUMBLE_PREFIX}/include/openssl/opensslconf-ppc.h

cd ..
rm -rf openssl-1.0.0m-i386
cp -R openssl-1.0.0m openssl-1.0.0m-i386
cd openssl-1.0.0m-i386
./Configure darwin-i386-cc no-shared --prefix=${MUMBLE_PREFIX} --openssldir=${MUMBLE_PREFIX}/openssl
make
make install

cp ${MUMBLE_PREFIX}/lib/libcrypto.a ${MUMBLE_PREFIX}/lib/libcrypto-i386.a
cp ${MUMBLE_PREFIX}/lib/libssl.a ${MUMBLE_PREFIX}/lib/libssl-i386.a
cp ${MUMBLE_PREFIX}/include/openssl/opensslconf.h ${MUMBLE_PREFIX}/include/openssl/opensslconf-i386.h

cd ${MUMBLE_PREFIX}/lib/
lipo -create -arch ppc libcrypto-ppc.a -arch i386 libcrypto-i386.a -output libcrypto.a
lipo -create -arch ppc libssl-ppc.a -arch i386 libssl-i386.a -output libssl.a
rm -rf libcrypto-ppc.a libcrypto-i386.a
rm -rf libssl-ppc.a libssl-i386.a

cd ../include/openssl
printf "// Automatically generated by the Mumble osx-universal build environment.\n" > opensslconf.h
printf "#if defined(i386)\n" >> opensslconf.h
printf "# include \"opensslconf-i386.h\"\n" >> opensslconf.h
printf "#elif defined(__ppc__)\n" >> opensslconf.h
printf "# include \"opensslconf-ppc.h\"\n" >> opensslconf.h
printf "#else\n" >> opensslconf.h
printf "# error Unable to determine target architecture\n" >> opensslconf.h
printf "#endif\n" >> opensslconf.h