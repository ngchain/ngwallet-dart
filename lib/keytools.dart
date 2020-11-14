import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart' as crypto;
import 'package:fast_base58/fast_base58.dart';
import 'package:hex/hex.dart';
import 'package:sha3/sha3.dart';
import 'package:secp256k1/secp256k1.dart' as secp256k1;

const gcmStandardNonceSize = 12;

Future<String> decryptKeyFile(String keyPath, String passwd) async {
  var f = File(keyPath);
  var raw = await f.readAsBytes();

  var key = SHA3(256, SHA3_PADDING, 256).update(utf8.encode(passwd)).digest();

  var privateKey = await aes256gcmDecrypt(raw, key);

  return Base58Encode(privateKey);
}

Future<void> encryptToKeyFile(
    secp256k1.PrivateKey priv, String keyPath, String passwd) async {
  var key = SHA3(256, SHA3_PADDING, 256).update(utf8.encode(passwd)).digest();

  var f = File(keyPath);

  var fileContent = await aes256gcmEncrypt(HEX.decode(priv.toHex()), key);
  await f.writeAsBytes(fileContent);
}

Future<List<int>> aes256gcmDecrypt(List<int> raw, List<int> key) async {
  const cipher = crypto.aesGcm;
  var secretKey = crypto.SecretKey(key);
  var nonce = crypto.Nonce(raw.sublist(0, gcmStandardNonceSize));
  return await cipher.decrypt(
    raw.sublist(gcmStandardNonceSize),
    secretKey: secretKey,
    nonce: nonce,
  );
}

Future<List<int>> aes256gcmEncrypt(List<int> raw, List<int> key) async {
  const cipher = crypto.aesGcm;
  var secretKey = crypto.SecretKey(key);
  var nonce = cipher.newNonce();
  var encrypted = await cipher.encrypt(
    raw.sublist(gcmStandardNonceSize),
    secretKey: secretKey,
    nonce: nonce,
  );

  return [...nonce.bytes, ...encrypted];
}
