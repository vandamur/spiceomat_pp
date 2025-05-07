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
    this.availableQuantities = const [2, 4, 8, 12], // Standardwerte
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
        padding: const EdgeInsets.all(32.0),
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

            const SizedBox(height: 10), // Abstand von 20 auf 10 reduziert
            // Hauptinhalt: Links Gewürz-Info, rechts Mengenauswahl
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Linke Seite: Gewürzname und Bild
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Gewürzname
                        Text(
                          widget.spiceName,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        // Bild des Gewürzes
                        Image.asset(
                          widget.imagePath,
                          height: 120,
                          width: 120,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (context, error, stackTrace) => const Icon(
                                Icons.image_not_supported,
                                size: 120,
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Trennlinie zwischen linker und rechter Seite
                  Container(
                    width: 1,
                    height: double.infinity,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),

                  // Rechte Seite: Mengenauswahl
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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

                        const SizedBox(height: 30),

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
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Buttons für Navigation (zurück zur Übersicht und weiter)
            Padding(
              padding: const EdgeInsets.all(32),
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

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
