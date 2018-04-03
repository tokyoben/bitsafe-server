extern "C" {
class __attribute__((visibility("default"))) secp256k1Lib {

public:
	secp256k1Lib();
	virtual ~secp256k1Lib();
	char* Sign(char* key, char* message);
	char* CreatePubKey(char* key);
	char* AddPublic(char* a, char* b);
	char* AddPrivate(char* a, char* b);
	char* Negate(char* a);
	char* Mult(char* a, char* b);
	char* Test();
private:
	int val;
	secp256k1_context *sign;
	secp256k1_context *vrfy;

};
}
