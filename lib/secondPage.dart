import 'dart:developer' as dd;
import 'package:flutter/material.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  bool _isPfefferActive = true;
  bool _isChiliActive = false;
  bool _isKardamomActive = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth * 0.15;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F1DE),
      body: Stack(
        children: [
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              opacity: _isFocused ? 0 : 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.topCenter,
                    child: const Text(
                      "Mal wieder frisch kochen mit...",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildButtonWithText(
                        imagePath: 'assets/black_pepper.png',
                        buttonSize: buttonSize,
                        text: 'Pfeffer',
                        backgroundColor: const Color(0xFF555629),
                        onTap: () {
                          setState(() {
                            _isFocused = true;

                            dd.log("Pfeffer pressed");
                          });
                        },
                        isActive: _isPfefferActive,
                      ),
                      const SizedBox(width: 20),
                      _buildButtonWithText(
                        imagePath: 'assets/chili.png',
                        buttonSize: buttonSize,
                        text: 'Chili',
                        backgroundColor: const Color(0xFF4f2b14),
                        onTap: () {
                          setState(() {
                            _isFocused = true;

                            dd.log("Chili pressed");
                          });
                        },
                        isActive: _isChiliActive,
                      ),
                      const SizedBox(width: 20),
                      _buildButtonWithText(
                        imagePath: 'assets/cardamom.png',
                        buttonSize: buttonSize,
                        text: 'Kardamom',
                        backgroundColor: const Color(0xFFa86414),
                        onTap: () {
                          setState(() {
                            _isFocused = true;

                            dd.log("Kardamom pressed");
                          });
                        },
                        isActive: _isKardamomActive,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isFocused)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 800),
              top: MediaQuery.of(context).size.height / 3 - buttonSize / 2,
              left: MediaQuery.of(context).size.width / 2 - buttonSize / 2,
              child: _buildButtonWithText(
                imagePath:
                    _isPfefferActive
                        ? 'assets/black_pepper.png'
                        : _isChiliActive
                        ? 'assets/chili.png'
                        : 'assets/cardamom.png',
                buttonSize: buttonSize * 1.5,
                text:
                    _isPfefferActive
                        ? 'Pfeffer'
                        : _isChiliActive
                        ? 'Chili'
                        : 'Kardamom',
                backgroundColor:
                    _isPfefferActive
                        ? const Color(0xFF555629)
                        : _isChiliActive
                        ? const Color(0xFF4f2b14)
                        : const Color(0xFFa86414),
                onTap: () {},
                isActive: true,
              ),
            ),
          if (_isFocused)
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 30),
                onPressed: () {
                  setState(() {
                    _isFocused = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButtonWithText({
    required String imagePath,
    required double buttonSize,
    required String text,
    required Color backgroundColor,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            InkWell(
              onTap: isActive ? onTap : null,
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    imagePath,
                    width: buttonSize,
                    height: buttonSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            if (!isActive)
              Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    202,
                    202,
                    202,
                  ).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
          ],
        ),
        const SizedBox(height: 0),
        Container(
          width: buttonSize,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: const BoxDecoration(color: Colors.white),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
