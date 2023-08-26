import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  static const routeName = '/privacy-policy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: Column(
            children: [
              Text(
                'Workout is a fitness app that helps you track your fitness activities.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 36),
              Text(
                  'Workout uses your google data after your consent to fetch data from google fit. The data accessed is only used for displaying purposes and is stored on the device. In any case, the data is not shared with any third party.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
