import 'package:flutter/material.dart';

// Simple win page
class WinPage extends StatelessWidget {
  const WinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'correct-hero',
                child: Image.asset(
                  'assets/images/correct_item.png',
                  width: 200,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'You Found It!',
                style: TextStyle(fontSize: 34, color: Colors.orange),
              ),
              SizedBox(height: 10),
              Text('Happy Halloween 🎃', style: TextStyle(fontSize: 18)),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (r) => false),
                child: Text('Back Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
