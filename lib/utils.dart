import 'package:fast_base58/fast_base58.dart';
import 'package:hex/hex.dart';
import 'package:secp256k1/secp256k1.dart';
import 'package:sha3/sha3.dart';

String getBS58AddressFromPrivateKey(String bs58PrivateKeys) {
  // TODO: support list keys
  var rawPrivateKey = Base58Decode(bs58PrivateKeys);
  var hexPrivateKey = HEX.encode(rawPrivateKey);

  var privateKey = PrivateKey.fromHex(hexPrivateKey);
  var publicKey = privateKey.publicKey;
  var k = SHA3(256, SHA3_PADDING, 256);

  k.update(rawPrivateKey);
  var hash = k.digest();
  var addr = hash.sublist(0, 2);
  var hexPub = publicKey.toCompressedHex(); // TODO: support schnorr

  addr.addAll(HEX.decode(hexPub));
  return Base58Encode(addr);
}

List<num> LStr2LNum(List<String> lstr) {
  var lnum = <num>[];
  lstr.forEach((str) {
    lnum.add(num.parse(str));
  });

  return lnum;
}
