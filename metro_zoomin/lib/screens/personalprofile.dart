import 'package:flutter/material.dart';
import '../widgets/universalwidgets.dart';

class PersonalProfile extends StatefulWidget {
  const PersonalProfile({super.key});

  @override
  State<PersonalProfile> createState() => _PersonalProfileState();
}

class _PersonalProfileState extends State<PersonalProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Personal Profile'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('Test'),
          ],
        ),
      ),
    );
  }
}
