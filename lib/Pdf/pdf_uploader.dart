import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'pdf_viewer.dart';
import 'download.dart';

class PDFUploader extends StatefulWidget {
  @override
  _PDFUploaderState createState() => _PDFUploaderState();
}

class _PDFUploaderState extends State<PDFUploader> {
  String? _uploadedFileURL;

  Future<void> _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null) {
      PlatformFile file = result.files.first;
      String fileName = path.basename(file.path!);

      File fileToUpload = File(file.path!);

      try {
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference ref = storage.ref().child('uploads/$fileName');
        UploadTask uploadTask = ref.putFile(fileToUpload);

        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        _uploadedFileURL = await taskSnapshot.ref.getDownloadURL();
        print('File uploaded at: $_uploadedFileURL');
        setState(() {});
        _navigateToPDFViewerPage(_uploadedFileURL!);
      } catch (e) {
        print('Error uploading file: $e');
      }
    } else {
      print('User canceled the picker');
    }
  }

  Future<void> _navigateToPDFViewerPage(String url) async {
    final filePath = await downloadFile(url);  // Assuming downloadFile returns the file path as a String
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerPage(url: filePath),  // Pass filePath as url
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload PDF'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickAndUploadFile,
              child: Text('Pick and Upload PDF'),
            ),
            _uploadedFileURL != null
                ? Text('Uploaded PDF URL: $_uploadedFileURL')
                : Container(),
          ],
        ),
      ),
    );
  }
}
