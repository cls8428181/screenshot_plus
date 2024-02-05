
## Languages

- [English](./README.md)

### Screenshot Plus

`Screenshot Plus`是一个高效的Flutter插件，用于捕获Flutter应用中的任何小部件（Widget）的当前状态。无论是当前屏幕上可见的小部件，还是不在屏幕中但需要以编程方式捕获的小部件，甚至是超长列表，`Screenshot Plus`都能轻松应对。

### 功能特点

- **捕获当前屏幕小部件**: 快速捕获当前屏幕上的任何小部件，并将其保存为图片。
- **从任意小部件生成图片**: 即使小部件当前不在屏幕上，也能从任意小部件生成图片。
- **捕获长列表**: 专门为长列表设计的捕获功能，无论列表多长，都能完整捕获。

### 安装

在`pubspec.yaml`文件中添加以下依赖：

```yaml
dependencies:
  flutter_screenshot_plus: ^最新版本
```

然后运行`flutter packages get`来安装插件。

### 使用方法

```dart
ScreenShot(
    controller: controller,
    child: your_child,
);

///创建controller
ScreenShotController controller = ScreenShotController();

```

#### 捕获当前屏幕上的小部件

```dart
Uint8List? image = await controller.capture(
  pixelRatio: 1.5, // 可选，设定像素比
  delay: Duration(milliseconds: 20), // 可选，截图前的延迟
);
```

#### 从任意小部件生成图片

```dart
Uint8List image = await controller.captureFromWidget(
  MyWidget(), // 将要捕获的小部件
  delay: Duration(seconds: 1), // 可选，生成图片前的延迟
  pixelRatio: 1.5, // 可选，设定像素比
  context: context, // 可选，当前的BuildContext
  targetSize: Size(1080, 1920), // 可选，目标大小
);
```

#### 捕获长列表

```dart
Uint8List? longImage = await controller.captureLongWidget(
  scrollController: myScrollController, // 必须，长列表的ScrollController
  extraImage: [ImageParam(...)], // 可选，额外的图片，如头部、尾部或水印
  maxHeight: 10000, // 可选，最大高度限制
  pixelRatio: 1.5, // 可选，设定像素比
  backgroundColor: Colors.white, // 可选，背景色，默认为白色
  format: ShotFormat.png, // 可选，图片格式，png或jpeg
  quality: 100, // 可选，图片质量，0~100
);
```

### 参数说明

- `pixelRatio`: 设定输出图片的像素比，默认使用设备的像素比。
- `delay`: 在捕获前等待的时间，有助于等待动画完成。
- `backgroundColor`: 为捕获的小部件设置背景色，默认为白色。
- `format`: 设置输出图片的格式，支持PNG和JPEG。
- `quality`: 设置JPEG图片的质量，范围是0到100。对PNG格式无效。

### 贡献

如果你有任何建议或问题，请通过GitHub Issues提交。

### 许可证

`Screenshot Plus`根据MIT许可证发布。详情请查看LICENSE文件。

### 感谢
screenshot

---