import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'confirmation_page.dart';

class WeightSelectionPage extends StatefulWidget {
  final String spiceName;
  final String imagePath;
  final List<int> availableQuantities;

  const WeightSelectionPage({
    super.key,
    required this.spiceName,
    required this.imagePath,
    this.availableQuantities = const [2, 3, 6, 9], // Standardwerte
  });

  @override
  State<WeightSelectionPage> createState() => _WeightSelectionPageState();
}

class _WeightSelectionPageState extends State<WeightSelectionPage> {
  late int _selectedQuantity;

  @override
  void initState() {
    super.initState();
    // Standardwert auf den ersten verfügbaren Wert setzen
    _selectedQuantity =
        widget.availableQuantities.isNotEmpty
            ? widget.availableQuantities[0]
            : 2;

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

  void _selectQuantity(int quantity) {
    setState(() {
      _selectedQuantity = quantity;
    });
  }

  void _increaseQuantity() {
    setState(() {
      if (_selectedQuantity < 100) {
        _selectedQuantity += 1;
      }
    });
  }

  void _decreaseQuantity() {
    setState(() {
      if (_selectedQuantity > 1) {
        _selectedQuantity -= 1;
      }
    });
  }

  void _proceed() {
    // Navigation zur Bestätigungsseite
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ConfirmationPage(
              spiceName: widget.spiceName,
              selectedAmount: "${_selectedQuantity}g",
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Überschrift "Menge auswählen"
            const Text(
              'Menge auswählen',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 135, 17, 9),
              ),
            ),

            const SizedBox(height: 10), // Reduzierter Abstand
            // Gewürzname
            Text(
              widget.spiceName,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10), // Reduzierter Abstand
            // Bild des Gewürzes
            Image.asset(
              widget.imagePath,
              height: 90, // Etwas reduzierte Höhe
              width: 90, // Etwas reduzierte Breite
              fit: BoxFit.contain,
              errorBuilder:
                  (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported,
                    size: 90,
                    color: Colors.grey,
                  ),
            ),

            const SizedBox(height: 10), // Reduzierter Abstand
            // Mengensteuerung
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _decreaseQuantity,
                  iconSize: 32,
                ),

                const SizedBox(width: 20),

                Text(
                  "${_selectedQuantity}g",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),

                const SizedBox(width: 20),

                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _increaseQuantity,
                  iconSize: 32,
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Mengenoptionen
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              alignment: WrapAlignment.center,
              children:
                  widget.availableQuantities.map((quantity) {
                    return ChoiceChip(
                      label: Text("${quantity}g"),
                      selected: _selectedQuantity == quantity,
                      onSelected: (selected) {
                        if (selected) {
                          _selectQuantity(quantity);
                        }
                      },
                    );
                  }).toList(),
            ),

            const Spacer(),

            // Buttons für Navigation (zurück zur Übersicht und weiter)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Zurück zur Übersicht-Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 15,
                        ),
                        backgroundColor: Colors.grey[400],
                        foregroundColor: Colors.black87,
                      ),
                      child: const Text('zurück zur Übersicht'),
                    ),
                  ),

                  const SizedBox(width: 20), // Abstand zwischen den Buttons
                  // Weiter-Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _proceed,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 15,
                        ),
                        backgroundColor: const Color(0xFF4CAF50), // Grün
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('weiter'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10), // Reduzierter Abstand am Ende
          ],
        ),
      ),
    );
  }
}
