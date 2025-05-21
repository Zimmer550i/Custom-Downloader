import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
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
  /// flutter_file_dialog: ^3.0.2
  /// image_gallery_saver_plus: ^4.0.1
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
      return _androidDownloadWithDio(url, fileName, onProgress);
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

  Future<String?> _saveFileToDownloads(
    Uint8List fileBytes,
    String fileName,
  ) async {
    final params = SaveFileDialogParams(data: fileBytes, fileName: fileName);

    final savedFilePath = await FlutterFileDialog.saveFile(params: params);

    return savedFilePath;
  }

  static Future<String> _androidDownloadWithDio(
    String url,
    String fileName,
    void Function(double)? onProgress,
  ) async {
    try {
      final dio = Dio();

      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };

      final response = await dio.get<Uint8List>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'User-Agent': 'Mozilla/5.0 (Flutter App)', 'Accept': '*/*'},
          followRedirects: true,
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
        onReceiveProgress: (received, total) {
          if (onProgress != null && total != -1) {
            onProgress(received / total);
          }
        },
      );

      final fileBytes = response.data;

      if (fileBytes == null) {
        throw Exception('Failed to download file bytes');
      }

      // Save the file bytes using the existing saveFileToDownloads method
      final savedFilePath = await CustomDownloader()._saveFileToDownloads(
        fileBytes,
        fileName,
      );

      if (savedFilePath == null) {
        throw Exception('File save was cancelled or failed');
      }

      return savedFilePath;
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }

  static Future<String> _iosDownloadToPhotos({
    required String url,
    required String fileName,
    void Function(double)? onProgress,
  }) async {
    final dio = Dio();

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

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

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

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
