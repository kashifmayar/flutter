import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<String> downloadFile(String url) async {
  final ref = FirebaseStorage.instance.refFromURL(url);
  final dir = await getApplicationDocumentsDirectory();
  final file = File(path.join(dir.path, ref.name));
  await ref.writeToFile(file);
  return file.path;
}
