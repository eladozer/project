import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/pointycastle.dart';

AsymmetricKeyPair<PublicKey, PrivateKey> getKeys(int size) {
  if (size < 1024) size = 1024;
  var rng = SecureRandom('AES/CTR/AUTO-SEED-PRNG');
  var keyGen = RSAKeyGenerator()
    ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), size, 64), rng));
  return keyGen.generateKeyPair();
}

Uint8List encrypt(PublicKey pubKey, String msg) {
  var msgBytes = utf8.encode(msg);
  Uint8List list = Uint8List.fromList(msgBytes);
  var encryptor = OAEPEncoding(RSAEngine())
    ..init(true, PublicKeyParameter<RSAPublicKey>(pubKey));
  var encrypted = encryptor.process(list);
  return Uint8List.fromList(encrypted);
}

String decrypt(PrivateKey priKey, Uint8List encrypted) {
  var decryptor = OAEPEncoding(RSAEngine())
    ..init(false, PrivateKeyParameter<RSAPrivateKey>(priKey));
  var decrypted = decryptor.process(encrypted);
  return utf8.decode(decrypted);
}

void main() {
  var keySize = 128;
  var pair = getKeys(keySize);
  var pubKey = pair.publicKey;
  var priKey = pair.privateKey;
  var msg = 'Hello World!';
  var encrypted = encrypt(pubKey, msg);
  var decrypted = decrypt(priKey, encrypted);
  print('Encrypted: ${base64.encode(encrypted)}');
  print('Decrypted: $decrypted');
}
