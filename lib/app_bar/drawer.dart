import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../file_upload/upload_home/upload_files.dart';
import 'img.dart';
import 'launch_screen.dart';


class DrawerW extends StatefulWidget {
  const DrawerW({super.key});

  @override
  _DrawerWState createState() => _DrawerWState();
}

class _DrawerWState extends State<DrawerW> {
  bool isClose = true;

  void toggleCollapse() {
    setState(() {
      isClose = !isClose;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: isClose ? Get.width * .3 : Get.width * .7,
        color: Colors.transparent,
        child: Stack(
          children: [
            Container(
              width: isClose ? Get.width * 0.2 : Get.width * 0.6,
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: Get.height * 0.1,
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                      ),
                      child: isClose
                          ? const Icon(Icons.store, color: Colors.white, size: 32)
                          : const Center(child: Text('Social', style: TextStyle(color: Colors.white, fontSize: 24))),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          DrawerItem( link: 'https://web.whatsapp.com', name: 'WhatsApp', img: AppImage.whatsapp, isClose: isClose,),
                          DrawerItem( link: 'https://www.instagram.com', name: 'Instagram', img: AppImage.instagram, isClose: isClose,),
                          DrawerItem( link: 'https://www.facebook.com', name: 'Facebook', img: AppImage.facebook, isClose: isClose,),
                          DrawerItem( link: 'https://www.x.com', name: 'Twitter', img: AppImage.twitter, isClose: isClose,),
                          DrawerItem( link: 'https://in.pinterest.com', name: 'Pinterest', img: AppImage.pinterest, isClose: isClose,),
                          // DrawerItem( link: 'https://free-for.dev/#/', name: 'Free for Developers', img: AppImage.whatsapp, isClose: isClose,),
                          DrawerItem( link: 'https://pixabay.com/images/search/', name: 'Free for Developers', img: AppImage.whatsapp, isClose: isClose,),


                          Padding(
                            padding: const EdgeInsets.only(left: 12, right: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 8,),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Get.back();
                                        Get.to(()=> FileUploadScreen());
                                      },
                                      child:  Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/img/logo.png'))),
                                      ),
                                    ),
                                    const SizedBox(width: 10,),
                                    if(isClose == false)
                                      Text('Upload Files'),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Divider(),
                                ),
                              ],
                            ),
                          )

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 90,
              left: isClose
                  ? (Get.width * 0.2) - 20
                  : (Get.width * 0.6) - 20,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: toggleCollapse,
                  child: Container(
                    height: 35,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(7)),
                      color: Colors.red.shade100,
                      border: Border.all(color: Colors.blue, width: 1.9),
                    ),
                    child: Center(
                      child: Icon(
                        isClose ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final String link;
  final String name;
  final String img;
  final bool isClose;

  const DrawerItem({super.key, required this.link, required this.name, required this.img, required this.isClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8,),
          Row(
            children: [
              InkWell(
                onTap: () {
                  Get.back();
                  Get.to(()=> PlatformScreen(url: link,));
                },
                child:  Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(image: DecorationImage(image: AssetImage('$img'))),
                ),
              ),
              const SizedBox(width: 10,),
              if(isClose == false)
                Text(name),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(),
          ),
        ],
      ),
    );

  }
}