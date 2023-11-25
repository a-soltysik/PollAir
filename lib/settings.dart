import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  static final settings = [true, false];
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Choose unit"),
          ToggleButtons(
            isSelected: settings,
            children: const <Widget>[
              Text("µg/m³"),
              Text("%"),
            ],
            onPressed: (int index) {
              setState(() {
                for (int i = 0; i < settings.length; i++) {
                  settings[i] = i == index;
                }
              });
            },
          )
        ]);
  }
}
