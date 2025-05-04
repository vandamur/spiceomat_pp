import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'first_page.dart';

class SpiceUnavailablePage extends StatefulWidget {
  final String spiceName;

  const SpiceUnavailablePage({super.key, required this.spiceName});

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
    // TODO: Implementiere die Navigation zurück zur Gewürzauswahl
    print('Going back to overview');
    Navigator.pop(context); // Beispiel: Einfach zurück
    // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => FirstPage()), (route) => false); // Beispiel: Zurück zur Startseite
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.spiceName),
        backgroundColor: const Color.fromARGB(255, 135, 17, 9),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // TODO: Bild des Gewürzes einfügen
              Image.asset(
                'assets/${widget.spiceName.toLowerCase()}.png',
                height: 150,
                errorBuilder:
                    (context, error, stackTrace) => const Icon(
                      Icons.error_outline,
                      size: 150,
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.spiceName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Oops, das gewählte Gewürz ist momentan nicht verfügbar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _goBackToOverview(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 135, 17, 9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('zur Gewürz-Übersicht'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
