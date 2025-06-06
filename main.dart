
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const IndBelApp());
}

class IndBelApp extends StatelessWidget {
  const IndBelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IndBel',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _codeController = TextEditingController();
  String? _name;
  String? _km;
  late File localCsv;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final dir = await getApplicationDocumentsDirectory();
    localCsv = File('${dir.path}/dados.csv');
    await _syncCsv();
  }

  Future<void> _syncCsv() async {
    try {
      final now = DateTime.now();
      if (now.hour == 9 && now.minute >= 30 && now.minute < 45) {
        final response = await http.get(Uri.parse('https://raw.githubusercontent.com/LogisticaIncobel/indicadores-colaboradores/main/dados.csv'));
        if (response.statusCode == 200) {
          await localCsv.writeAsString(response.body);
        }
      }
    } catch (_) {}
  }

  Future<void> _login() async {
    if (!localCsv.existsSync()) return;
    final lines = await localCsv.readAsLines();
    for (var line in lines.skip(1)) {
      final parts = line.split(',');
      if (parts[0].trim() == _codeController.text.trim()) {
        setState(() {
          _name = parts[1];
          _km = '${double.parse(parts[2]).toStringAsFixed(2)} km';
        });
        return;
      }
    }
    setState(() {
      _name = 'Código não encontrado';
      _km = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(title: const Text('Login IndBel')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo_incobel.png', height: 100),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Digite seu código'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _login,
              child: const Text('ENTRAR'),
            ),
            const SizedBox(height: 20),
            if (_name != null) Text('Nome: $_name'),
            if (_km != null) Text('Dispersão KM: $_km'),
          ],
        ),
      ),
    );
  }
}
