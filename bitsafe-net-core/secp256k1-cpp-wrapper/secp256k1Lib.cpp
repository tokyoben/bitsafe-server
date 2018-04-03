// secp256kLib.cpp : Defines the exported functions for the DLL application.
//


#include <iostream>
#include <assert.h>
#include <stdexcept>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "secp256k1.h"
#include "secp256k1Lib.h"

int char2int(char input)
{
	if (input >= '0' && input <= '9')
		return input - '0';
	if (input >= 'A' && input <= 'F')
		return input - 'A' + 10;
	if (input >= 'a' && input <= 'f')
		return input - 'a' + 10;
	throw std::invalid_argument("Invalid input string");
}

// This function assumes src to be a zero terminated sanitized string with
// an even number of [0-9a-f] characters, and target to be sufficiently large
void hex2bin(const char* src, unsigned char* target)
{
	while (*src && src[1])
	{
		*(target++) = char2int(*src) * 16 + char2int(src[1]);
		src += 2;
	}
}

extern "C" __attribute__((visibility("default"))) secp256k1Lib::secp256k1Lib() {
	sign = secp256k1_context_create(SECP256K1_CONTEXT_SIGN);
	vrfy = secp256k1_context_create(SECP256K1_CONTEXT_VERIFY);
}

extern "C" __attribute__((visibility("default"))) secp256k1Lib::~secp256k1Lib() {
	secp256k1_context_destroy(sign);
	secp256k1_context_destroy(vrfy);
}

extern "C" char* secp256k1Lib::Test() {


    char szSampleString[] = "Hello World";
    unsigned long ulSize = strlen(szSampleString) + sizeof(char);
    char* pszReturn = NULL;

    pszReturn = (char*)::malloc(ulSize);
    // Copy the contents of szSampleString
    // to the memory pointed to by pszReturn.
    strcpy(pszReturn, szSampleString);
    // Return pszReturn.
    return pszReturn;


}

extern "C" __attribute__((visibility("default"))) char* secp256k1Lib::Sign(char* key, char* message) {

	unsigned char bkey[36];
	unsigned char bmessage[32];
	hex2bin(key, bkey);
	hex2bin(message, bmessage);

	//get signature and in der format
	unsigned char signature[72];
	size_t sigsize;
	sigsize = sizeof(signature);

	secp256k1_ecdsa_signature sig;
	secp256k1_ecdsa_sign(sign, &sig, bmessage, bkey, NULL, NULL);
	secp256k1_ecdsa_signature_serialize_der(sign, signature, &sigsize, &sig);

	const int bufferSize = sizeof(signature);
	char converted[bufferSize*2 + 1];
	int i;

	for(i=0;i<bufferSize;i++) {
		sprintf(&converted[i*2], "%02x", signature[i]);
	}

    unsigned long ulSize = strlen(converted) + sizeof(char);
    char* pszReturn = NULL;
    pszReturn = (char*)::malloc(ulSize);
    strcpy(pszReturn, converted);

	memset( key, 0, sizeof(key) );
	memset( message, 0, sizeof(message) );
	memset( bkey, 0, sizeof(bkey) );
	memset( bmessage, 0, sizeof(bmessage) );
	memset( signature, 0, sizeof(signature) );
	memset( converted, 0, sizeof(converted) );

    return pszReturn;

}

extern "C" char* secp256k1Lib::CreatePubKey(char* key) {

	unsigned char bkey[36];
	hex2bin(key, bkey);

	//get public key in compressed format	------------------------------------------------------------------------
	unsigned char spubkey[33];
	size_t pubsize;
	pubsize = sizeof(spubkey);



	secp256k1_pubkey pubkey;
	secp256k1_ec_pubkey_create(sign, &pubkey, bkey);
	secp256k1_ec_pubkey_serialize(sign, spubkey, &pubsize, &pubkey, SECP256K1_EC_COMPRESSED);

	const int bufferSize = 33;
	char converted[bufferSize*2 + 1];
	int i;

	for(i=0;i<bufferSize;i++) {
		sprintf(&converted[i*2], "%02x", spubkey[i]);
	}

    unsigned ulSize = strlen(converted) + sizeof(char);
    char* pszReturn = NULL;
    pszReturn = (char*)::malloc(ulSize);
    strcpy(pszReturn, converted);

	memset( key, 0, sizeof(key) );
	memset( bkey, 0, sizeof(bkey) );
	memset( converted, 0, sizeof(converted) );
	memset( spubkey, 0, sizeof(spubkey) );


    return pszReturn;
	//end get public key

}

extern "C" char* secp256k1Lib::AddPrivate(char* a, char* b) {

	//add two biggies		----------------------------------------------------------------------------------------
	unsigned char IL[32];
	unsigned char Kpar[32];

	hex2bin(a, IL);
	hex2bin(b, Kpar);

	secp256k1_ec_privkey_tweak_add(vrfy, IL, Kpar);

	const int bufferSize = 32;
	char converted[bufferSize*2 + 1];
	int i;

	for(i=0;i<bufferSize;i++) {
		sprintf(&converted[i*2], "%02x", IL[i]);
	}

    unsigned long ulSize = strlen(converted) + sizeof(char);
    char* pszReturn = NULL;
    pszReturn = (char*)::malloc(ulSize);
    strcpy(pszReturn, converted);

	memset( a, 0, sizeof(a) );
	memset( b, 0, sizeof(b) );
	memset( Kpar, 0, sizeof(Kpar) );
	memset( IL, 0, sizeof(IL) );
	memset( converted, 0, sizeof(converted) );

    return pszReturn;

}

extern "C" char* secp256k1Lib::AddPublic(char* a, char* b)
{

	unsigned char tspubkey[33];

	size_t tspubsize;
	tspubsize = sizeof(tspubkey);

	unsigned char ILP[32];

	hex2bin(a, tspubkey);
	hex2bin(b, ILP);

	secp256k1_pubkey tpubkey;
	secp256k1_ec_pubkey_parse(sign, &tpubkey, tspubkey, tspubsize);
	secp256k1_ec_pubkey_tweak_add(vrfy, &tpubkey, ILP);
	secp256k1_ec_pubkey_serialize(sign, tspubkey, &tspubsize, &tpubkey, SECP256K1_EC_COMPRESSED);

	const int bufferSize = 33;
	char converted[bufferSize*2 + 1];
	int i;

	for(i=0;i<bufferSize;i++) {
		sprintf(&converted[i*2], "%02x", tspubkey[i]);
	}

    unsigned long ulSize = strlen(converted) + sizeof(char);
    char* pszReturn = NULL;
    pszReturn = (char*)::malloc(ulSize);
    strcpy(pszReturn, converted);

	memset( a, 0, sizeof(a) );
	memset( b, 0, sizeof(b) );
	memset( ILP, 0, sizeof(ILP) );
	memset( converted, 0, sizeof(converted) );

    return pszReturn;


}

extern "C" char* secp256k1Lib::Mult(char* a, char* b) {

	//add two biggies		----------------------------------------------------------------------------------------
	unsigned char IL[32];
	unsigned char Kpar[32];

	hex2bin(a, IL);
	hex2bin(b, Kpar);

	secp256k1_ec_privkey_tweak_mul(vrfy, IL, Kpar);

	const int bufferSize = 32;
	char converted[bufferSize*2 + 1];
	int i;

	for(i=0;i<bufferSize;i++) {
		sprintf(&converted[i*2], "%02x", IL[i]);
	}

    unsigned long ulSize = strlen(converted) + sizeof(char);
    char* pszReturn = NULL;
    pszReturn = (char*)::malloc(ulSize);
    strcpy(pszReturn, converted);

	memset( a, 0, sizeof(a) );
	memset( b, 0, sizeof(b) );
	memset( Kpar, 0, sizeof(Kpar) );
	memset( IL, 0, sizeof(IL) );
	memset( converted, 0, sizeof(converted) );

    return pszReturn;

}

extern "C" char* secp256k1Lib::Negate(char* a) {

	//add two biggies		----------------------------------------------------------------------------------------
	unsigned char IL[32];
	hex2bin(a, IL);

	secp256k1_ec_privkey_negate(vrfy, IL);

	const int bufferSize = 32;
	char converted[bufferSize*2 + 1];
	int i;

	for(i=0;i<bufferSize;i++) {
		sprintf(&converted[i*2], "%02x", IL[i]);
	}

    unsigned long ulSize = strlen(converted) + sizeof(char);
    char* pszReturn = NULL;
    pszReturn = (char*)::malloc(ulSize);
    strcpy(pszReturn, converted);

	memset( a, 0, sizeof(a) );
	memset( IL, 0, sizeof(IL) );
	memset( converted, 0, sizeof(converted) );

    return pszReturn;

}

// C++:
extern "C" secp256k1Lib* CreateTestClass()
{
	return new secp256k1Lib();
}

extern "C" void DisposeTestClass(
	secp256k1Lib* pObject)
{
	if (pObject != NULL)
	{
		delete pObject;
		pObject = NULL;
	}
}
