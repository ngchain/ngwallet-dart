# ngwallet-dart

`ngwallet (dart version)` is an ONLINE simple cli wallet to NGIN network.

So before running ngwallet, it is required to host or find a living rpc server on ngcore daemon.

## Usage

You can run the wallet like running javascript

```bash
dart ./bin/ngwallet.dart --help
```

or directlly download and run the [precompiled binary](https://github.com/ngchain/ngwallet-dart/releases)

```bash
./ngwallet --help
```

## Examples

### new

```bash
./ngwallet new # create a new wallet on the current folder, without password
./ngwallet new 123456 # password is 123456
./ngwallet new /path/to/ngwallet.key 123456 # create a new wallet on /path/to/ngwallet.key with 123456 password
```

### address

```bash
./ngwallet address # get the address of local wallet
./ngwallet address 10010 # get the owner address of account 10010
```

### account

```bash
./ngwallet account # get the account which is binded with wallet address

```

### balance

```bash
./ngwallet balance # get the balance of local address
./ngwallet balance HJfu6vfoSiNa5K3zqfzM4yTiPtEDf4cwR9KKZq8RSEMi9KXb # get the balance of address HJfu...
./ngwallet balance 10010 # get the balance of account 10010
```

### register

```bash
./ngwallet register 10010 # register account 10010
```

### transact

```bash
./ngwallet transact --participants 10011 --values 1.5 # send 1.5 NG to 10011
./ngwallet transact --participants 10011,10012 --values 1.5,2.33 # send 1.5 NG to 10011 and 2.33 to 10012
```

## logout

```bash
./ngwallet logout # logout address' account
```

## check

```bash
./ngwallet check 1a2f5ca793198a0069d57c3943d0c9ca705058e59e5685d1019f2b84d3463d6e # check tx 1a2f...'s status, in pool or packed in block
```
