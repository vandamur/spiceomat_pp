import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'weight_selection_page.dart';
import 'grindscreen.dart';

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

  void _backToWeightSelection(BuildContext context) {
    Navigator.pop(context);
  }

  void _containerPlaced(BuildContext context) {
    // Navigation zum Mahlvorgang
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GrindScreen(
          spiceName: widget.spiceName,
          selectedAmount: widget.selectedAmount,
        ),
      ),
    );
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
