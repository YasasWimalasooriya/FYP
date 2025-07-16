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
  late final EthereumAddress operatorAddress;

  bool _initialized = false;

  Future<bool> init() async {
    print("🔧 Blockchain init started");
    try {
      _client = Web3Client(rpcUrl, Client());
      _credentials = EthPrivateKey.fromHex(privateKey);
      operatorAddress = await _credentials.extractAddress();
      contractAddress = EthereumAddress.fromHex(contractAddressHex);

      print("📦 Loading ABI...");
      final abiString = await rootBundle.loadString(abiPath);
      final abi = jsonEncode(jsonDecode(abiString));

      _contract = DeployedContract(
        ContractAbi.fromJson(abi, "V2GEnergySystem"),
        contractAddress,
      );

      final name = await getTokenName();
      _initialized = true;
      print("✅ Contract loaded. Token name: $name");
    } catch (e, st) {
      print("❌ Blockchain init error: $e");
      print("📜 Stacktrace: $st");
      _initialized = false;
    }

    return _initialized;
  }

  // Future<List<dynamic>> callFunction(String name, List<dynamic> args) async {
  //   try {
  //     print("🔍 Trying to get function: $name from contract");
  //     final function = _contract.function(name);
  //     print("📞 Calling function $name with params: $args");
  //     final result = await _client.call(
  //       contract: _contract,
  //       function: function,
  //       params: args,
  //     );
  //     print("✅ Result from $name: $result");
  //     return result;
  //   } catch (e, st) {
  //     print("❌ callFunction error for $name: $e");
  //     print("📜 Stacktrace: $st");
  //     rethrow; // <-- IMPORTANT: don’t silently fail
  //   }
  // }
  Future<List<dynamic>> callFunction(String name, List<dynamic> args) async {
    try {
      print("🔍 Trying to get function: $name from contract");
      final function = _contract.function(name);
      print("📞 Calling function $name with params: $args");
      final result = await _client.call(
        contract: _contract,
        function: function,
        params: args,
      );
      print("✅ Result from $name: $result");
      return result;
    } catch (e, st) {
      print("❌ callFunction error for $name: $e");
      print("📜 Stacktrace: $st");
      rethrow; // <-- IMPORTANT: don’t silently fail
    }
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
      chainId: 11155111, // Sepolia chain ID
    );
  }

  Future<String> registerEVOwner({
    required String walletAddress,
    required BigInt maxDischargeCapacity,
    required BigInt minBatteryLevel,
  }) async {
    final EthereumAddress evAddress = EthereumAddress.fromHex(walletAddress);
    return await sendTransaction(
      'registerEVOwner',
      [evAddress, maxDischargeCapacity, minBatteryLevel],
    );
  }

  Future<String> mintAdditionalTokens(BigInt amount) async {
    return await sendTransaction('mintAdditionalTokens', [amount]);
  }

  Future<String> updatePricing({
    required BigInt offPeakPrice,
    required BigInt peakPrice,
    required BigInt dischargeRate,
  }) async {
    return await sendTransaction(
      'updatePricing',
      [offPeakPrice, peakPrice, dischargeRate],
    );
  }

  Future<String> getTokenName() async {
    final result = await callFunction('name', []);
    print(result.toString());
    return result.first as String;
  }

  Future<bool> isRegistered(String addressHex) async {
    final address = EthereumAddress.fromHex(addressHex);
    final result = await callFunction('isRegisteredEVOwner', [address]);
    return result[0] as bool;
  }

  /// Purchase energy tokens (charging)
  Future<String> purchaseEnergyTokens({
    required BigInt energyAmountKWh,
    required bool isPeakHours,
  }) async {
    // Call getCurrentPricing() which returns a struct tuple inside a list
    final result = await callFunction("getCurrentPricing", []);
    final pricing = result[0] as List<dynamic>; // unpack struct tuple

    final BigInt offPeakPrice = pricing[0] as BigInt;
    final BigInt peakPrice = pricing[1] as BigInt;

    final BigInt pricePerKWh = isPeakHours ? peakPrice : offPeakPrice;
    final BigInt totalCost = energyAmountKWh * pricePerKWh;

    // Pass bool directly, since contract expects bool type for 2nd param
    return await sendTransaction(
      'purchaseEnergyTokens',
      [energyAmountKWh, isPeakHours],
      value: totalCost,
    );
  }
}