import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dd;
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  // State variables
  fbp.BluetoothDevice? connectedDevice;
  fbp.BluetoothCharacteristic? targetCharacteristic;
  StreamSubscription<fbp.BluetoothConnectionState>? connectionStateSubscription;
  StreamSubscription<List<int>>? valueSubscription;
  StreamSubscription<List<fbp.ScanResult>>? scanSubscription;
  bool isScanning = false;
  bool isConnecting = false;
  List<fbp.ScanResult> _scanResults = [];

  // Stream controllers for state updates
  final _connectionStateController = StreamController<fbp.BluetoothDevice?>.broadcast();
  final _scanResultsController = StreamController<List<fbp.ScanResult>>.broadcast();
  final _receivedDataController = StreamController<String>.broadcast();

  // Streams
  Stream<fbp.BluetoothDevice?> get connectionState => _connectionStateController.stream;
  Stream<List<fbp.ScanResult>> get scanResultsStream => _scanResultsController.stream;
  Stream<String> get receivedData => _receivedDataController.stream;
  
  // Getter for scan results
  List<fbp.ScanResult> get scanResults => _scanResults;

  Future<bool> checkBluetoothState() async {
    if (await fbp.FlutterBluePlus.isSupported == false) {
      return false;
    }
    return true;
  }

  void startScan() {
    if (isScanning) return;

    _scanResults.clear();
    isScanning = true;

    try {
      scanSubscription = fbp.FlutterBluePlus.scanResults.listen((results) {
        final resultMap = {for (var r in results) r.device.remoteId: r};
        _scanResults = resultMap.values.toList();
        _scanResults.sort((a, b) => b.rssi.compareTo(a.rssi));
        _scanResultsController.add(_scanResults);

        // Auto-connect logic for Spiceomat
        for (var result in results) {
          if (result.device.platformName == "Spiceomat") {
            dd.log("Found Spiceomat, attempting to connect...");
            stopScan();
            connect(result.device);
            return;
          }
        }
      }, onError: (e) {
        dd.log("Scan Error: $e");
        stopScan();
      });

      fbp.FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
      ).catchError((e) {
        dd.log("Start Scan Error: $e");
        isScanning = false;
      });

      Timer(const Duration(seconds: 10), stopScan);
    } catch (e) {
      dd.log("Could not start scan: $e");
      isScanning = false;
    }
  }

  void stopScan() {
    if (!isScanning) return;
    fbp.FlutterBluePlus.stopScan();
    scanSubscription?.cancel();
    isScanning = false;
  }

  Future<void> connect(fbp.BluetoothDevice device) async {
    if (isConnecting || connectedDevice != null) return;

    isConnecting = true;
    _receivedDataController.add("");
    stopScan();

    try {
      connectionStateSubscription = device.connectionState.listen((state) async {
        dd.log("Device ${device.remoteId} state: $state");
        if (state == fbp.BluetoothConnectionState.disconnected) {
          if (connectedDevice?.remoteId == device.remoteId) {
            connectedDevice = null;
            targetCharacteristic = null;
            isConnecting = false;
            _connectionStateController.add(null);
            _receivedDataController.add("Disconnected");
            valueSubscription?.cancel();
          }
        }
      });

      await device.connect(autoConnect: false);
      connectedDevice = device;
      isConnecting = false;
      _connectionStateController.add(device);
      _receivedDataController.add("Connected! Discovering services...");

      await _discoverServices(device);

    } catch (e) {
      dd.log("Connection Error: $e");
      isConnecting = false;
      _receivedDataController.add("Connection Failed: $e");
      device.disconnect();
    }
  }

  Future<void> _discoverServices(fbp.BluetoothDevice device) async {
    try {
      List<fbp.BluetoothService> services = await device.discoverServices();
      _receivedDataController.add("Found ${services.length} services.");

      fbp.BluetoothCharacteristic? writeCharacteristic;
      fbp.BluetoothCharacteristic? notifyCharacteristic;

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
            writeCharacteristic = characteristic;
          }
          if (characteristic.properties.notify) {
            notifyCharacteristic = characteristic;
          }
        }
      }

      if (writeCharacteristic != null) {
        targetCharacteristic = writeCharacteristic;
        _setupNotifications(notifyCharacteristic);
      } else {
        _receivedDataController.add("Required characteristic not found");
        disconnect();
      }
    } catch (e) {
      dd.log("Service Discovery Error: $e");
      _receivedDataController.add("Service Discovery Failed: $e");
      disconnect();
    }
  }

  Future<void> _setupNotifications(fbp.BluetoothCharacteristic? characteristic) async {
    if (characteristic == null) return;

    try {
      await characteristic.setNotifyValue(true);
      valueSubscription = characteristic.onValueReceived.listen((value) {
        String receivedText = utf8.decode(value);
        _receivedDataController.add(receivedText);
      }, onError: (e) {
        dd.log("Notification Error: $e");
      });
    } catch (e) {
      dd.log("Setup Notifications Error: $e");
    }
  }

  Future<void> sendData(String text) async {
    if (connectedDevice == null || targetCharacteristic == null) {
      dd.log("Not connected or characteristic not found.");
      _receivedDataController.add("Error: Not connected.");
      return;
    }

    if (text.isEmpty) {
      dd.log("Input text is empty.");
      _receivedDataController.add("Enter text to send.");
      return;
    }

    try {
      List<int> bytesToSend = utf8.encode(text);
      bool withoutResponse = targetCharacteristic!.properties.writeWithoutResponse;
      
      if (withoutResponse) {
        await targetCharacteristic!.write(bytesToSend, withoutResponse: true);
      } else {
        await targetCharacteristic!.write(bytesToSend);
      }
      
      //_receivedDataController.add("Sent: $text");
    } catch (e) {
      dd.log("Send Error: $e");
      _receivedDataController.add("Send Failed: $e");
    }
  }

  void disconnect() {
    connectionStateSubscription?.cancel();
    valueSubscription?.cancel();
    connectedDevice?.disconnect();
    connectedDevice = null;
    targetCharacteristic = null;
    isConnecting = false;
    _connectionStateController.add(null);
    _receivedDataController.add("Disconnected");
  }

  void dispose() {
    stopScan();
    disconnect();
    _connectionStateController.close();
    _scanResultsController.close();
    _receivedDataController.close();
  }
}