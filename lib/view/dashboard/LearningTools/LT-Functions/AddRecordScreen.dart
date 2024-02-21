import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AddRecordScreen extends StatefulWidget {
  @override
  _AddRecordScreenState createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  bool isRecording = false;
  FlutterSoundRecorder? _recorder;
  Color selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "Record Audio",
          style: TextStyle(
            color: Colors.black26,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFe5f3fd),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Color(0xFFe5f3fd),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    isRecording ? Icons.mic : Icons.mic_none,
                    size: 100,
                    color: isRecording ? Colors.red : Colors.green,
                  ),
                  SizedBox(height: 20),
                  Text(
                    isRecording ? 'Recording...' : 'Click to start recording',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  onPressed: _startStopRecording,
                  child: Icon(
                    isRecording ? Icons.stop : Icons.mic,
                    size: 40,
                    color: isRecording ? Colors.red : Colors.green,
                  ),
                  style: TextButton.styleFrom(
                    shape: CircleBorder(),
                  ),
                ),
                if (!isRecording)
                  TextButton.icon(
                    onPressed: () {
                      _promptFileName(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(
                      Icons.save,
                      color: Color(0xFFe5f3fd),
                    ),
                    label: Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startStopRecording() async {
    if (isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (await _requestPermission()) {
      try {
        await _recorder!.startRecorder(
          toFile: 'audio.wav',
          codec: Codec.pcm16WAV,
        );
        setState(() {
          isRecording = true;
        });
      } catch (e) {
        print('Error starting recording: $e');
      }
    }
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      isRecording = false;
    });
  }

  Future<bool> _requestPermission() async {
    if (await Permission.microphone.request().isGranted &&
        await Permission.storage.request().isGranted) {
      return true;
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Permission Required'),
          content: Text('Please grant microphone and storage permissions.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }
  }

  Future<void> _promptFileName(BuildContext context) async {
    TextEditingController fileNameController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter File Name"),
          content: TextField(
            controller: fileNameController,
            decoration: InputDecoration(hintText: "File Name"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                String fileName = fileNameController.text;
                if (fileName.isNotEmpty) {
                  await _saveRecording(fileName);
                }
                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveRecording(String fileName) async {
    if (await _requestStoragePermission()) {
      try {
        String? path = await _recorder!.stopRecorder();
        if (path != null) {
          // Get a list of external storage directories
          List<Directory>? storageDirectories = await getExternalStorageDirectories();
          if (storageDirectories != null && storageDirectories.isNotEmpty) {
            // Choose the directory where you want to save the recordings
            Directory chosenDirectory = storageDirectories[0]; // You can choose any directory from the list

            // Construct the directory path
            String recordingsDirectoryPath = '${chosenDirectory.path}/MyRecordings';

            // Create the directory if it doesn't exist
            Directory recordingsDirectory = Directory(recordingsDirectoryPath);
            if (!await recordingsDirectory.exists()) {
              await recordingsDirectory.create(recursive: true);
            }

            // Construct the file path
            String filePath = '$recordingsDirectoryPath/$fileName.wav';

            // Copy the recorded file to the recordings directory
            await File(path).copy(filePath);

            print('Recording saved at: $filePath');
          } else {
            print('Error: No external storage directories found');
          }
        } else {
          print('Error: Recording path is null');
        }
      } catch (e) {
        print('Error saving recording: $e');
      }
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Permission Required'),
          content: Text('Please grant storage permission to save the recording.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }
  }
}
