import 'package:jsonrpc2/jsonrpc_io_client.dart';

class NgRPCClient {
  ServerProxy proxy;

  NgRPCClient(String walletRPCServerAddr) {
    proxy = ServerProxy(walletRPCServerAddr);
  }

  Future<Map> checkTx(String hash) async {
    var res;
    res = await proxy.call('getTxByHash', {'hash': hash});
    if (res is Exception) {
      throw res;
    }
    return res;
  }

  Future<String> sendTx(String hexTx) async {
    var res = await proxy.call('sendTx', {'rawTx': hexTx});
    if (res is Exception) {
      throw res;
    }
    return res;
  }

  Future<String> signTx(List<String> base58PrivateKeys, String hexTx) async {
    var res = await proxy
        .call('signTx', {'rawTx': hexTx, 'privateKeys': base58PrivateKeys});
    if (res is Exception) {
      throw res;
    }
    return res;
  }

  Future<Map> getAccountByNum(num accountNum) async {
    var res = await proxy.call('getAccountByNum', {'num': accountNum});
    if (res is Exception) {
      throw res;
    }
    return res;
  }

  Future<List> getAccountByAddr(String addr) async {
    var res = await proxy.call('getAccountByAddress', {'address': addr});
    if (res is Exception) {
      throw res;
    }
    return res;
  }

  Future<BigInt> getBalanceByNum(int n) async {
    var res = await proxy.call('getBalanceByNum', {'num': n});
    if (res is Exception) {
      throw res;
    }

    return BigInt.parse(res, radix: 10);
  }

  Future<BigInt> getBalanceByAddr(String addr) async {
    var res = await proxy.call('getBalanceByAddress', {'address': addr});
    if (res is Exception) {
      throw res;
    }

    return BigInt.parse(res, radix: 10);
  }

  Future<Map> getLatestBlock() async {
    var res = await proxy.call('getLatestBlock');
    if (res is Exception) {
      throw res;
    }
    return res;
  }

  Future<String> genTransaction(int convener, List<dynamic> participants,
      List<num> values, num fee, String extra) async {
    var params = {
      'convener': convener,
      'participants': participants,
      'values': values,
      'fee': fee,
      'extra': extra,
    };
    var res = await proxy.call('genTransaction', params);
    if (res is Exception) {
      throw res;
    }
    return res;
  }

  Future<String> genRegister(int newAccountNum, String owner) async {
    var params = {'num': newAccountNum, 'owner': owner};
    var res = await proxy.call('genRegister', params);
    if (res is Exception) {
      throw res;
    }
    return res;
  }

  Future<String> genLogout(int convener, num fee, String extra) async {
    var params = {'convener': convener, 'fee': fee, 'extra': extra};
    var res = await proxy.call('genLogout', params);
    if (res is Exception) {
      throw res;
    }
    return res;
  }

  Future<String> genAssign(int convener, num fee, String extra) async {
    var params = {'convener': convener, 'fee': fee, 'extra': extra};
    var res = await proxy.call('genAssign', params);
    if (res is Exception) {
      throw res;
    }
    return res;
  }

  Future<String> genAppend(int convener, num fee, String extra) async {
    var params = {'convener': convener, 'fee': fee, 'extra': extra};
    var res = await proxy.call('genAppend', params);
    if (res is Exception) {
      throw res;
    }
    return res;
  }
}
