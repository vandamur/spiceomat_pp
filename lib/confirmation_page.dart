import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'weight_selection_page.dart';
import 'grindscreen.dart';
import 'services/bluetooth_service.dart';

class ConfirmationPage extends StatefulWidget {
  final String spiceName;
  final String selectedAmount;

  const ConfirmationPage({
    super.key,
    required this.spiceName,
    required this.selectedAmount,
  });

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  // BluetoothService Instanz
  final BluetoothService _bluetoothService = BluetoothService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Querformat beibehalten
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Orientierung beim Verlassen nicht zurücksetzen, da die vorherige Seite
    // ebenfalls im Querformat ist
    super.dispose();
  }

  // Konvertiert den String der ausgewählten Menge in einen double-Wert
  double _getTargetWeight() {
    // Entfernt das 'g' vom Ende und konvertiert in einen Double
    String numericPart = widget.selectedAmount.replaceAll('g', '');
    return double.parse(numericPart);
  }

  void _backToWeightSelection(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> _containerPlaced(BuildContext context) async {
    // Vermeide mehrfaches Klicken während der Verarbeitung
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Sende den TARE-Befehl über Bluetooth
      await _bluetoothService.sendData("TARE");

      // Zeige einen Indikator, dass die Waage tariert wird
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waage wird tariert...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Warte 2 Sekunden
      await Future.delayed(const Duration(seconds: 2));

      // Prüfe, ob die Seite noch montiert ist, bevor wir weitermachen
      if (!mounted) return;

      // Navigation zum Mahlvorgang mit Zielgewicht
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => GrindScreen(
                spiceName: widget.spiceName,
                selectedAmount: widget.selectedAmount,
                targetWeight: _getTargetWeight(),
              ),
        ),
      );
    } catch (e) {
      // Bei Fehler eine Nachricht anzeigen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Tarieren: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Stelle sicher, dass der Verarbeitungsstatus zurückgesetzt wird
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gewürzname und ausgewählte Menge als Titel
            Text(
              '${widget.spiceName} - ${widget.selectedAmount}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 135, 17, 9),
              ),
            ),

            const SizedBox(height: 50),

            // Hauptanweisung
            const Text(
              'Platziere das Gefäß unter der Öffnung und bestätige, wenn du bereit bist.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 80),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Zurück zur Mengenauswahl Button
                ElevatedButton(
                  onPressed: () => _backToWeightSelection(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Menge ändern',
                    style: TextStyle(fontSize: 18),
                  ),
                ),

                // Gefäß platziert Button
                ElevatedButton(
                  onPressed: () => _containerPlaced(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50), // Grün
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Gefäß platziert',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
