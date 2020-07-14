import 'rpc_client.dart';
import 'utils.dart';

Future<void> getAddress(String privateKey) async {
  print(getBS58AddressFromPrivateKey(privateKey));
}

Future<void> getBalanceByNum(int accountNum) async {
  var client = NgRPCClient('http://127.0.0.1:52521'); //TODO: allow override me

  var balance = await client.getBalanceByNum(accountNum);
  print(balance);
}

Future checkTx(String hash) async {
  var client = NgRPCClient('http://127.0.0.1:52521'); //TODO: allow override me

  var result = await client.checkTx(hash);
  if (result['tx'] == null) {
    print('tx ' + hash + ' failed');
  }

  if (result['onChain'] == true) {
    print('tx ' + hash + ' is successfully handled on the chain');
  } else {
    print('tx ' + hash + ' is not hanlded by chain yet, please wait');
  }
}

Future<void> newTransactionTx(String privateKey, int convener,
    List participants, List values, num fee, String extra) async {
  var client = NgRPCClient('http://127.0.0.1:52521'); //TODO: allow override me

  var unsignedTx =
      await client.genTransaction(convener, participants, values, fee, extra);
  var signedTx = await client.signTx([privateKey], unsignedTx);
  print('signed raw Tx is ' + await signedTx);
  var hash = await client.sendTx(signedTx);
  print('tx ' + await hash + ' has been sent');
}

Future<void> newRegisterTx(String privateKey, int newAccountNum) async {
  var client = NgRPCClient('http://127.0.0.1:52521'); //TODO: allow override me

  var base58Address = getBS58AddressFromPrivateKey(privateKey);

  var unsignedTx = await client.genRegister(newAccountNum, base58Address);
  var signedTx = await client.signTx([privateKey], unsignedTx);
  print('signed raw Tx is ' + await signedTx);
  var hash = await client.sendTx(signedTx);
  print('tx ' + await hash + ' has been sent');
}

Future<void> newLogoutTx(
    String privateKey, int logoutAccountNum, num fee, String extra) async {
  var client = NgRPCClient('http://127.0.0.1:52521'); //TODO: allow override me

  var unsignedTx = await client.genLogout(logoutAccountNum, fee, extra);
  var signedTx = await client.signTx([privateKey], unsignedTx);
  print('signed raw Tx is ' + await signedTx);
  var hash = await client.sendTx(signedTx);
  print('tx ' + await hash + ' has been sent');
}

Future<void> newAssignTx(
    String privateKey, int convener, num fee, String extra) async {
  var client = NgRPCClient('http://127.0.0.1:52521'); //TODO: allow override me

  var unsignedTx = await client.genAssign(convener, fee, extra);
  var signedTx = await client.signTx([privateKey], unsignedTx);
  print('signed raw Tx is ' + await signedTx);
  var hash = await client.sendTx(signedTx);
  print('Tx ' + await hash + ' has been sent');
}

Future<void> newAppendTx(
    String privateKey, int convener, num fee, String extra) async {
  var client = NgRPCClient('http://127.0.0.1:52521'); //TODO: allow override me

  var unsignedTx = await client.genAssign(convener, fee, extra);
  var signedTx = await client.signTx([privateKey], unsignedTx);
  print('signed raw Tx is ' + await signedTx);
  var hash = await client.sendTx(signedTx);
  print('tx ' + await hash + ' has been sent');
}
