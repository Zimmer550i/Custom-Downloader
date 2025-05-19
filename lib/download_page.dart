import 'package:downloader/custom_downloader.dart';
import 'package:flutter/material.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  bool isLoading = false;
  bool saveToPhotos = false;
  final String videoUrl =
      "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
  final String imageUrl = "https://picsum.photos/500/500";
  final String fileUrl = "https://sakif049.web.app/CV.pdf";
  final urlCtrl = TextEditingController(text: "https://picsum.photos/500/500");
  final nameCtrl = TextEditingController(text: "sakif.jpg");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Downloader",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          spacing: 24,
          children: [
            Row(
              spacing: 24,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      urlCtrl.text = imageUrl;
                      nameCtrl.text = "image.jpg";
                    });
                  },
                  child: Text("Image"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      urlCtrl.text = videoUrl;
                      nameCtrl.text = "";
                    });
                  },
                  child: Text("Video"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      urlCtrl.text = fileUrl;
                      nameCtrl.text = "CV.pdf";
                    });
                  },
                  child: Text("File"),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text("URL: ")),
                Expanded(flex: 5, child: TextField(controller: urlCtrl)),
                IconButton(
                  onPressed: () {
                    setState(() {
                      urlCtrl.text = "";
                    });
                  },
                  icon: Icon(Icons.close_outlined),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text("Name: ")),
                Expanded(flex: 5, child: TextField(controller: nameCtrl)),
                IconButton(
                  onPressed: () {
                    setState(() {
                      nameCtrl.text = "";
                    });
                  },
                  icon: Icon(Icons.close_outlined),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: saveToPhotos,
                  onChanged: (val) {
                    setState(() {
                      saveToPhotos = !saveToPhotos;
                    });
                  },
                ),
                Expanded(child: Text("Save to photos")),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                try {
                  final text = await CustomDownloader.download(
                    url: urlCtrl.text.trim(),
                    fileName: nameCtrl.text.trim(),
                    saveToPhotos: saveToPhotos,
                    onProgress: (p0) {
                      debugPrint((p0 * 100).toString());
                    },
                  );

                  ScaffoldMessenger.of(
                    // ignore: use_build_context_synchronously
                    context,
                  ).showSnackBar(
                    SnackBar(content: Text("File Downloaded: $text")),
                  );
                  setState(() {
                    isLoading = false;
                  });
                } catch (e) {
                  print(e.toString());
                  ScaffoldMessenger.of(
                    // ignore: use_build_context_synchronously
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                  setState(() {
                    isLoading = false;
                  });
                }
              },
              child: isLoading ? CircularProgressIndicator() : Text("Download"),
            ),
          ],
        ),
      ),
    );
  }
}
