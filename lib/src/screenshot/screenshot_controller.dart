import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../merge/images_merge_helper.dart';
import 'merge_param.dart';

enum ShotFormat { png, jpeg }

class ScreenShotController {
  /// Widget key
  late final GlobalKey containerKey;

  ScreenShotController() {
    containerKey = GlobalKey();
  }

  /// Capture the current state of the widget
  Future<Uint8List?> capture({
    double? pixelRatio,
    Duration delay = const Duration(milliseconds: 20),
  }) {
    //Delay is required. See Issue https://github.com/flutter/flutter/issues/22308
    return Future.delayed(delay, () async {
      try {
        ui.Image? image = await captureAsUiImage(
          delay: Duration.zero,
          pixelRatio: pixelRatio,
        );
        ByteData? byteData =
            await image?.toByteData(format: ui.ImageByteFormat.png);
        image?.dispose();

        Uint8List? pngBytes = byteData?.buffer.asUint8List();

        return pngBytes;
      } on Exception {
        throw (Exception);
      }
    });
  }

  /// Capture the current state of the widget
  Future<Uint8List> captureFromWidget(
    Widget widget, {
    Duration delay = const Duration(seconds: 1),
    double? pixelRatio,
    BuildContext? context,
    Size? targetSize,
  }) async {
    ui.Image image = await widgetToUiImage(widget,
        delay: delay,
        pixelRatio: pixelRatio,
        context: context,
        targetSize: targetSize);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    return byteData!.buffer.asUint8List();
  }

  /// If you are building a desktop/web application that supports multiple views, consider passing [context] so that Flutter knows which view to capture.
  static Future<ui.Image> widgetToUiImage(
    Widget widget, {
    Duration delay = const Duration(seconds: 1),
    double? pixelRatio,
    BuildContext? context,
    Size? targetSize,
  }) async {
    ///Retry counter
    int retryCounter = 3;
    bool isDirty = false;

    Widget child = widget;

    if (context != null) {
      ///Inherit Theme and MediaQuery of app
      child = InheritedTheme.captureAll(
        context,
        MediaQuery(
            data: MediaQuery.of(context),
            child: Material(
              color: Colors.transparent,
              child: child,
            )),
      );
    }

    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final fallBackView = platformDispatcher.views.first;
    final view =
        context == null ? fallBackView : View.maybeOf(context) ?? fallBackView;
    Size logicalSize =
        targetSize ?? view.physicalSize / view.devicePixelRatio; // Adapted
    Size imageSize = targetSize ?? view.physicalSize; // Adapted

    assert(logicalSize.aspectRatio.toStringAsPrecision(5) ==
        imageSize.aspectRatio
            .toStringAsPrecision(5)); // Adapted (toPrecision was not available)

    final RenderView renderView = RenderView(
      view: view,
      child: RenderPositionedBox(
          alignment: Alignment.center, child: repaintBoundary),
      configuration: ViewConfiguration(
        size: logicalSize,
        devicePixelRatio: pixelRatio ?? 1.0,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(
        focusManager: FocusManager(),
        onBuildScheduled: () {
          ///current render is dirty, mark it.
          isDirty = true;
        });

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
            container: repaintBoundary,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: child,
            )).attachToRenderTree(
      buildOwner,
    );

    ///Render Widget
    buildOwner.buildScope(
      rootElement,
    );
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    ui.Image? image;

    do {
      ///Reset the dirty flag
      isDirty = false;

      image = await repaintBoundary.toImage(
          pixelRatio: pixelRatio ?? (imageSize.width / logicalSize.width));

      ///This delay sholud increas with Widget tree Size
      await Future.delayed(delay);

      ///
      ///Check does this require rebuild
      ///
      ///
      if (isDirty) {
        ///
        ///Previous capture has been updated, re-render again.
        ///
        ///
        buildOwner.buildScope(
          rootElement,
        );
        buildOwner.finalizeTree();
        pipelineOwner.flushLayout();
        pipelineOwner.flushCompositingBits();
        pipelineOwner.flushPaint();
      }
      retryCounter--;

      ///
      ///retry untill capture is successfull
      ///
    } while (isDirty && retryCounter >= 0);
    try {
      /// Dispose All widgets
      // rootElement.visitChildren((Element element) {
      //   rootElement.deactivateChild(element);
      // });
      buildOwner.finalizeTree();
    } catch (e) {
      print(e.toString());
    }

    return image; // Adapted to directly return the image and not the Uint8List
  }

  Future<ui.Image?> captureAsUiImage(
      {double? pixelRatio = 1,
      Duration delay = const Duration(milliseconds: 20)}) {
    //Delay is required. See Issue https://github.com/flutter/flutter/issues/22308
    return Future.delayed(delay, () async {
      try {
        var findRenderObject = containerKey.currentContext?.findRenderObject();
        if (findRenderObject == null) {
          return null;
        }
        RenderRepaintBoundary boundary =
            findRenderObject as RenderRepaintBoundary;
        BuildContext? context = containerKey.currentContext;
        if (pixelRatio == null) {
          if (context != null) {
            pixelRatio = pixelRatio ?? MediaQuery.of(context).devicePixelRatio;
          }
        }
        ui.Image image = await boundary.toImage(pixelRatio: pixelRatio ?? 1);
        return image;
      } on Exception {
        throw (Exception);
      }
    });
  }

  /// [scrollController] is the scroll controller for the child widget, applicable if the child is a [ScrollView].
  /// The [pixelRatio] for the resulting image defaults to [View.of(context).devicePixelRatio].
  /// Some child widgets may lack a background, which can be set via [backgroundColor], with a default of [Colors.white].
  /// Set the image format through [format], supporting png or jpeg.
  /// Set [quality] between 0~100; however, [quality] is irrelevant if [format] is png.
  /// Supports merging [extraImage], such as headers, footers, or watermarks.
  Future<Uint8List?> captureLongWidget({
    ScrollController? scrollController,
    List<ImageParam> extraImage = const [],
    int maxHeight = 10000,
    double? pixelRatio,
    Color? backgroundColor,
    ShotFormat format = ShotFormat.png,
    int quality = 100,
  }) async {
    if (containerKey.currentContext == null) {
      return null;
    }

    var findRenderObject = containerKey.currentContext?.findRenderObject();

    if (findRenderObject == null) {
      return null;
    }

    final repaintBoundary = findRenderObject as RenderRepaintBoundary;
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final fallBackView = platformDispatcher.views.first;

    /// retrieve the view associated with the current context of the container key
    final view = containerKey.currentContext == null
        ? fallBackView
        : View.maybeOf(containerKey.currentContext!) ?? fallBackView;

    /// calculate the logical size of the view
    Size logicalSize = view.physicalSize / view.devicePixelRatio;

    /// calculate the pixel ratio for the screenshot
    final shotPixelRatio = pixelRatio ??
        MediaQuery.of(containerKey.currentContext!).devicePixelRatio;

    /// calculate the quality of the screenshot
    int shotQuality = max(10, min(100, quality));

    /// calculate the scrolling height
    double sHeight =
        scrollController?.position.viewportDimension ?? logicalSize.height;

    /// initialize the image height
    double imageHeight = 0;

    /// initialize the list of image parameters
    List<ImageParam> imageParams = [];

    /// add a header
    for (var element in extraImage) {
      if (element.offset == const Offset(-1, -1)) {
        imageParams.add(ImageParam(
          image: element.image,
          offset: Offset(0, imageHeight),
          size: element.size,
        ));
        imageHeight += element.size.height;
      }
    }

    /// check if scrolling is possible
    bool canScroll = scrollController != null &&
        (scrollController.position.maxScrollExtent) > 0;

    if (canScroll) {
      scrollController.jumpTo(0);
      await Future.delayed(const Duration(milliseconds: 200));
    }

    /// capture the first screenshot
    var firstImage = await _screenshot(repaintBoundary, shotPixelRatio);

    /// add the first screenshot to the imageParams list
    imageParams.add(ImageParam(
      image: firstImage,
      offset: Offset(0, imageHeight),
      size: logicalSize * shotPixelRatio,
    ));

    /// update the image height
    imageHeight += sHeight * shotPixelRatio;

    if (canScroll) {
      assert(() {
        scrollController.addListener(() {
          debugPrint(
              "WidgetShot scrollController?.offser = ${scrollController.offset} , scrollController?.position.maxScrollExtent = ${scrollController.position.maxScrollExtent}");
        });
        return true;
      }());

      int i = 1;

      while (true) {
        if (imageHeight >= maxHeight * shotPixelRatio) {
          break;
        }
        double lastImageHeight = 0;

        if (_canScroll(scrollController)) {
          double scrollHeight = scrollController.offset + sHeight / 10;

          if (scrollHeight > sHeight * i) {
            /// scroll to the specified position
            scrollController.jumpTo(sHeight * i);
            await Future.delayed(const Duration(milliseconds: 500));
            i++;

            /// capture the screen and add it to the list of image parameters
            Uint8List image =
                await _screenshot(repaintBoundary, shotPixelRatio);

            imageParams.add(ImageParam(
              image: image,
              offset: Offset(0, imageHeight),
              size: logicalSize * shotPixelRatio,
            ));
            imageHeight += sHeight * shotPixelRatio;
          } else if (scrollHeight > scrollController.position.maxScrollExtent) {
            /// calculate the height of the last screenshot
            lastImageHeight = scrollController.position.maxScrollExtent +
                sHeight -
                sHeight * i;

            /// scroll to the end
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
            await Future.delayed(const Duration(milliseconds: 500));

            /// capture the last screenshot
            Uint8List lastImage =
                await _screenshot(repaintBoundary, shotPixelRatio);

            imageParams.add(ImageParam(
              image: lastImage,
              offset: Offset(
                0,
                ((logicalSize.height - lastImageHeight) * shotPixelRatio),
              ),
              size: Size(logicalSize.width, lastImageHeight) * shotPixelRatio,
            ));

            imageHeight += lastImageHeight * shotPixelRatio;
          } else {
            /// scroll to the specified position
            scrollController.jumpTo(scrollHeight);
            await Future.delayed(const Duration(milliseconds: 16));
          }
        } else {
          break;
        }
      }
    }

    /// add a footer
    for (var element in extraImage) {
      if (element.offset == const Offset(-2, -2)) {
        imageParams.add(ImageParam(
          image: element.image,
          offset: Offset(0, imageHeight),
          size: element.size,
        ));
        imageHeight += element.size.height;
      }
    }

    /// add the extra images
    for (var element in extraImage) {
      if (element.offset != const Offset(-1, -1) &&
          element.offset != const Offset(-2, -2)) {
        imageParams.add(ImageParam(
          image: element.image,
          offset: element.offset,
          size: element.size,
        ));
      }
    }

    /// create the merge parameters
    final mergeParam = MergeParam(
        color: backgroundColor,
        size: Size(logicalSize.width * shotPixelRatio, imageHeight),
        format: format,
        quality: shotQuality,
        imageParams: imageParams);

    /// merge the images
    return await _merge(canScroll, mergeParam);
  }

  Future<Uint8List?> _merge(bool canScroll, MergeParam mergeParam) async {
    if (canScroll) {
      ///merge images
      final image = await ImagesMergeHelper.margeMergeParam(mergeParam);

      ///convert image to Uint8List
      return await ImagesMergeHelper.imageToUint8List(image);
    } else {
      Paint paint = Paint();
      paint
        ..isAntiAlias = false
        ..color = Colors.white;
      ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      Canvas canvas = Canvas(pictureRecorder);
      if (mergeParam.color != null) {
        canvas.drawColor(mergeParam.color!, BlendMode.color);
        canvas.save();
      }

      for (var element in mergeParam.imageParams) {
        ui.Image img = await decodeImageFromList(element.image);

        canvas.drawImage(img, element.offset, paint);
      }

      ui.Picture picture = pictureRecorder.endRecording();

      ui.Image rImage = await picture.toImage(
          mergeParam.size.width.ceil(), mergeParam.size.height.ceil());
      ByteData? byteData =
          await rImage.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    }
  }

  bool _canScroll(ScrollController? scrollController) {
    if (scrollController == null) {
      return false;
    }
    double maxScrollExtent = scrollController.position.maxScrollExtent;
    double offset = scrollController.offset;
    return !nearEqual(maxScrollExtent, offset,
        scrollController.position.physics.tolerance.distance);
  }

  Future<Uint8List> _screenshot(
      RenderRepaintBoundary repaintBoundary, double pixelRatio) async {
    ui.Image image = await repaintBoundary.toImage(pixelRatio: pixelRatio);

    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List uint8list = byteData!.buffer.asUint8List();
    return Future.value(uint8list);
  }
}
