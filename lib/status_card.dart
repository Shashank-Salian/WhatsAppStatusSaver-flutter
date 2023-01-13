import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:whatsapp_status_saver/file_preview.dart';
import 'package:whatsapp_status_saver/status_saver.dart';

import 'android_methods.dart';

class StatusCard extends StatefulWidget {
  final FileSystemEntity statusFile;
  final bool isVideo;
  const StatusCard(
      {super.key,
      required this.statusFile,
      this.isVideo = false});

  @override
  State<StatefulWidget> createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard> {
  Uint8List? _videoImage;

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
    Directory(StatusSaver.statusSaverPath)
        .create(recursive: true)
        .catchError((Object e) {
      Fluttertoast.showToast(
        msg: "Could not create directory to save status",
        toastLength: Toast.LENGTH_LONG,
      );
    });
  }

  void onDownloadClick() {
    StatusSaver.saveFile(widget.statusFile, widget.isVideo)
        .then((value) async {
      await AndroidMethods.sendMediaScannerBroadcast(
          value.path);
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
  }

  void onShareClick() {
    Share.shareXFiles([XFile(widget.statusFile.path)]);
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
                      File(widget.statusFile.path),
                    ).image,
              fit: _videoImage == null ? BoxFit.scaleDown : BoxFit.cover,
              child: InkWell(
                onTap: () {
                  // TODO: Implement Image preview
                  Navigator.of(context).push(PageRouteBuilder(
                      opaque: false,
                      barrierColor: Colors.black87,
                      transitionDuration: const Duration(milliseconds: 250),
                      transitionsBuilder:
                          (ctx, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: animation.drive(Tween(
                              begin: const Offset(0, 1), end: Offset.zero)),
                          child: child,
                        );
                      },
                      pageBuilder: (BuildContext ctx, _, __) {
                        return FilePreview(
                          path: widget.statusFile.path,
                          onDownloadClick: onDownloadClick,
                          onShareClick: onShareClick,
                          isVideo: widget.isVideo,
                        );
                      }));
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
                      onTap: onDownloadClick,
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
                      onTap: onShareClick,
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
