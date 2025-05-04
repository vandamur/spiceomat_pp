import 'package:flutter/material.dart';
import 'services/bluetooth_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'first_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spiceomat',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BluetoothService _bluetooth = BluetoothService();
  final TextEditingController _textController = TextEditingController();
  String _receivedData = "";
  bool _isScanning = false;
  double _targetWeight = 0.0;
  bool _isTaring = false;

  fbp.BluetoothDevice? _connectedDevice;

  @override
  void initState() {
    super.initState();
    _setupBluetoothListeners();

    // Start scanning automatically
    _bluetooth.startScan();

    // Stop scanning after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (_isScanning && mounted) {
        _bluetooth.stopScan();
      }
    });
  }

  void _setupBluetoothListeners() {
    _bluetooth.connectionState.listen((device) {
      setState(() {
        _connectedDevice = device;
      });
    });

    _bluetooth.scanResultsStream.listen((results) {
      setState(() {
        _isScanning = _bluetooth.isScanning;
      });
    });

    _bluetooth.receivedData.listen((data) {
      setState(() {
        _receivedData = data;
      });
    });
  }

  void _handleTare() {
    _bluetooth.sendData("<2;0>");
    setState(() {
      _isTaring = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTaring = false;
        });
      }
    });
  }

  double _getCurrentWeight() {
    try {
      return double.parse(_receivedData);
    } catch (e) {
      return 0.0;
    }
  }

  @override
  void dispose() {
    _bluetooth.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiceomat', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 135, 17, 9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (_connectedDevice == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: LinearProgressIndicator(),
              ),
            const SizedBox(height: 10),

            if (_connectedDevice != null) ...[
              TextField(
                controller: _textController,

                decoration: const InputDecoration(
                  labelText: 'Enter text to send',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _bluetooth.sendData(_textController.text);
                  //_textController.clear();
                },
                child: const Text('Send'),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Target Weight: ${_targetWeight.toStringAsFixed(1)} g'),
                  Expanded(
                    child: Slider(
                      value: _targetWeight,
                      min: 0.0,
                      max: 3.0,
                      divisions: 60,
                      onChanged: (value) {
                        setState(() {
                          _targetWeight = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _bluetooth.sendData("<1;$_targetWeight>");
                    },
                    child: const Text('Test'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _bluetooth.sendData("<0;0>");
                    },
                    child: const Text('Stop'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _handleTare();
                    },
                    child: const Text('Tare'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Current Weight:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Center(
                child: Text(
                  _isTaring ? 'Taring...' : '$_receivedData g',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              const SizedBox(height: 20),
              if (_targetWeight > 0) ...[
                LinearProgressIndicator(
                  value: _getCurrentWeight() / _targetWeight,
                  minHeight: 10,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                ),
                const SizedBox(height: 20),
              ],
            ],
            const Spacer(), // Fügt flexiblen Raum hinzu, um den Button nach unten zu schieben
            Center(
              // Zentriert den Button horizontal
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FirstPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  backgroundColor: const Color.fromARGB(255, 135, 17, 9),
                  foregroundColor: Colors.white,
                ),
                child: const Text('START', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(
              height: 20,
            ), // Fügt etwas Abstand am unteren Rand hinzu
          ],
        ),
      ),
    );
  }
}
