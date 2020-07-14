import 'package:jsonrpc2/jsonrpc_io_client.dart';

class NgRPCClient {
  ServerProxy proxy;

  NgRPCClient(String walletRPCServerAddr) {
    proxy = ServerProxy(walletRPCServerAddr);
  }

  Future<Map> checkTx(String hash) async {
    var res = await proxy.call('getTxByHash', {'hash': hash});
    var result = proxy.checkError(res);
    return result;
  }

  Future<String> sendTx(String hexTx) async {
    var res = await proxy.call('sendTx', {'rawTx': hexTx});
    var result = proxy.checkError(res);
    return result;
  }

  Future<String> signTx(List<String> base58PrivateKeys, String hexTx) async {
    var res = await proxy
        .call('signTx', {'rawTx': hexTx, 'privateKeys': base58PrivateKeys});
    var result = proxy.checkError(res);
    return result;
  }

  Future<Map> getAccountByNum(num n) async {
    var res = await proxy.call('getAccountByNum', n);
    var result = proxy.checkError(res);
    return result;
  }

  Future<List> getAccountsByAddress(String addr) async {
    var res = await proxy.call('getAccountsByAddress', {'address': addr});
    var result = proxy.checkError(res);
    return result;
  }

  Future<Map> getBalanceByNum(int n) async {
    var res = await proxy.call('getBalance', n);
    var result = proxy.checkError(res);
    return result;
  }

  Future<Map> getLatestBlock() async {
    var res = await proxy.call('getLatestBlock');
    var result = proxy.checkError(res);
    return result;
  }

  Future<String> genTransaction(int convener, List<dynamic> participants,
      List<num> values, num fee, String extra) async {
    var params = {
      'convener': convener,
      'participants': 'participants',
      'values': values,
      'fee': fee,
      'extra': extra,
    };
    var res = await proxy.call('genTransaction', params);
    var result = proxy.checkError(res);
    return result;
  }

  Future<String> genRegister(int newAccountNum, String owner) async {
    var params = {'num': newAccountNum, 'owner': owner};
    var res = await proxy.call('genRegister', params);
    var result = proxy.checkError(res);
    return result;
  }

  Future<String> genLogout(int convener, num fee, String extra) async {
    var params = {'convener': convener, 'fee': fee, 'extra': extra};
    var res = await proxy.call('genLogout', params);
    var result = proxy.checkError(res);
    return result;
  }

  Future<String> genAssign(int convener, num fee, String extra) async {
    var params = {'convener': convener, 'fee': fee, 'extra': extra};
    var res = await proxy.call('genAssign', params);
    var result = proxy.checkError(res);
    return result;
  }

  Future<String> genAppend(int convener, num fee, String extra) async {
    var params = {'convener': convener, 'fee': fee, 'extra': extra};
    var res = await proxy.call('genAppend', params);
    var result = proxy.checkError(res);
    return result;
  }
}
