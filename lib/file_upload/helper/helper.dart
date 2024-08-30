import 'dart:typed_data';

import 'package:allsocialmedia/file_upload/theme.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';


class Helper {
  static const String appName = "Test App";

  static Container button(String name, Function() task, {Function()? task2}) {
    return Container(
      width: Get.size.width * 0.30,
      decoration: BoxDecoration(
          color: ThemeColors.secondary.withOpacity(0.7),
          borderRadius: BorderRadius.circular(7)),
      child: InkWell(
        onTap: () {
          task();
          if (task2 != null) {
            task2();
          }
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
            ),
          ),
        ),
      ),
    );
  }

  static Padding imgButton(String img, double circular, Function() task,) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
            color: ThemeColors.primary.withOpacity(0.8),
            borderRadius: BorderRadius.circular(circular)),
        height: 40,
        width: 40,
        child: TextButton(
          onPressed: () {
            task();
          },
          child: Image(
            image: AssetImage(img),
            color: ThemeColors.white,
          ),
        ),
      ),
    );
  }

  static Future<void> _downloadFile(String name, String url) async {
    if (await Helper.requestPermission()) {
      Directory? directory;

      try {
        directory = await getExternalStorageDirectory();
        String newPath = '';
        List<String> paths = directory!.path.split("/");
        for (int x = 1; x < paths.length; x++) {
          String folder = paths[x];
          if (folder != "Android") {
            newPath += "/" + folder;
          } else {
            break;
          }
        }
        newPath = newPath + "/Download";
        directory = Directory(newPath);

        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }

        final taskId = await FlutterDownloader.enqueue(
          url: url,
          savedDir: directory.path,
          showNotification: true,
          openFileFromNotification: true,
          fileName: name,
        );

        print('Download Task ID: $taskId');
      } catch (e) {
        print('Error: $e');
      }
    } else {
      await Helper.getPermission();
      print('Permission denied');
    }
  }

  static Future<void> _deleteFile(String fileName, {String folderPath = 'uploads'}) async {
    print("my file path: $folderPath/$fileName");
    try {
      Reference storageRef =
          FirebaseStorage.instance.ref().child('$folderPath/$fileName');
      await storageRef.delete();
      print('File deleted successfully: $fileName');
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  static Future<bool> requestPermission() async {
    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    AndroidDeviceInfo android = await plugin.androidInfo;
    Permission p =
        android.version.sdkInt < 33 ? Permission.storage : Permission.photos;

    var permission = await p.request();

    if (permission != PermissionStatus.granted) {
      permission = await p.request();
    }

    return permission == PermissionStatus.granted;
  }

  static Future<bool> getPermission() async {
    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    AndroidDeviceInfo android = await plugin.androidInfo;
    if (android.version.sdkInt < 33) {
      if (await Permission.storage.request().isGranted) {
        return true;
      } else if (await Permission.storage.request().isPermanentlyDenied) {
        await openAppSettings();
      } else if (await Permission.audio.request().isDenied) {
        return false;
      }
    } else {
      if (await Permission.photos.request().isGranted) {
        return true;
      } else if (await Permission.photos.request().isPermanentlyDenied) {
        await openAppSettings();
      } else if (await Permission.photos.request().isDenied) {
        return false;
      }
    }
    return false;
  }

  static Future<List<Map<String, String>>> fetchAllFileURLs(String folderPath) async {
    List<Map<String, String>> fileData = [];
    List<Map<String, String>> folderData = [];

    try {
      final ListResult result =
          await FirebaseStorage.instance.ref(folderPath).listAll();
      print("my data : ${result.items} => nextPageToken: ${result.nextPageToken} prefixes: ${result.prefixes}");
      for (var ref in result.items) {
        String fileName = ref.name;
        String url = await ref.getDownloadURL();
        fileData.add({
          'name': fileName,
          'url': url,
          'type': 'file',
        });
      }

      for (var prefix in result.prefixes) {
        String folderName = prefix.name;
        String fullPath = prefix.fullPath;
        folderData.add({
          'name': folderName,
          'url': '',
          'type': 'folder',
          'fullPath': fullPath,
        });
      }

      return [...folderData, ...fileData];
    } catch (e) {
      print('Error fetching URLs: $e');
      return [];
    }
  }

  static Future<List<Map<String, String>>> searchFiles(String searchQuery) async {
    List<Map<String, String>> matchedFiles = [];
    try {
      final ListResult result =
          await FirebaseStorage.instance.ref('uploads').listAll();
      for (var ref in result.items) {
        String fileName = ref.name;
        if (fileName.toLowerCase().contains(searchQuery.toLowerCase())) {
          String url = await ref.getDownloadURL();
          matchedFiles.add({
            'name': fileName,
            'url': url,
          });
        }
      }
    } catch (e) {
      print('Error searching for files: $e');
    }
    return matchedFiles;
  }

  static Widget _imgFullScreen(String imgUrl) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage("$imgUrl"),
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }

  static TextButton fileList(String name, String imgUrl, Function() task, {String folderPath = 'uploads'}) {
    return TextButton(
      onPressed: () {
        if (name.contains(RegExp(r'(jpg|png|HEIC)')) && imgUrl.isNotEmpty) {
          print('my url: $imgUrl');
          Get.to(() => _imgFullScreen(imgUrl));
        } else {
          task();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 25,
            // width: Get.width* 0.3,
            decoration: BoxDecoration(
                color: ThemeColors.primary,
                borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Text(
                name,
                style: TextStyle(fontSize: 16, color: ThemeColors.white),
              ),
            ),
          ),
          const Spacer(),
          if (imgUrl.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Helper.imgButton("assets/icons/download.png", 12, () {
                  _downloadFile(name, imgUrl);
                }),
                Helper.imgButton("assets/icons/delete.png", 12, () async {
                  await _deleteFile(name, folderPath: folderPath);
                  task();
                }),
              ],
            ),
        ],
      ),
    );
  }

  static Future<String> fileCheck(String name) async {
    String fileExtension = name.split('.').last.toUpperCase();

    if (fileExtension == 'PNG' ||
        fileExtension == 'JPG' ||
        fileExtension == 'JPEG' ||
        fileExtension == 'GIF' ||
        fileExtension == 'WEBP') {
      return "assets/icons/check_outline.png";
    } else if (fileExtension == 'CSV') {
      return 'assets/icons/csv.png';
    } else if (fileExtension == 'XLS' || fileExtension == 'XLSX') {
      return 'assets/icons/xls.png';
    } else if (fileExtension == 'MPEG' ||
        fileExtension == 'MP4' ||
        fileExtension == 'QUICKTIME' ||
        fileExtension == 'WEBM' ||
        fileExtension == '3GPP' ||
        fileExtension == '3GPP2' ||
        fileExtension == '3GPP-TT' ||
        fileExtension == 'H261' ||
        fileExtension == 'H263' ||
        fileExtension == 'H263-1998' ||
        fileExtension == 'H263-2000' ||
        fileExtension == 'H264') {
      return 'assets/icons/video.png';
    } else if (fileExtension == 'BASIC' ||
        fileExtension == 'L24' ||
        fileExtension == 'MP4' ||
        fileExtension == 'MPEG' ||
        fileExtension == 'OGG' ||
        fileExtension == '3GPP' ||
        fileExtension == '3GPP2' ||
        fileExtension == 'AC3' ||
        fileExtension == 'WEBM' ||
        fileExtension == 'AMR-NB' ||
        fileExtension == 'AMR' ||
        fileExtension == 'MP3') {
      return 'assets/icons/audio.png';
    } else if (fileExtension == 'PDF') {
      return 'assets/icons/pdf.png';
    }

    return 'assets/icons/alert_round.png';
  }

  static Future<bool> addFolder(String fullPath) async {
    final TextEditingController folderName = TextEditingController();
    bool isFolderCreated = false;
    bool isLoading = false;

    await Get.dialog(
      StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return !isLoading
            ? Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          "Create Folder",
                          style: TextStyle(
                            fontSize: 18,
                            color: ThemeColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: folderName,
                        // onChanged: (query) {
                        //   controller.searchFiles(query);
                        // },
                        textInputAction: TextInputAction.search,
                        style: TextStyle(color: ThemeColors.secondary),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          hintText: "Folder Name...",
                          hintStyle: TextStyle(color: ThemeColors.primary),
                          filled: true,
                          fillColor: ThemeColors.textFiled,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: Center(
                              child: Container(
                                height: 40,
                                width: 80,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: ThemeColors.primary,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                child: Text("Cancel",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              if (folderName.text.isNotEmpty) {
                                setState(() {
                                  isLoading = true;
                                });
                                try {
                                  Reference folderRef = FirebaseStorage.instance
                                      .ref()
                                      .child(
                                          '$fullPath/${folderName.text}/.keep');
                                  await folderRef
                                      .putData(Uint8List.fromList([]));
                                  isFolderCreated = true;
                                } catch (e) {
                                  print('Error creating folder: $e');
                                  isFolderCreated = false;
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Get.back();
                                }
                              } else {
                                print('Enter folder name');
                                ScaffoldMessenger.of(Get.context!).showSnackBar(
                                  SnackBar(content: Text('Enter folder name')),
                                );
                              }
                            },
                            child: Center(
                              child: Container(
                                height: 40,
                                width: 80,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: ThemeColors.primary,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                child: Text("Create",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : Dialog(
                backgroundColor: Colors.transparent,
                child: Center(
                    child: CircularProgressIndicator(
                  color: ThemeColors.white,
                  backgroundColor: ThemeColors.primary,
                )));
      }),
      barrierDismissible: false,
    );

    return isFolderCreated;
  }
}
