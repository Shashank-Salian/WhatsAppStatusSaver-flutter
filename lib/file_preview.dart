import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FilePreview extends StatefulWidget {
  final String path;
  final Function onDownloadClick, onShareClick;
  final bool isVideo;
  const FilePreview(
      {super.key,
      required this.path,
      required this.onDownloadClick,
      required this.onShareClick,
      required this.isVideo});

  @override
  State<StatefulWidget> createState() => _FilePreviewState();
}

class _FilePreviewState extends State<FilePreview> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      initVideo();
    }
  }

  void initVideo() async {
    _controller = VideoPlayerController.file(File(widget.path));
    _controller.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: false,
      allowMuting: true,
      showOptions: false,
      aspectRatio: _controller.value.aspectRatio
    );
    _chewieController?.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Image preview"),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            width: 50,
            child: InkWell(
                child: const Icon(Icons.download),
                onTap: () {
                  widget.onDownloadClick();
                }),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            width: 50,
            child: InkWell(
              child: const Icon(Icons.share),
              onTap: () {
                widget.onShareClick();
              },
            ),
          )
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        heightFactor: double.maxFinite,
        widthFactor: double.maxFinite,
        child: widget.isVideo
            ? _chewieController != null
                ? AspectRatio( aspectRatio: _controller.value.aspectRatio,child: Chewie(controller: _chewieController!))
                : const CircularProgressIndicator(
                    backgroundColor: Colors.grey,
                  )
            : Image.file(File(widget.path)),
      ),
    );
  }
}
