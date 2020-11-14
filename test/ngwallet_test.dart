import 'package:ngwallet/keytools.dart';
import 'package:ngwallet/utils.dart';
import 'package:test/test.dart';

void main() {
  test('addr', () {
    expect(
        getBS58AddressFromPrivateKey(
            'AYBxTPyyPvAXxKGBH2mZSyKDwCFVwM1zD4JYJZaVF4SK'),
        '4oLzQmCDMb5sHnuHKFVxrLyfvMJaQ2y3YYHeKX5rs7j3fvH3');
  });

  // test('addr', () async {
  //   expect(await decryptKeyFile('C:\\Users\\c\\.ngkeys\\ngcore.key', ''),
  //       '2w31hPyqG5kVyg7DmFJR2VgR69HeX8fQbQuyX65XTUyp');
  // });
}
