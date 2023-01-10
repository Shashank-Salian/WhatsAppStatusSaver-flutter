import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'android_methods.dart';

class StatusCard extends StatefulWidget {
  final String img;
  final FileSystemEntity statusFile;
  final bool isVideo;
  const StatusCard(
      {super.key,
      required this.img,
      required this.statusFile,
      this.isVideo = false});

  @override
  State<StatefulWidget> createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard> {
  Uint8List? _videoImage;
  static const String statusSaverPath =
      "/storage/emulated/0/Pictures/StatusSaver";

  @override
  void initState() {
    super.initState();
    setThumbnailFromVideo();
    createStatusSaveDirectory();
  }

  void setThumbnailFromVideo() {
    VideoThumbnail.thumbnailData(
      video: widget.statusFile.path,
      imageFormat: ImageFormat.PNG,
      maxHeight: 480,
      maxWidth: 720,
    ).then((value) {
      setState(() {
        _videoImage = value;
      });
    });
  }

  void createStatusSaveDirectory() {
    Directory(statusSaverPath).create(recursive: true).catchError((Object e) {
      Fluttertoast.showToast(
        msg: "Could not create directory to save status",
        toastLength: Toast.LENGTH_LONG,
      );
    });
  }

  bool fileExists(String fileName) {
    return File("$statusSaverPath/$fileName").existsSync();
  }

  String getFileName() {
    var now = DateTime.now();
    var fileName =
        "${widget.isVideo ? "VID" : "IMG"}${now.year.toString().substring(2)}${now.month}${now.day}${now.hour}${now.minute}.${widget.isVideo ? "mp4" : "jpg"}";

    int i = 0;
    while (fileExists(fileName)) {
      if (i != 0) {
        fileName = fileName.replaceAll(RegExp(r"\(\d+\)"), "(${++i})");
        continue;
      }
      var fileNameAndExt = fileName.split(".");
      fileName = "${fileNameAndExt[0]}(${++i}).${fileNameAndExt[1]}";
    }

    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: Ink.image(
              image: widget.isVideo
                  ? _videoImage == null
                      ? Image.asset(
                          "images/loading.png",
                          width: 64,
                        ).image
                      : Image.memory(_videoImage!).image
                  : Image.file(
                      File(widget.img),
                    ).image,
              fit: _videoImage == null ? BoxFit.scaleDown : BoxFit.cover,
              child: InkWell(
                onTap: () {
                  // TODO: Implement Image preview
                  debugPrint("ImagePreview");
                },
              ),
            ),
          ),
          Container(
            color: Colors.black12,
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: InkWell(
                      onTap: () {
                        String finalStatusPath =
                            "$statusSaverPath/${getFileName()}";
                        File(widget.statusFile.path)
                            .copy(finalStatusPath)
                            .then((value) async {
                          await AndroidMethods.sendMediaScannerBroadcast(finalStatusPath);
                          Fluttertoast.showToast(
                            msg: "Saved...",
                            toastLength: Toast.LENGTH_LONG,
                          );
                        }).catchError((Object e) {
                          Fluttertoast.showToast(
                            msg: "Could not save the file!",
                            toastLength: Toast.LENGTH_LONG,
                          );
                        });
                      },
                      child: const Icon(
                        Icons.download,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: InkWell(
                      onTap: () {
                        Share.shareXFiles([XFile(widget.statusFile.path)]);
                      },
                      child: const Icon(
                        Icons.share,
                        color: Colors.black,
                      ),
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
}
