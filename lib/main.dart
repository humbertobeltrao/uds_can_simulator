//TO TRANSFER FROM CLOUD TO SD CARD (USING client.ino FILE)
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:webappesp/firmware_version.dart';

class FirmwareList extends StatefulWidget {
  @override
  _FirmwareListState createState() => _FirmwareListState();
}

class _FirmwareListState extends State<FirmwareList> {
  List<FirmwareVersion> firmwareVersions = [];
  String? _ipAddress;

  @override
  void initState() {
    super.initState();
    fetchFirmwareVersions();
  }

  // Fetch the JSON file containing firmware versions
  Future<void> fetchFirmwareVersions() async {
    final response = await http.get(Uri.parse(
        'https://drive.google.com/uc?export=download&id=1sXG-sWlGdqKr6ouHnW9tpQZUECDOBubU'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        // Parse the firmware versions from JSON
        firmwareVersions = (data['firmware_versions'] as List)
            .map((item) => FirmwareVersion.fromJson(item))
            .toList();
      });
    } else {
      print('Failed to load firmware versions');
    }
  }

  Future<void> _sendFirmwareUrl(String url) async {
    if (_ipAddress == null || _ipAddress!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the ESP32 IP address')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://$_ipAddress/update-firmware'),
      body: json.encode({'url': url}),
      headers: {'Content-Type': 'application/json'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firmware URL sent successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send firmware URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firmware Versions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Enter ESP32 IP Address',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _ipAddress = value;
              },
            ),
            SizedBox(height: 16),
            Expanded(
              child: firmwareVersions.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: firmwareVersions.length,
                      itemBuilder: (context, index) {
                        final firmware = firmwareVersions[index];
                        return ListTile(
                          title: Text('${firmware.displayVersion}'),
                          onTap: () {
                            _sendFirmwareUrl(firmware.url);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FirmwareList(),
  ));
}
/*
//TO STORE FILE LOCALLY
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firmware Downloader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirmwareListScreen(),
    );
  }
}

class FirmwareListScreen extends StatefulWidget {
  @override
  _FirmwareListScreenState createState() => _FirmwareListScreenState();
}

class _FirmwareListScreenState extends State<FirmwareListScreen> {
  List<dynamic> firmwareVersions = [];

  @override
  void initState() {
    super.initState();
    fetchFirmwareVersions();
  }

  Future<void> fetchFirmwareVersions() async {
    final response = await http.get(Uri.parse(
        'https://drive.google.com/uc?export=download&id=1R4iZKPCbdQDQ0JhU5KlgHnPGoNR7aliA'));

    if (response.statusCode == 200) {
      setState(() {
        firmwareVersions = json.decode(response.body)['firmware_versions'];
      });
    } else {
      throw Exception('Failed to load firmware versions');
    }
  }

  Future<void> downloadFirmware(String url, String displayVersion) async {
    final stopwatch = Stopwatch()..start();

    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/firmware_$displayVersion.bin');

    await file.writeAsBytes(bytes);

    stopwatch.stop();

    print('Download completed in ${stopwatch.elapsed.inSeconds} seconds');
    print('File saved at: ${file.path}'); // Print file path

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Download completed in ${stopwatch.elapsed.inSeconds} seconds. File saved at: ${file.path}')),
    );
    await moveFileToExternalStorage('firmware_$displayVersion.bin');
  }

  Future<void> moveFileToExternalStorage(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final internalFile = File('${directory.path}/$fileName');

    final externalDirectory = await getExternalStorageDirectory();
    final externalFile = File('${externalDirectory!.path}/$fileName');

    // Copy the file to external storage
    await internalFile.copy(externalFile.path);

    print('File moved to external storage: ${externalFile.path}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firmware Versions'),
      ),
      body: firmwareVersions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: firmwareVersions.length,
              itemBuilder: (context, index) {
                final firmware = firmwareVersions[index];
                return ListTile(
                  title: Text(firmware['display_version']),
                  onTap: () {
                    downloadFirmware(
                        firmware['url'], firmware['display_version']);
                  },
                );
              },
            ),
    );
  }
}*/
