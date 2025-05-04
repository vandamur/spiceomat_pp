// filepath: /Users/vandamuradyan/development/spiceomat_pp/lib/spice_overview.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'weight_selection_page.dart';
import 'spice_unavailable_page.dart';

class SpiceOverview extends StatefulWidget {
  const SpiceOverview({super.key});

  @override
  State<SpiceOverview> createState() => _SpiceOverviewState();
}

class _SpiceOverviewState extends State<SpiceOverview> {
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
  void _selectSpice(
    BuildContext context,
    String spiceName,
    String imagePath,
    bool isAvailable,
  ) {
    if (isAvailable) {
      // Navigation zur Mengenauswahl-Seite für verfügbare Gewürze
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => WeightSelectionPage(
                spiceName: spiceName,
                imagePath: imagePath,
              ),
        ),
      );
    } else {
      // Navigation zur "Nicht verfügbar"-Seite
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SpiceUnavailablePage(
                spiceName: spiceName,
                imagePath: imagePath,
              ),
        ),
      );
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
                    fontSize: 34,
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
      onTap: () => _selectSpice(context, name, imagePath, isAvailable),
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color:
                      isAvailable
                          ? const Color.fromARGB(79, 43, 20, 0)
                          : const Color.fromARGB(79, 43, 20, 40),
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
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
