import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:ngwallet/commands.dart';
import 'package:ngwallet/utils.dart';

class checkTxCMD extends Command {
  @override
  final name = 'checkTx';

  @override
  final description = 'Check the status of one Tx.';

  checkTxCMD() {
    argParser.addOption('hash');
  }

  @override
  void run() {
    var hash = argResults['hash'];

    checkTx(hash);
  }
}

class getAddressCMD extends Command {
  @override
  final name = 'getAddress';

  @override
  final description = 'Get the address for receiving NGIN.';

  getAddressCMD() {
    argParser.addOption('privateKey');
  }

  @override
  void run() {
    var privateKey = checkEmpty(argResults['privateKey'], 'privateKey');
    getAddress(privateKey);
  }
}

class getBalanceByNumCMD extends Command {
  @override
  final name = 'getBalanceByNum';

  @override
  final description = 'Get the balance of an Account or Address.';

  getBalanceByNumCMD() {
    argParser.addOption('num');
  }

  @override
  void run() {
    var accountNum = int.parse(argResults['num']);

    getBalanceByNum(accountNum);
  }
}

class newTransactionTxCMD extends Command {
  @override
  final name = 'newTransactionTx';

  @override
  final description = 'Generate and sent a new Transaction Tx.';

  newTransactionTxCMD() {
    // [argParser] is automatically created by the parent class.
    argParser.addOption('privateKey');
    argParser.addOption('convener');
    argParser.addMultiOption('participants');
    argParser.addMultiOption('values');
    argParser.addOption('fee');
    argParser.addOption('extra');
  }

  @override
  void run() {
    var privateKey = checkEmpty(argResults['privateKey'], 'privateKey');
    var convener = int.parse(checkEmpty(argResults['convener'], 'convener'));
    var participants = LStr2LInt(argResults['participants']);
    var values = LStr2LNum(argResults['values']);
    var fee = num.parse(checkEmpty(argResults['fee'], 'fee'));
    var extra = argResults['extra'];

    newTransactionTx(privateKey, convener, participants, values, fee, extra);
  }
}

class newRegisterTxCMD extends Command {
  @override
  final name = 'newRegisterTx';

  @override
  final description = 'Generate and sent a new Register Tx.';

  newRegisterTxCMD() {
    argParser.addOption('privateKey');

    argParser.addOption('registerAccountNum');
  }

  @override
  void run() {
    var privateKey = checkEmpty(argResults['privateKey'], 'privateKey');
    var newAccountNum = int.parse(
        checkEmpty(argResults['registerAccountNum'], 'registerAccountNum'));

    newRegisterTx(privateKey, newAccountNum);
  }
}

class newLogoutTxCMD extends Command {
  @override
  final name = 'newLogoutTx';

  @override
  final description = 'Generate and sent a new Logout Tx.';

  newLogoutTxCMD() {
    // [argParser] is automatically created by the parent class.
    argParser.addOption('privateKey');
    argParser.addOption('fee');
    argParser.addOption('extra');

    argParser.addOption('logoutAccountNum');
  }

  @override
  void run() {
    var privateKey = checkEmpty(argResults['privateKey'], 'privateKey');
    var fee = checkEmpty(argResults['fee'], 'fee');
    var extra = argResults['extra'];

    var delAccountNum =
        checkEmpty(argResults['logoutAccountNum'], 'logoutAccountNum');

    newLogoutTx(privateKey, delAccountNum, fee, extra);
  }
}

class newAssignTxCMD extends Command {
  @override
  final name = 'newAssignTx';

  @override
  final description = 'Generate and sent a new Assign Tx.';

  newAssignTxCMD() {
    argParser.addOption('privateKey');
    argParser.addOption('convener');
    argParser.addOption('fee');
    argParser.addOption('extra');
  }

  @override
  void run() {
    var privateKey = checkEmpty(argResults['privateKey'], 'privateKey');
    var convener = int.parse(checkEmpty(argResults['convener'], 'convener'));
    var fee = num.parse(checkEmpty(argResults['fee'], 'fee'));
    var extra = argResults['extra'];

    newAssignTx(privateKey, convener, fee, extra);
  }
}

class newAppendTxCMD extends Command {
  @override
  final name = 'newAppendTx';

  @override
  final description = 'Generate and sent a new Append Tx.';

  newAppendTxCMD() {
    argParser.addOption('privateKey');
    argParser.addOption('convener');
    argParser.addOption('fee');
    argParser.addOption('extra');
  }

  @override
  void run() {
    var privateKey = checkEmpty(argResults['privateKey'], 'privateKey');
    var convener = int.parse(checkEmpty(argResults['convener'], 'convener'));
    var fee = num.parse(checkEmpty(argResults['fee'], 'fee'));
    var extra = argResults['extra'];

    newAppendTx(privateKey, convener, fee, extra);
  }
}

Future main(List<String> args) async {
  /* config commands */
  var runner = CommandRunner('ngwallet', 'wallet for NGIN')
    ..addCommand(checkTxCMD())
    ..addCommand(getAddressCMD())
    ..addCommand(getBalanceByNumCMD())
    ..addCommand(newRegisterTxCMD())
    ..addCommand(newLogoutTxCMD())
    ..addCommand(newTransactionTxCMD())
    ..addCommand(newAssignTxCMD())
    ..addCommand(newAppendTxCMD());

  await runner.run(args).catchError((error) {
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
