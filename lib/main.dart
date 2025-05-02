import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this for SystemChrome
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';
import 'dart:developer' as dd;
import 'secondPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spiceomat',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainPage(),
      routes: {'/second': (context) => SecondPage()},
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  UsbPort? _port;
  String _status = "Idle";
  List<Widget> _ports = [];
  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;
  UsbDevice? _device;
  int motorSpeed = 0;
  double TARGET_WEIGHT = 1.0;

  // Add a TextEditingController
  final TextEditingController _serialDataController = TextEditingController();

  Future<bool> _connectTo(device) async {
    // Clear the controller instead of the list
    _serialDataController.clear();

    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }

    if (_transaction != null) {
      _transaction!.dispose();
      _transaction = null;
    }

    if (_port != null) {
      _port!.close();
      _port = null;
    }

    if (device == null) {
      _device = null;
      setState(() {
        _status = "Disconnected";
      });
      return true;
    }

    _port = await device.create();
    if (await (_port!.open()) != true) {
      setState(() {
        _status = "Failed to open port";
      });
      return false;
    }
    _device = device;

    await _port!.setDTR(true);
    await _port!.setRTS(true);
    await _port!.setPortParameters(
      9600,
      UsbPort.DATABITS_8,
      UsbPort.STOPBITS_1,
      UsbPort.PARITY_NONE,
    );

    _transaction = Transaction.stringTerminated(
      _port!.inputStream as Stream<Uint8List>,
      Uint8List.fromList([13, 10]),
    );

    _subscription = _transaction!.stream.listen((String line) {
      setState(() {
        // Append data to the controller
        _serialDataController.text += line + '\n';
      });
    });

    setState(() {
      _status = "Connected";
    });
    return true;
  }

  void _getPorts() async {
    _ports = [];
    List<UsbDevice> devices = await UsbSerial.listDevices();
    dd.log("Devices: $devices");

    // Check if the current device is still connected
    if (_device != null && !devices.contains(_device)) {
      dd.log("Current device disconnected");
      await _connectTo(null); // Disconnect if the device is gone
    }

    // Attempt auto-connect if exactly one device is found and none is connected
    if (_device == null && devices.length == 1) {
      dd.log("Exactly one device found, attempting auto-connect...");
      // Use await here to ensure connection attempt completes before UI update
      await _connectTo(devices[0]);
      // We call setState after the loop to update the UI based on the connection status
    }

    devices.forEach((device) {
      _ports.add(
        ListTile(
          leading: Icon(Icons.usb),
          title: Text(
            device.productName ?? "Unknown Product",
          ), // Added null check
          subtitle: Text(
            device.manufacturerName ?? "Unknown Manufacturer",
          ), // Added null check
          trailing: _buildConnectButton(
            device,
            devices.length,
          ), // Use helper function
        ),
      );
    });

    // Update the state after processing all devices and connection attempts
    setState(() {});
  }

  // Helper function to decide which button to show
  Widget? _buildConnectButton(UsbDevice device, int totalDevices) {
    if (_device == device) {
      // If this device is the connected device, show Disconnect
      return ElevatedButton(
        child: Text("Disconnect"),
        onPressed: () {
          _connectTo(null).then((res) {
            // No need to call _getPorts here, usbEventStream listener will trigger it
          });
        },
      );
    } else if (_device == null && totalDevices > 1) {
      // If no device is connected and there are multiple devices, show Connect
      return ElevatedButton(
        child: Text("Connect"),
        onPressed: () {
          _connectTo(device).then((res) {
            // No need to call _getPorts here, usbEventStream listener will trigger it
          });
        },
      );
    } else {
      // Otherwise (auto-connecting, or connected to another device), show nothing
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    UsbSerial.usbEventStream!.listen((UsbEvent event) {
      dd.log("USB Event: ${event.event}"); // Log the event type
      _getPorts(); // Refresh ports on any USB event
    });

    // Initial attempt to get ports and potentially auto-connect
    _getPorts();
  }

  @override
  void dispose() {
    // Dispose the controller
    _serialDataController.dispose();
    super.dispose();
    _connectTo(null);
  }

  void startMotor(int motorSpeed, double TARGET_WEIGHT) async {
    dd.log("startMotor pushed");
    String data = "<0,$motorSpeed,$TARGET_WEIGHT,0>";
    dd.log(data);
    if (_port == null) {
      dd.log("Port is null, returning ...");
      return;
    }

    await _port!.write(Uint8List.fromList(data.codeUnits));
  }

  void stopMotor() async {
    dd.log("stopMotor pushed");
    if (_port == null) {
      dd.log("Port is null, returning ...");
      return;
    }
    String data = "<0,0,0,0>";
    await _port!.write(Uint8List.fromList(data.codeUnits));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalMargin = 0.02 * screenWidth;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiceomat', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 135, 17, 9),
      ),
      body: SingleChildScrollView(
        // Added SingleChildScrollView
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
            child: Column(
              children: <Widget>[
                Text(
                  _ports.isNotEmpty
                      ? "Available Serial Ports"
                      : "No serial devices available",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ..._ports,
                Text('Status: $_status\n'),
                Text(
                  'info: ${_port?.toString() ?? "N/A"}\n',
                ), // Added null check for _port
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => startMotor(motorSpeed, TARGET_WEIGHT),
                      child: Icon(Icons.play_arrow),
                    ),
                    SizedBox(width: 16), // Add spacing between buttons
                    ElevatedButton(
                      onPressed: stopMotor,
                      child: Icon(Icons.stop),
                    ),
                  ],
                ),
                // First Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("<<<", style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            motorSpeed
                                .toString(), // Display current value above slider
                            style: TextStyle(fontSize: 16),
                          ),
                          Slider(
                            value: motorSpeed.toDouble(),
                            min: -100,
                            max: 100,
                            divisions:
                                20, // Adjusted divisions for better granularity
                            label: motorSpeed.toString(),
                            onChanged: (double value) {
                              dd.log("Motor speed: $value");
                              setState(() {
                                motorSpeed = value.toInt();
                              });
                            },
                            onChangeEnd: (double value) {
                              //startMotor(motorSpeed);
                            },
                          ),
                        ],
                      ),
                    ),
                    Text(">>>", style: TextStyle(fontSize: 16)),
                  ],
                ),
                // Second Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("<<<", style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            TARGET_WEIGHT.toStringAsFixed(
                              1,
                            ), // Display current value
                            style: TextStyle(fontSize: 16),
                          ),
                          Slider(
                            value: TARGET_WEIGHT,
                            min: 1.0,
                            max: 100.0,
                            divisions: 99, // 100 divisions means 99 intervals
                            label: TARGET_WEIGHT.toStringAsFixed(1),
                            onChanged: (double value) {
                              setState(() {
                                TARGET_WEIGHT = value;
                              });
                              // Intentionally left empty as requested for further action
                            },
                          ),
                        ],
                      ),
                    ),
                    Text(">>>", style: TextStyle(fontSize: 16)),
                  ],
                ),
                // Add a TextField to display serial data
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: TextField(
                    controller: _serialDataController,
                    readOnly: true,
                    maxLines: 5, // Adjust number of lines as needed
                    decoration: InputDecoration(
                      labelText: "Serial Data",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                SizedBox(height: 20), // Add some spacing before the button
                ElevatedButton(
                  child: Text('Go to Second Page'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/second');
                  },
                ),
                SizedBox(height: 20), // Add some spacing at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}
