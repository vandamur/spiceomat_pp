import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'spice_overview.dart';

class SpiceUnavailablePage extends StatefulWidget {
  final String spiceName;
  final String imagePath;

  const SpiceUnavailablePage({
    super.key,
    required this.spiceName,
    required this.imagePath,
  });

  @override
  State<SpiceUnavailablePage> createState() => _SpiceUnavailablePageState();
}

class _SpiceUnavailablePageState extends State<SpiceUnavailablePage> {
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

  // Funktion zum Zurückkehren zur Übersicht
  void _goBackToOverview(BuildContext context) {
    // Navigation zurück zur Gewürzauswahl
    print('Going back to overview');
    Navigator.pop(context); // Einfach zurück zur vorherigen Seite
    // Alternative: Zurück zur Startseite
    // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpiceOverview()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // TODO: Bild des Gewürzes einfügen
              Image.asset(
                widget.imagePath,
                height: 150,
                errorBuilder:
                    (context, error, stackTrace) => const Icon(
                      Icons.error_outline,
                      size: 150,
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.spiceName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Oops, das gewählte Gewürz ist momentan nicht verfügbar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _goBackToOverview(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 135, 17, 9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'zur Gewürz-Übersicht',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
