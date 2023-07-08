import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Using chess UCI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Home page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _commandController;
  late TextEditingController _processPathController;
  late TextEditingController _outputController;
  Process? _uciProcess;

  @override
  void initState() {
    _commandController = TextEditingController();
    _processPathController = TextEditingController();
    _outputController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _processPathController.dispose();
    _commandController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _sendCommand() {
    _outputController.text = "";
    final command = _commandController.text;
    _uciProcess?.stdin.write("$command\n");
    _uciProcess?.stdin.flush();
  }

  void _selectProcessPath() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    _startProcessIfFileSelected(result);
  }

  void _startProcessIfFileSelected(FilePickerResult? result) async {
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      final path = file.absolute.path;
      final process = await Process.start(path, <String>[]);

      process.stdout.transform(utf8.decoder).listen((line) {
        _handleProcessLine(line);
      });

      setState(() {
        _uciProcess = process;
        _processPathController.text = path;
      });
    }
  }

  void _handleProcessLine(String line) {
    _outputController.text += "\n$line";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _commandController,
                  ),
                ),
                ElevatedButton(
                  onPressed: _sendCommand,
                  child: const Text(
                    'Send',
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _processPathController,
                    enabled: false,
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectProcessPath,
                  child: const Text(
                    'Select',
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: TextField(
                  controller: _outputController,
                  enabled: false,
                  maxLines: 100,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
