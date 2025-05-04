import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'grindingdone.dart';
import 'services/bluetooth_service.dart';
import 'dart:async';

class GrindScreen extends StatefulWidget {
  final String spiceName;
  final String selectedAmount;
  final double targetWeight;

  const GrindScreen({
    super.key,
    required this.spiceName,
    required this.selectedAmount,
    required this.targetWeight,
  });

  @override
  State<GrindScreen> createState() => _GrindScreenState();
}

class _GrindScreenState extends State<GrindScreen> {
  bool _isGrinding = true;
  final BluetoothService _bluetooth = BluetoothService();
  String _currentWeight = "0.0";
  late StreamSubscription<String> _dataSubscription;

  @override
  void initState() {
    super.initState();
    // Querformat beibehalten
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Abonniere den Bluetooth-Datenstrom
    _setupBluetoothListener();

    // Starte den Mahlvorgang
    _startGrinding();
  }

  void _setupBluetoothListener() {
    _dataSubscription = _bluetooth.receivedData.listen((data) {
      if (mounted) {
        setState(() {
          _currentWeight = data;
        });

        // Prüfe, ob das Zielgewicht erreicht wurde
        _checkWeightAndFinish();
      }
    });
  }

  void _startGrinding() {
    // Sende den Befehl zum Starten des Mahlvorgangs mit dem Zielgewicht
    _bluetooth.sendData("<1;${widget.targetWeight}>");
  }

  void _stopGrinding() {
    // Sende den Befehl zum Stoppen des Mahlvorgangs
    _bluetooth.sendData("<0;0>");
  }

  void _checkWeightAndFinish() {
    try {
      double currentWeight = double.parse(_currentWeight);

      // Wenn das Zielgewicht erreicht oder überschritten wurde
      if (currentWeight >= widget.targetWeight && _isGrinding) {
        _stopGrinding();
        setState(() {
          _isGrinding = false;
        });

        // Navigiere zur "Fertig"-Seite
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => GrindingDone(
                  spiceName: widget.spiceName,
                  selectedAmount: widget.selectedAmount,
                ),
          ),
        );
      }
    } catch (e) {
      // Fehler beim Parsen des Gewichts
    }
  }

  @override
  void dispose() {
    // Datenabo beenden
    _dataSubscription.cancel();
    // Orientierung beim Verlassen nicht zurücksetzen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double? currentWeightValue;
    double progressValue = 0.0;

    try {
      currentWeightValue = double.parse(_currentWeight);
      progressValue =
          widget.targetWeight > 0
              ? (currentWeightValue / widget.targetWeight).clamp(0.0, 1.0)
              : 0.0;
    } catch (e) {
      currentWeightValue = null;
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gewürzinfo
              Text(
                '${widget.spiceName} - ${widget.selectedAmount}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 135, 17, 9),
                ),
              ),

              const SizedBox(height: 30),

              // Haupttext
              const Text(
                'Mahlvorgang läuft',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Gewichtsanzeige
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Aktuelles Gewicht: ${currentWeightValue?.toStringAsFixed(1) ?? "0.0"} g',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const Text(' / ', style: TextStyle(fontSize: 22)),
                  Text(
                    'Ziel: ${widget.targetWeight.toStringAsFixed(1)} g',
                    style: const TextStyle(fontSize: 22),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Fortschrittsbalken
              LinearProgressIndicator(
                value: progressValue,
                minHeight: 10,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 135, 17, 9),
                ),
              ),

              const SizedBox(height: 40),

              // Loading Animation
              _isGrinding
                  ? const CircularProgressIndicator(
                    color: Color.fromARGB(255, 135, 17, 9),
                    strokeWidth: 6.0,
                  )
                  : const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
