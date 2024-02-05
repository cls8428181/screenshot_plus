
---
## Languages

- [中文](./README_ZH.md)

### Screenshot Plus

`Screenshot Plus` is an efficient Flutter plugin for capturing the current state of any widget within a Flutter application. Whether it's capturing visible widgets on the current screen, generating images from widgets not currently displayed, or even capturing long lists, `Screenshot Plus` handles it with ease.

### Features

- **Capture Current Screen Widgets**: Quickly capture any widget on the current screen and save it as an image.
- **Generate Images from Any Widget**: Generate images from any widget, even if it's not currently displayed on the screen.
- **Capture Long Lists**: Specially designed for capturing long lists, ensuring the entire list is captured, no matter the length.

### Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_screenshot_plus: ^latest_version
```

Then run `flutter packages get` to install the plugin.

### Usage

```dart
ScreenShot(
    controller: controller,
    child: your_child,
);

// Create a controller
ScreenShotController controller = ScreenShotController();
```

#### Capture Current Screen Widgets

```dart
Uint8List? image = await controller.capture(
  pixelRatio: 1.5, // Optional, set the pixel ratio
  delay: Duration(milliseconds: 20), // Optional, delay before capture
);
```

#### Generate Images from Any Widget

```dart
Uint8List image = await controller.captureFromWidget(
  MyWidget(), // The widget to capture
  delay: Duration(seconds: 1), // Optional, delay before generating the image
  pixelRatio: 1.5, // Optional, set the pixel ratio
  context: context, // Optional, current BuildContext
  targetSize: Size(1080, 1920), // Optional, target size
);
```

#### Capture Long Lists

```dart
Uint8List? longImage = await controller.captureLongWidget(
  scrollController: myScrollController, // Required, the ScrollController for the long list
  extraImage: [ImageParam(...)], // Optional, extra images like headers, footers, or watermarks
  maxHeight: 10000, // Optional, maximum height limit
  pixelRatio: 1.5, // Optional, set the pixel ratio
  backgroundColor: Colors.white, // Optional, background color, defaults to white
  format: ShotFormat.png, // Optional, image format, supports png or jpeg
  quality: 100, // Optional, image quality, 0~100
);
```

### Parameters

- `pixelRatio`: Sets the pixel ratio for the output image, defaults to the device's pixel ratio.
- `delay`: The delay before capturing, useful for waiting for animations to complete.
- `backgroundColor`: Sets a background color for the captured widget, defaults to white.
- `format`: Sets the output image format, supports PNG and JPEG.
- `quality`: Sets the quality for JPEG images, range is 0 to 100. This is not applicable for PNG format.

### Contributions

If you have any suggestions or issues, please submit them through GitHub Issues.

### License

`Screenshot Plus` is released under the MIT license. See the LICENSE file for more details.

### Acknowledgements
screenshot

---