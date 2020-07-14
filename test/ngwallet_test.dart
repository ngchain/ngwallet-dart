import 'package:ngwallet/utils.dart';
import 'package:test/test.dart';

void main() {
  expect(
      getBS58AddressFromPrivateKey(
          'AYBxTPyyPvAXxKGBH2mZSyKDwCFVwM1zD4JYJZaVF4SK'),
      '4oLzQmCDMb5sHnuHKFVxrLyfvMJaQ2y3YYHeKX5rs7j3fvH3');
}
