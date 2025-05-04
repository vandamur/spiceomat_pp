import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'confirmation_page.dart';

class WeightSelectionPage extends StatefulWidget {
  final String spiceName;
  final String imagePath;

  const WeightSelectionPage({
    super.key,
    required this.spiceName,
    required this.imagePath,
  });

  @override
  State<WeightSelectionPage> createState() => _WeightSelectionPageState();
}

class _WeightSelectionPageState extends State<WeightSelectionPage> {
  String _selectedAmount = '2g'; // Standardwert

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

  void _selectAmount(String amount) {
    setState(() {
      _selectedAmount = amount;
    });
  }

  void _proceedToNextStep(BuildContext context) {
    // Navigation zur Bestätigungsseite
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ConfirmationPage(
              spiceName: widget.spiceName,
              selectedAmount: _selectedAmount,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Menge auswählen',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 135, 17, 9),
              ),
            ),
            const SizedBox(height: 20),

            // Bild des Gewürzes einfügen
            Image.asset(
              widget.imagePath,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder:
                  (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: Colors.grey,
                  ),
            ),

            const SizedBox(height: 20),

            // Mengenauswahl-Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAmountButton('2g'),
                const SizedBox(width: 15),
                _buildAmountButton('3g'),
                const SizedBox(width: 15),
                _buildAmountButton('6g'),
                const SizedBox(width: 15),
                _buildAmountButton('9g'),
              ],
            ),

            const SizedBox(height: 30),

            // Plus-Symbol
            const Icon(
              Icons.add_circle_outline,
              size: 60,
              color: Color.fromARGB(255, 135, 17, 9),
            ),

            const SizedBox(height: 10),

            // Produktname
            Text(
              widget.spiceName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const Spacer(),

            // Buttons-Reihe (zurück und weiter)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Zurück-Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
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
                  child: const Text('zurück', style: TextStyle(fontSize: 18)),
                ),

                // Weiter-Button
                ElevatedButton(
                  onPressed: () => _proceedToNextStep(context),
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
                  child: const Text('weiter', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountButton(String amount) {
    return ElevatedButton(
      onPressed: () => _selectAmount(amount),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _selectedAmount == amount
                ? const Color(0xFF4CAF50) // Grün
                : const Color(0xFFE0E0E0), // Grau
        foregroundColor:
            _selectedAmount == amount ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(amount, style: const TextStyle(fontSize: 16)),
    );
  }
}
