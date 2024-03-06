import 'package:flutter/material.dart';

class SettingsClass extends StatefulWidget {
  const SettingsClass({super.key});

  @override
  State<SettingsClass> createState() => _SettingsClassState();
}

class _SettingsClassState extends State<SettingsClass> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки приложения'),
        centerTitle: true,
      ),
    );
  }
}
