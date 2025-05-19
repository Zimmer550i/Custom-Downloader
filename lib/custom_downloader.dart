import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class CustomDownloader {
  /// Downloads a file from the given [url] and saves it locally on the device.
  ///
  /// Supports Android and iOS platforms with proper handling of file storage locations:
  /// - On Android, saves using `flutter_file_downloader` package.
  /// - On iOS, can save either to the app documents directory or directly to Photos gallery.
  ///
  /// ### Required Packages (add these to your pubspec.yaml):
  /// ```yaml
  /// dio: ^5.8.0+1
  /// path_provider: ^2.1.5
  /// flutter_file_downloader: ^2.1.0
  /// image_gallery_saver_plus: ^4.0.1
  /// ```
  ///
  /// ### Android Permissions (add to AndroidManifest.xml):
  /// ```xml
  /// <uses-permission android:name="android.permission.INTERNET"/>
  /// <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
  /// ```
  ///
  /// ### iOS Info.plist entries (add to ios/Runner/Info.plist):
  /// ```xml
  /// <key>LSSupportsOpeningDocumentsInPlace</key>
  /// <true/>
  /// <key>UIFileSharingEnabled</key>
  /// <true/>
  /// <key>NSPhotoLibraryAddUsageDescription</key>
  /// <string>We need permission to save photos and videos to your library for your convenience.</string>
  /// <key>NSPhotoLibraryUsageDescription</key>
  /// <string>We need permission to access your photo library to view and select your photos and videos.</string>
  /// ```
  ///
  /// ### Parameters:
  /// - [url]: The URL of the file to download.
  /// - [fileName]: Optional custom file name. Defaults to the last segment of the URL.
  /// - [saveToPhotos]: For iOS only. If true, saves the file to the Photos gallery instead of app documents directory.
  /// - [onProgress]: Optional callback providing download progress as a double (0.0 to 1.0).
  ///
  /// ### Returns:
  /// - Returns a [Future<String>] with the saved file path on success.
  /// - Throws an [Exception] if the platform is unsupported or download fails.
  ///
  /// Example usage:
  /// ```dart
  /// final path = await CustomDownloader.download(
  ///   url: 'https://example.com/file.mp4',
  ///   fileName: 'my_video.mp4',
  ///   saveToPhotos: true,
  ///   onProgress: (progress) {
  ///     print('Download progress: ${progress * 100}%');
  ///   },
  /// );
  /// print('File saved at $path');
  /// ```
  static Future<String> download({
    required String url,
    String? fileName,
    bool saveToPhotos = false,
    void Function(double)? onProgress,
  }) {
    if (fileName == null || fileName.trim() == "") {
      fileName = url.split("/").last;
    }
    if (Platform.isAndroid) {
      return _androidDownload(url, fileName, onProgress);
    } else if (Platform.isIOS) {
      if (saveToPhotos) {
        return _iosDownloadToPhotos(
          url: url,
          fileName: fileName,
          onProgress: onProgress,
        );
      } else {
        return _iosDownload(
          url: url,
          fileName: fileName,
          onProgress: onProgress,
        );
      }
    } else {
      throw Exception("Download not supported for this Platform");
    }
  }

  static Future<String> _androidDownload(
    String url,
    String fileName,
    void Function(double)? onProgress,
  ) async {
    final file = await FileDownloader.downloadFile(
      url: url,
      name: fileName,
      onProgress: (fileName, progress) {
        if (onProgress != null) {
          onProgress(progress);
        }
      },
    );
    if (file != null) {
      return file.path;
    } else {
      throw Exception('Download failed!');
    }
  }

  static Future<String> _iosDownloadToPhotos({
    required String url,
    required String fileName,
    void Function(double)? onProgress,
  }) async {
    final dio = Dio();
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/$fileName';

    await dio.download(
      url,
      tempPath,
      onReceiveProgress: (received, total) {
        if (onProgress != null) {
          onProgress(received / total);
        }
      },
    );

    final result = await ImageGallerySaverPlus.saveFile(
      tempPath,
      isReturnPathOfIOS: true,
    );
    return result['filePath'] ?? "Download failed!";
  }

  static Future<String> _iosDownload({
    required String url,
    required String fileName,
    void Function(double)? onProgress,
  }) async {
    final dio = Dio();
    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/$fileName';

    await dio.download(
      url,
      savePath,
      onReceiveProgress: (received, total) {
        if (onProgress != null) {
          onProgress(received / total);
        }
      },
    );

    return savePath;
  }
}
