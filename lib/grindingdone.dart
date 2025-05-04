import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'spice_overview.dart';

class GrindingDone extends StatefulWidget {
  final String spiceName;
  final String selectedAmount;

  const GrindingDone({
    super.key,
    required this.spiceName,
    required this.selectedAmount,
  });

  @override
  State<GrindingDone> createState() => _GrindingDoneState();
}

class _GrindingDoneState extends State<GrindingDone> {
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
    // Orientierung beim Verlassen nicht zurücksetzen
    super.dispose();
  }

  void _navigateToHome(BuildContext context) {
    // Navigator pop until FirstPage
    // Navigator.popUntil(context, (route) => route.isFirst);

    // Navigate to SpiceOverview via MaterialPageRoute
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SpiceOverview()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFA5D6A7), // Helles Grün oben
              Colors.white, // Weiß unten
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Überschrift
              Text(
                "Dein ${widget.spiceName} ist frisch gemahlen!",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF388E3C), // Dunkleres Grün
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Subheadline
              const Text(
                "Du kannst dein Gefäß jetzt entnehmen.",
                style: TextStyle(fontSize: 20, color: Colors.black87),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Icon/Bild
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFA5D6A7).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 100,
                  color: Color(0xFF388E3C),
                ),
              ),

              const SizedBox(height: 30),

              // Information zur gemahlenen Menge
              Text(
                "Gemahlene Menge: ${widget.selectedAmount}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Button zur Startseite
              ElevatedButton(
                onPressed: () => _navigateToHome(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF388E3C), // Dunkleres Grün
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
                  "Zur Startseite",
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
