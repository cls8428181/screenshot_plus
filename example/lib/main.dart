import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenshot_plus/flutter_screenshot_plus.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScreenShotController controller = ScreenShotController();
  ScrollController scrollController = ScrollController();

  Future<File> _createImageFile(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/image.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  screenshot() async {
    ///截长图
    final image =
        await controller.captureLongWidget(scrollController: scrollController);
    if (image == null) {
      return;
    }

    ///unit8List转file
    final file = await _createImageFile(image);

    ///分享图片 Share三方库
    await Share.shareXFiles([XFile(file.path)],
        text: 'Check out this screenshot!');
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShot(
      controller: controller,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: ListView.separated(
            controller: scrollController,
            itemBuilder: (context, index) => Card(
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Text("$index"),
                  ),
                ),
            separatorBuilder: (context, index) => const SizedBox(
                  height: 12,
                ),
            itemCount: 50),
        floatingActionButton: SizedBox(
          width: 100,
          height: 50,
          child: FloatingActionButton(
            onPressed: () => screenshot(),
            tooltip: 'Increment',
            child: const Text("ScreenShot"),
          ),
        ),
      ),
    );
  }
}
