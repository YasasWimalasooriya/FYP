import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'blockchain_config.dart';

class BlockchainService {
  static final BlockchainService _instance = BlockchainService._internal();
  factory BlockchainService() => _instance;
  BlockchainService._internal();

  late final Web3Client _client;
  late final DeployedContract _contract;
  late final Credentials _credentials;
  late final EthereumAddress contractAddress;
  late final EthereumAddress myAddress;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    _client = Web3Client(rpcUrl, Client());
    _credentials = EthPrivateKey.fromHex(privateKey);
    myAddress = _credentials.address;
    contractAddress = EthereumAddress.fromHex(contractAddressHex);

    // 👇 Load ABI as a list (not a wrapped object)
    final abiString = await rootBundle.loadString(abiPath);
    final abi = jsonEncode(jsonDecode(abiString)); // Just parse and re-encode

    _contract = DeployedContract(
      ContractAbi.fromJson(abi, "V2GEnergySystem"),
      contractAddress,
    );

    _initialized = true;

    try {
      final tokenName = await getTokenName();
      print("✅ Token Name: $tokenName");
    } catch (e) {
      print("⚠️ Failed to fetch token name: $e");
    }
  }

  Future<List<dynamic>> callFunction(String name, List<dynamic> args) async {
    final function = _contract.function(name);
    return await _client.call(
      contract: _contract,
      function: function,
      params: args,
    );
  }

  Future<String> sendTransaction(String name, List<dynamic> args, {BigInt? value}) async {
    final function = _contract.function(name);
    return await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: args,
        value: value != null ? EtherAmount.inWei(value) : null,
      ),
      chainId: 11155111, // Sepolia
    );
  }

  Future<String> registerEVOwner({
    required String vehicleNo,
    required BigInt fullCapacity,
    required BigInt minBatteryLevel,
  }) async {
    return await sendTransaction(
      'registerEVOwner',
      [vehicleNo, fullCapacity, minBatteryLevel],
    );
  }

  Future<String> getTokenName() async {
    final result = await callFunction('name', []);
    return result.first as String;
  }

  Future<bool> isRegistered(String addressHex) async {
    final address = EthereumAddress.fromHex(addressHex);
    final result = await callFunction('isRegisteredEVOwner', [address]);
    return result[0] as bool;
  }
}