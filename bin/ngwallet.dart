import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:fast_base58/fast_base58.dart';
import 'package:hex/hex.dart';
import 'package:ngwallet/defaults.dart';
import 'package:ngwallet/keytools.dart';
import 'package:ngwallet/rpc_client.dart';
import 'package:ngwallet/utils.dart';
import 'package:path/path.dart' as path;
import 'package:secp256k1/secp256k1.dart';

class JsonRpcCMD extends Command {
  JsonRpcCMD() {
    var home = '';
    var envVars = Platform.environment;
    if (Platform.isMacOS) {
      home = envVars['HOME'];
    } else if (Platform.isLinux) {
      home = envVars['HOME'];
    } else if (Platform.isWindows) {
      home = envVars['UserProfile'];
    }

    argParser.addOption('daemon',
        abbr: 'd',
        defaultsTo: 'http://127.0.0.1:52521',
        help: 'the URL of ngcore rpc');
    argParser.addOption('keyfilePath',
        abbr: 'k',
        defaultsTo: path.join(home, '.ngkeys', 'ngcore.key'),
        help: 'the Key file used in sending');
    argParser.addOption('keyfilePassword',
        abbr: 'p', defaultsTo: '', help: 'the password of Key file');
  }

  @override
  String get description => '';

  @override
  String get name => '';

  String get daemon {
    var daemon = checkEmpty(argResults['daemon'], 'daemon');
    return daemon;
  }

  Future<String> get privateKey async {
    try {
      return await decryptKeyFile(
          argResults['keyfilePath'], argResults['keyfilePassword']);
    } on FileSystemException {
      return await decryptKeyFile('ngcore.key', argResults['keyfilePassword']);
    }
  }

  NgRPCClient get client {
    return NgRPCClient(daemon);
  }

  Future<int> get convener async {
    var addr = getBS58AddressFromPrivateKey(await privateKey);
    var acc = client.getAccountByAddr(addr);
    if ((await acc) == null) {
      throw ('local address $addr doesn\'t have account, please register if you wanna sending coins');
    }
    return (await acc)['num'];
  }
}

class CheckTxCMD extends JsonRpcCMD {
  @override
  final name = 'check';

  @override
  final description = 'Check the status of one Tx.';

  @override
  final usageFooter = '''argument 0: <TxHash>''';

  @override
  Future<void> run() async {
    if (argResults.arguments.length != 1) {
      throw ArgumentError;
    }

    var txHash = checkEmpty(argResults.arguments[0], 'TxHash');

    var result = await client.checkTx(txHash);
    if (result['tx'] == null) {
      print('tx ' + txHash + ' failed');
    }

    if (result['onChain'] == true) {
      print('tx ' + txHash + ' is successfully handled on the chain');
    } else {
      print('tx ' + txHash + ' is not hanlded by chain yet, please wait');
    }
  }
}

class NewWalletCMD extends JsonRpcCMD {
  @override
  final name = 'new';

  @override
  final description = 'Create one new wallet file for receiving NG.';

  @override
  Future<void> run() async {
    var pk = PrivateKey.generate();
    switch (argResults.arguments.length) {
      case 0:
        await encryptToKeyFile(pk, 'ngcore.key', '');
        var rawPK = HEX.decode(pk.toHex());
        var newAddr = getBS58AddressFromPrivateKey(Base58Encode(rawPK));
        print('new address is $newAddr');
        break;
      case 1:
        await encryptToKeyFile(pk, 'ngcore.key', argResults.arguments[0]);
        var rawPK = HEX.decode(pk.toHex());
        var newAddr = getBS58AddressFromPrivateKey(Base58Encode(rawPK));
        print('new address is $newAddr');
        break;

      case 2:
        await encryptToKeyFile(
            pk, argResults.arguments[0], argResults.arguments[1]);
        var rawPK = HEX.decode(pk.toHex());
        var newAddr = getBS58AddressFromPrivateKey(Base58Encode(rawPK));
        print('new address is $newAddr');
        break;
      default:
        throw ArgumentError;
    }
  }
}

class GetAddressCMD extends JsonRpcCMD {
  @override
  final name = 'address';

  @override
  final description =
      'Get the local address for receiving NG, or search the account\'s owner.';

  @override
  Future<void> run() async {
    switch (argResults.arguments.length) {
      case 0:
        print(getBS58AddressFromPrivateKey(await privateKey));
        break;
      case 1:
        var accountNum = int.parse(argResults.arguments[0]);
        var res = await client.getAccountByNum(accountNum);

        print(res['owner']);
        break;
      default:
        throw ArgumentError;
    }
  }
}

class GetAccountCMD extends JsonRpcCMD {
  @override
  final name = 'account';

  @override
  final description =
      'Show local account for sending NG, or search the account belonging to one address.';

  @override
  Future<void> run() async {
    switch (argResults.arguments.length) {
      case 0:
        print(await convener);
        break;
      case 1:
        var account = await client.getAccountByAddr(argResults.arguments[0]);
        print(account);
        break;
      default:
        throw ArgumentError;
    }
  }
}

class GetBalanceCMD extends JsonRpcCMD {
  @override
  final name = 'balance';

  @override
  final description = 'Get the balance of an AccountNum or Address.';

  @override
  final usageFooter = '''argument 0: <AccountNum or Address>''';

  @override
  Future<void> run() async {
    BigInt balance;
    switch (argResults.arguments.length) {
      case 0:
        var address = getBS58AddressFromPrivateKey(await privateKey);
        balance = await client.getBalanceByAddr(address);
        break;
      case 1:
        try {
          var accountNum = int.parse(argResults.arguments[0]);
          balance = await client.getBalanceByNum(accountNum);
        } on FormatException {
          var address = argResults.arguments[0];
          balance = await client.getBalanceByAddr(address);
        }
        break;
      default:
        throw ArgumentError;
    }

    var strBal = (balance / oneNG).toString();
    print('Balance: $strBal NG');
  }
}

class SendTransactionTxCMD extends JsonRpcCMD {
  @override
  final name = 'transact';

  @override
  final description = 'Generate and send a new Transact Tx.';

  SendTransactionTxCMD() {
    // [argParser] is automatically created by the parent class.
    argParser.addMultiOption('participants', defaultsTo: []);
    argParser.addMultiOption('values', defaultsTo: []);
    argParser.addOption('fee', defaultsTo: '0.0');
    argParser.addOption('extra', defaultsTo: '');
  }

  @override
  Future<void> run() async {
    var participants = argResults['participants'];
    var values = LStr2LNum(argResults['values']);
    var fee = num.parse(checkEmpty(argResults['fee'], 'fee'));
    var extra = argResults['extra'];

    var unsignedTx = await client.genTransaction(
        await convener, participants, values, fee, extra);
    var signedTx = await client.signTx([await privateKey], unsignedTx);
    print('signed raw Tx is ' + await signedTx);
    var hash = await client.sendTx(signedTx);
    print('tx ' + await hash + ' has been sent');
  }
}

class SendRegisterTxCMD extends JsonRpcCMD {
  @override
  final name = 'register';

  @override
  final description = 'Generate and send a new Register Tx.';

  @override
  final usageFooter = '''argument 0: <RegisterAccountNum>''';

  @override
  void run() async {
    if (argResults.arguments.length != 1) {
      throw ArgumentError;
    }

    var newAccountNum =
        int.parse(checkEmpty(argResults.arguments[0], 'registerAccountNum'));

    var base58Address = getBS58AddressFromPrivateKey(await privateKey);

    var unsignedTx = await client.genRegister(newAccountNum, base58Address);
    var signedTx = await client.signTx([await privateKey], unsignedTx);
    print('signed raw Tx is ' + await signedTx);
    var hash = await client.sendTx(signedTx);
    print('tx ' + await hash + ' has been sent');
  }
}

class SendLogoutTxCMD extends JsonRpcCMD {
  @override
  final name = 'logout';

  @override
  final description = 'Generate and send a new Logout Tx.';

  SendLogoutTxCMD() {
    // [argParser] is automatically created by the parent class
    argParser.addOption('fee');
    argParser.addOption('extra');
  }

  @override
  final usageFooter = '''argument 0: <LogoutAccountNum>''';

  @override
  void run() async {
    var fee = argResults['fee'];
    var extra = argResults['extra'];

    var logoutAccountNum = await convener;

    var unsignedTx = await client.genLogout(logoutAccountNum, fee, extra);
    var signedTx = await client.signTx([await privateKey], unsignedTx);
    print('signed raw Tx is ' + await signedTx);
    var hash = await client.sendTx(signedTx);
    print('tx ' + await hash + ' has been sent');
  }
}

class SendAssignTxCMD extends JsonRpcCMD {
  @override
  final name = 'assign';

  @override
  final description = 'Generate and send a new Assign Tx.';

  SendAssignTxCMD() {
    argParser.addOption('fee');
    argParser.addOption('extra');
  }

  @override
  void run() async {
    if (argResults.arguments.length != 1) {
      throw ArgumentError;
    }
    var fee = num.parse(argResults['fee']);
    var extra = argResults['extra'];

    var unsignedTx = await client.genAssign(await convener, fee, extra);
    var signedTx = await client.signTx([await privateKey], unsignedTx);
    print('signed raw Tx is ' + await signedTx);
    var hash = await client.sendTx(signedTx);
    print('Tx ' + await hash + ' has been sent');
  }
}

class SendAppendTxCMD extends JsonRpcCMD {
  @override
  final name = 'append';

  @override
  final description = 'Generate and send a new Append Tx.';

  SendAppendTxCMD() {
    argParser.addOption('fee');
    argParser.addOption('extra');
  }

  @override
  void run() async {
    if (argResults.arguments.length != 1) {
      throw ArgumentError;
    }

    var fee = num.parse(checkEmpty(argResults['fee'], 'fee'));
    var extra = argResults['extra'];

    var unsignedTx = await client.genAssign(await convener, fee, extra);
    var signedTx = await client.signTx([await privateKey], unsignedTx);
    print('signed raw Tx is ' + await signedTx);
    var hash = await client.sendTx(signedTx);
    print('tx ' + await hash + ' has been sent');

    exit(0);
  }
}

Future main(List<String> args) async {
  /* config commands */
  var runner = CommandRunner('ngwallet', 'wallet for NGIN')
    ..addCommand(CheckTxCMD())
    ..addCommand(GetAddressCMD())
    ..addCommand(GetBalanceCMD())
    ..addCommand(NewWalletCMD())
    ..addCommand(GetAccountCMD())
    ..addCommand(SendRegisterTxCMD())
    ..addCommand(SendLogoutTxCMD())
    ..addCommand(SendTransactionTxCMD())
    ..addCommand(SendAssignTxCMD())
    ..addCommand(SendAppendTxCMD());

  await runner.run(args).then((_) => {exit(0)}).catchError((error) {
    if (error is! UsageException) throw error;
    print(error);
    exit(64); // Exit code 64 indicates a usage error.
  });
}

dynamic checkEmpty(dynamic any, String field) {
  if (any == null) {
    throw UsageException(field + ' is required', '');
  }

  return any;
}
