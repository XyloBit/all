import 'package:allsocialmedia/file_upload/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller.dart';
import '../helper/helper.dart';

class FileUploadScreen extends StatelessWidget {
  FileUploadScreen({super.key});

  final FileUploadController controller =
      Get.put(FileUploadController(), tag: 'FileUploadController');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => controller.allFiles.isNotEmpty
                  ? RefreshIndicator(
                      backgroundColor: ThemeColors.primary,
                      color: ThemeColors.white,
                      onRefresh: () async {
                        await controller.fetchAllFiles(false,);
                      },
                      child: ListView.builder(
                        itemCount: controller.allFiles.length,
                        itemBuilder: (context, index) {
                          final item = controller.allFiles[index];
                          final name = item['name'] ?? '';
                          final imgUrl = item['url'] ?? '';
                          final type = item['type'] ?? 'file';
                          final fullPath = item['fullPath'] ?? '';

                          if (type == 'folder') {
                            print("folderName: $name");
                          }

                          return Column(
                            children: [
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: type == 'folder'
                                    ? Container(
                                        height: 200,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: ThemeColors.primary,
                                              width: 2),
                                          image: const DecorationImage(
                                            image: AssetImage(
                                                "assets/icons/folder.png"),
                                            fit: BoxFit.fitHeight,
                                          ),
                                        ),
                                        child:
                                            Helper.fileList(name, imgUrl, () {
                                          controller.fetchAllFiles(true, folderPath: fullPath);
                                        }, folderPath: controller.folderHistory.last),
                                      )
                                    : Container(
                                        height: 200,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: name.contains(
                                                  RegExp(r'(jpg|png|HEIC)'))
                                              ? DecorationImage(
                                                  image: NetworkImage(imgUrl),
                                                  fit: BoxFit.cover,
                                                )
                                              : DecorationImage(
                                                  image: AssetImage(name.contains(RegExp(r'(mp3|aac)')) ?
                                                      "assets/icons/audio.png" : 'assets/icons/video.png'),
                                                  fit: BoxFit.fitHeight,
                                                ),
                                        ),
                                        child: Helper.fileList(
                                            name, imgUrl, () {}, folderPath: controller.folderHistory.last),
                                      ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  : Center(child: Text('loading.....', style: TextStyle(fontWeight: FontWeight.bold),)),
            ),
          ),
        ],
      ),
      floatingActionButton: Obx(() => Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (controller.files.isNotEmpty)
                FloatingActionButton(
                  onPressed: ()=>controller.uploadFiles(folderPath: "${controller.folderHistory.last}"),
                  backgroundColor: ThemeColors.primary,
                  child: Icon(
                    Icons.upload,
                    color: ThemeColors.white,
                  ),
                ),
              SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                onPressed: controller.pickFiles,
                backgroundColor: ThemeColors.primary,
                child: Icon(
                  Icons.add,
                  color: ThemeColors.white,
                ),
              ),
            ],
          )),
    );
  }

  PreferredSizeWidget _appBar(context) {
    return AppBar(
      toolbarHeight: 50,
      backgroundColor: ThemeColors.primary,
      title: Obx(() {
        return controller.isSearchVisible.value
            ? SizedBox(
                width: Get.size.width,
                child: Container(
                  height: 40,
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: (query) {
                      controller.searchFiles(query);
                    },
                    textInputAction: TextInputAction.search,
                    style: TextStyle(color: ThemeColors.secondary),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      hintText: "search...",
                      hintStyle: TextStyle(color: ThemeColors.primary),
                      suffixIcon: Helper.imgButton(
                          "assets/icons/close_black.png", 10, () {
                        controller.isSearchVisible.toggle();
                        if (controller.searchController.text.isNotEmpty) {
                          controller.searchController.clear();
                          controller.searchFiles('');
                        }
                      }),
                      prefixIcon: Helper.imgButton(
                          "assets/icons/search_outline.png", 10, () {
                        controller.searchController;
                      }),
                      filled: true,
                      fillColor: ThemeColors.textFiled,
                    ),
                  ),
                ),
              )
            : Row(
                children: [
                  Obx(() {
                    return Visibility(
                      visible: controller.folderHistory.length > 1,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                            onPressed: () => controller.goBack(),
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: ThemeColors.white,
                            )),
                      ),
                    );
                  }),
                  Text(
                    'Test App',
                    style: TextStyle(color: ThemeColors.white),
                  ),
                ],
              );
      }),
      actions: [
        Obx(() {
          return controller.isSearchVisible.value
              ? Container()
              : Row(
                  children: [
                    Helper.imgButton("assets/icons/add_folder.png", 12, () {
                      Helper.addFolder(controller.fullPath.value);
                    }),
                    Helper.imgButton("assets/icons/search_outline.png", 12, () {
                      controller.isSearchVisible.toggle();
                    }),
                    // Helper.imgButton("assets/icons/apple.png", 12, () {
                    //   controller.test(context);
                    // }),
                  ],
                );
        }),
      ],
    );
  }
}
