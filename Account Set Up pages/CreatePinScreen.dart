import 'package:flutter/material.dart';
import 'accountLogin.dart';

class CreatePinScreen extends StatefulWidget {
  @override
  _CreatePinScreenState createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  String pin = '';

  void _onKeyTap(String value) {
    setState(() {
      if (value == 'DEL') {
        if (pin.isNotEmpty) {
          pin = pin.substring(0, pin.length - 1);
        }
      } else if (pin.length < 6) {
        pin += value;
      }
    });
  }

  void _goToCongratsScreen() {
    if (pin.length >= 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CongratulationsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Instruction Text
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Add a pin number to make your account more secure",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // PIN Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                pin.isEmpty ? '• • • •' : pin.split('').map((e) => '•').join(' '),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 40, letterSpacing: 10),
              ),
            ),

            const SizedBox(height: 30),

            // Dial pad
            _buildNumberPad(),

            const SizedBox(height: 20),

            // Continue Button
            ElevatedButton(
              onPressed: _goToCongratsScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: const Size(200, 50),
              ),
              child: const Text("Continue"),
            ),

            const SizedBox(height: 20),

            // Dots Indicator
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle_outlined, size: 8),
                SizedBox(width: 5),
                Icon(Icons.circle_outlined, size: 8),
                SizedBox(width: 5),
                Icon(Icons.circle, size: 8), // current page
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    List<List<String>> keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['DEL', '0'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ElevatedButton(
                  onPressed: () => _onKeyTap(key),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                  ),
                  child: key == 'DEL'
                      ? const Icon(Icons.backspace_outlined)
                      : Text(
                    key,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class CongratulationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Congratulations!\nYour account is secure!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
