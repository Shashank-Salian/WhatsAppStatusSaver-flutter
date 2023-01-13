import 'dart:io';

abstract class StatusSaver {
  static const String statusSaverPath = "/storage/emulated/0/Pictures/StatusSaver";
  static const String waStatusFiles = "/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses";


  static bool fileExists(String fileName) {
    return File("$statusSaverPath/$fileName").existsSync();
  }

  static String _getSaveFileName(bool isVideo) {
    var now = DateTime.now();
    var fileName =
        "${isVideo ? "VID" : "IMG"}${now.year.toString().substring(2)}${now.month}${now.day}${now.hour}${now.minute}.${isVideo ? "mp4" : "jpg"}";

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


  static List<List<FileSystemEntity>> getStatusAsPhotosAndVideos() {
    List<FileSystemEntity> statuses = Directory(StatusSaver.waStatusFiles)
        .listSync();
    List<FileSystemEntity> photoFiles = [],
        videoFiles = [];
    for (var element in statuses) {
      if (element
          .statSync()
          .type == FileSystemEntityType.file) {
        if (element.path.endsWith(".mp4")) {
          videoFiles.add(element);
          continue;
        }
        if (element.path.endsWith(".jpg") ||
            element.path.endsWith(".jpeg") ||
            element.path.endsWith(".png")) {
          photoFiles.add(element);
          continue;
        }
      }
    }
    return [photoFiles, videoFiles];
  }

  static Future<File> saveFile(FileSystemEntity file, bool isVideo) {
    return File(file.path).copy("$statusSaverPath/${_getSaveFileName(isVideo)}");
  }
}