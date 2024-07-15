import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_pdfview/flutter_pdfview.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  File? selectedImage;
  bool showDropdown = false;
  String? selectedRelation;

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickAndUploadPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null) {
      PlatformFile file = result.files.first;
      String fileName = path.basename(file.path!);

      File fileToUpload = File(file.path!);

      try {
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference ref = storage.ref().child('pdfs/$fileName');
        UploadTask uploadTask = ref.putFile(fileToUpload);

        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        String downloadURL = await taskSnapshot.ref.getDownloadURL();
        print('PDF uploaded at: $downloadURL');
      } catch (e) {
        print('Error uploading PDF: $e');
      }
    } else {
      print('User canceled the picker');
    }
  }

  Future<void> _viewPDF() async {
    // Example PDF path from Firebase Storage
    String examplePDFPath = 'pdfs/test.pdf';

    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child(examplePDFPath);
      String downloadURL = await ref.getDownloadURL();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(url: downloadURL),
        ),
      );
    } catch (e) {
      print('Error fetching PDF: $e');
    }
  }

  void _toggleDropdown() {
    setState(() {
      showDropdown = !showDropdown;
    });
  }

  void _onRelationSelected(String? value) {
    setState(() {
      selectedRelation = value;
      showDropdown = false;
    });
    _pickImageFromGallery();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "DashBoard",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.greenAccent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: _toggleDropdown,
                icon: const Icon(Icons.upload_rounded),
                label: const Text("Add Report"),
              ),
              if (showDropdown)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: selectedRelation,
                    hint: const Text('Select Relation'),
                    items: ['My Self', 'Father', 'Mother', 'Son', 'Daughter']
                        .map((relation) => DropdownMenuItem<String>(
                      value: relation,
                      child: Text(relation),
                    ))
                        .toList(),
                    onChanged: _onRelationSelected,
                  ),
                ),
              if (selectedImage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(selectedImage!),
                ),
              ElevatedButton.icon(
                onPressed: _pickAndUploadPDF,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Upload PDF"),
              ),
              ElevatedButton.icon(
                onPressed: _viewPDF,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("View PDF"),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 120),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/add-member');
                    },
                    label: const Text("Add Member"),
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PDFViewerPage extends StatelessWidget {
  final String url;

  PDFViewerPage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View PDF'),
      ),
      body: PDFView(
        filePath: url,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
        onRender: (_pages) {
          print("PDF rendered: $_pages pages");
        },
        onError: (error) {
          print('Error: $error');
        },
        onPageError: (page, error) {
          print('Page error on page: $page, error: $error');
        },
        onViewCreated: (PDFViewController pdfViewController) {
          print("PDFView created");
        },
        onPageChanged: (int? page, int? total) {
          print('Page changed: $page/$total');
        },
      ),
    );
  }
}
