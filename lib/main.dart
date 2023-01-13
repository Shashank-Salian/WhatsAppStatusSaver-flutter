import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:whatsapp_status_saver/android_methods.dart';
import 'package:whatsapp_status_saver/container_page.dart';
import 'package:whatsapp_status_saver/status_saver.dart';

void main() {
  runApp(const MyHomePage(title: "WhatsApp Status Saver"));
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isPermissionGranted = false;
  List<io.FileSystemEntity> _photoStatuses = [], _videoStatuses = [];
  static const Widget permissionErrorMsg = Center(
    child: Text("Please grant the permission for this app to work!"),
  );

  @override
  void initState() {
    super.initState();
    checkPermission().then((value) {
      var statusFiles = StatusSaver.getStatusAsPhotosAndVideos();
      debugPrint(statusFiles[0].toString());
      setState(() {
        _photoStatuses = statusFiles[0];
        _videoStatuses = statusFiles[1];
      });
    }).catchError((Object e) {
      debugPrint(e.toString());
      Fluttertoast.showToast(
          msg: "Something went wrong while requesting permission",
          toastLength: Toast.LENGTH_LONG);
    });
  }

  Future<void> checkPermission() async {
    String aVersion = await AndroidMethods.getAndroidVersion().catchError((Object err) {
      Fluttertoast.showToast(
          msg: "Error getting android version!",
          toastLength: Toast.LENGTH_LONG);
      debugPrint(err.toString());
    });

    if (int.parse(aVersion) <= 10) {
      if (await Permission.storage.request().isGranted) {
        setState(() {
          _isPermissionGranted = true;
        });
      }
      return;
    }

    if (await Permission.manageExternalStorage.isGranted) {
      setState(() {
        _isPermissionGranted = true;
      });
      return;
    }
    if (await Permission.manageExternalStorage.request().isGranted) {
      setState(() {
        _isPermissionGranted = true;
      });
    }
  }

  void onRefresh() {
    var statusFiles = StatusSaver.getStatusAsPhotosAndVideos();
    setState(() {
      _photoStatuses = statusFiles[0];
      _videoStatuses = statusFiles[1];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.title,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("WhatsApp Status Saver"),
            bottom: const TabBar(
              tabs: [
                Tab(text: "Photos"),
                Tab(
                  text: "Videos",
                )
              ],
            ),
          ),
          body: TabBarView(
            children: _isPermissionGranted
                ? [
                    ContainerPage(
                      data: _photoStatuses,
                      onRefresh: onRefresh,
                    ),
                    ContainerPage(
                      data: _videoStatuses,
                      onRefresh: onRefresh,
                      isVideo: true,
                    )
                  ]
                : [permissionErrorMsg, permissionErrorMsg],
          ),
          // drawer: const MyAppDrawer(),
        ),
      ),
    );
  }
}
