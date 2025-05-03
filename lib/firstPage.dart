import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Setzt die Orientierung zurück beim Verlassen der Seite
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  // Funktion zum Navigieren zur nächsten Seite oder zur "Nicht verfügbar"-Seite
  void _selectSpice(BuildContext context, String spiceName, bool isAvailable) {
    if (isAvailable) {
      // TODO: Navigiere zur Mengenauswahl-Seite für verfügbare Gewürze
      print('Selected available spice: $spiceName');
      // Navigator.push(context, MaterialPageRoute(builder: (context) => QuantitySelectionPage(spiceName: spiceName)));
    } else {
      // TODO: Navigiere zur "Nicht verfügbar"-Seite
      print('Selected unavailable spice: $spiceName');
      // Navigator.push(context, MaterialPageRoute(builder: (context) => SpiceUnavailablePage(spiceName: spiceName)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Center(
                child: Text(
                  'Wähle dein Gewürz aus',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 135, 17, 9),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: <Widget>[
                  _buildSpiceCard(
                    context,
                    'Pfeffer',
                    'assets/black_pepper.png',
                    true,
                  ),
                  _buildSpiceCard(context, 'Chili', 'assets/chili.png', false),
                  _buildSpiceCard(
                    context,
                    'Kardamom',
                    'assets/cardamom.png',
                    false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpiceCard(
    BuildContext context,
    String name,
    String imagePath,
    bool isAvailable,
  ) {
    return GestureDetector(
      onTap: () => _selectSpice(context, name, isAvailable),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.brown[400], // Beispiel-Hintergrundfarbe
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Center(
                        child: Text('Bild\n$name', textAlign: TextAlign.center),
                      ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
