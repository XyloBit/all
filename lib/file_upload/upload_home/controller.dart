
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../helper/helper.dart';
import '../theme.dart';

class FileUploadController extends GetxController {
  var files = RxList<File>([]);
  var downloadURL = Rx<String?>(null);
  var allFiles = RxList<Map<String, String>>([]);
  final RxBool isSearchVisible = false.obs;
  final TextEditingController searchController = TextEditingController();
  var uploadProgress = 0.0.obs;
  var fullPath = ''.obs;
  var folderHistory = <String>[].obs;


  @override
  void onInit() {
    super.onInit();
    fetchAllFiles(false, folderPath: 'uploads');
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      files.value = result.paths.map((path) => File(path!)).toList();
    }
  }

  Future<void> uploadFiles({String folderPath = 'uploads'}) async {
    if (files.isEmpty) return;
    print("folderPath: $folderPath");

    Get.dialog(
      Obx(() => AlertDialog(
        title: Text('File Uploading...', style: TextStyle(color: ThemeColors.primary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 25,
                  decoration: BoxDecoration(
                    border: Border.all(color: ThemeColors.primary),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: uploadProgress.value / 100,
                      color: ThemeColors.primary,
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                ),
                Text(
                  '${uploadProgress.value.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: uploadProgress.value >= 50 ?ThemeColors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
        actions: [
          Helper.imgButton("assets/icons/close_bold.png", 12, () {
            Get.back();
          }),
        ],
      )),
      barrierDismissible: false,
    );

    for (File file in files) {
      String fileName = file.path.split('/').last;
      Reference storageRef = FirebaseStorage.instance.ref().child('$folderPath/$fileName');

      try {
        UploadTask uploadTask = storageRef.putFile(file);

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          uploadProgress.value = progress;
        });

        await uploadTask;
        String url = await storageRef.getDownloadURL();
        downloadURL.value = url;
      } catch (e) {
        print('Error uploading file: $e');
      }
    }

    Get.back();
    files.clear();
    fetchAllFiles(true, folderPath: folderPath);
  }

  Future<void> fetchAllFiles(bool dialog, {String folderPath = 'uploads'}) async {
    try {

      if(dialog){
        Get.dialog(
            Center(child: CircularProgressIndicator(color: ThemeColors.primary, backgroundColor: ThemeColors.white,))
        );
      }else{}

      if (folderHistory.isEmpty || folderHistory.last != folderPath) {
        folderHistory.add(folderPath);
      }

      allFiles.value = await Helper.fetchAllFileURLs(folderPath);
      Get.back();
    } catch (e) {
      print('Error fetching files: $e');
    }
  }

  Future<void> searchFiles(String query) async {
    if (query.isNotEmpty) {
      try {
        allFiles.value = await Helper.searchFiles(query);
      } catch (e) {
        print('Error searching files: $e');
      }
    } else {
      fetchAllFiles(true, );
    }
  }

  void goBack() {
    if (folderHistory.length > 1) {
      folderHistory.removeLast();
      fetchAllFiles(true, folderPath: folderHistory.last);
    }
  }

  void test(context) {

    print('test $folderHistory');
    // fetchAllFiles(folderPath: "uploads");

  }

}
