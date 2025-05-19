# Custom Downloader

A Flutter project to download files from URLs and save them locally on Android and iOS devices.

## Features

- Downloads files from any URL.
- Supports both Android and iOS platforms.
- On Android, files are saved using the `flutter_file_downloader` package.
- On iOS, files can be saved either to the app documents directory or directly to the Photos gallery.
- Provides download progress updates via a callback.

## Getting Started

This project is a starting point for a Flutter application that handles file downloads with proper platform-specific storage handling.

### Required Packages

Add these dependencies to your `pubspec.yaml`:

```yaml
dio: ^5.8.0+1
path_provider: ^2.1.5
flutter_file_downloader: ^2.1.0
image_gallery_saver_plus: ^4.0.1
```

### Android Permissions

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### iOS Info.plist Entries

Add these keys to `ios/Runner/Info.plist` to handle file saving and photo library access:

```xml
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
<key>UIFileSharingEnabled</key>
<true/>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need permission to save photos and videos to your library for your convenience.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need permission to access your photo library to view and select your photos and videos.</string>
```

## Usage

### Download Method

Downloads a file from the given [url] and saves it locally on the device.

Supports Android and iOS platforms with proper handling of file storage locations:
- On Android, saves using `flutter_file_downloader` package.
- On iOS, can save either to the app documents directory or directly to Photos gallery.

### Parameters:
- [url]: The URL of the file to download.
- [fileName]: Optional custom file name. Defaults to the last segment of the URL.
- [saveToPhotos]: For iOS only. If true, saves the file to the Photos gallery instead of app documents directory.
- [onProgress]: Optional callback providing download progress as a double (0.0 to 1.0).

### Returns:
- Returns a [Future<String>] with the saved file path on success.
- Throws an [Exception] if the platform is unsupported or download fails.

### Example:
```dart
final path = await CustomDownloader.download(
  url: 'https://example.com/file.mp4',
  fileName: 'my_video.mp4',
  saveToPhotos: true,
  onProgress: (progress) {
    print('Download progress: ${progress * 100}%');
  },
);
print('File saved at $path');
```

---

## Helpful Links

- [flutter_file_downloader package](https://pub.dev/packages/flutter_file_downloader)
- [image_gallery_saver_plus package](https://pub.dev/packages/image_gallery_saver_plus)
- [dio package](https://pub.dev/packages/dio)
- [path_provider package](https://pub.dev/packages/path_provider)

---

Feel free to reach out if you want me to add usage examples or integration tips in Flutter widgets!
