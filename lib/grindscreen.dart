import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'grindingdone.dart';

class GrindScreen extends StatefulWidget {
  final String spiceName;
  final String selectedAmount;

  const GrindScreen({
    super.key,
    required this.spiceName,
    required this.selectedAmount
  });

  @override
  State<GrindScreen> createState() => _GrindScreenState();
}

class _GrindScreenState extends State<GrindScreen> {
  bool _isGrinding = true;
  
  @override
  void initState() {
    super.initState();
    // Querformat beibehalten
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    // Simulierte Mahldauer von 5 Sekunden
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isGrinding = false;
        });
        // Navigation zur "Fertig"-Seite
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GrindingDone(
              spiceName: widget.spiceName,
              selectedAmount: widget.selectedAmount,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    // Orientierung beim Verlassen nicht zurücksetzen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gewürzinfo
              Text(
                '${widget.spiceName} - ${widget.selectedAmount}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 135, 17, 9),
                ),
              ),
              
              const SizedBox(height: 50),
              
              // Haupttext
              const Text(
                'Mahlvorgang läuft',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // Untertext
              const Text(
                'Bitte einen Moment Geduld',
                style: TextStyle(
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 60),
              
              // Loading Animation
              const CircularProgressIndicator(
                color: Color.fromARGB(255, 135, 17, 9),
                strokeWidth: 6.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}