import 'package:flutter/material.dart';
import 'package:screenshot_plus/src/screenshot/screenshot.dart';
import 'dart:ui' as ui;
import 'package:screenshot_plus/src/screenshot/screenshot_controller.dart';

part "merge_painter.dart";

class ImagesMerge extends StatefulWidget {
  const ImagesMerge(
    this.imageList, {
    super.key,
    this.direction = Axis.vertical,
    this.controller,
    this.fit = true,
    this.backgroundColor,
  });

  ///List of images list, content must be ui.Image.
  ///If you have another format of image, you can transfer it to ui.Image
  ///by [ImagesMergeHelper].
  final List<ui.Image> imageList;

  ///Merge direction, default to vertical.
  final Axis direction;

  ///Whether to Scale the pictures to same width/height when pictures has
  ///different width/height,
  ///Fit width when direction is vertical, and fit height when horizontal.
  ///Default to true.
  final bool fit;

  ///background color
  final Color? backgroundColor;

  ///Controller to capture screen.
  final ScreenShotController? controller;

  @override
  State<ImagesMerge> createState() => _ImagesMergeState();
}

class _ImagesMergeState extends State<ImagesMerge> {
  int totalWidth = 0;
  int totalHeight = 0;
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        _calculate(constraint);
        return ScreenShot(
          controller: widget.controller ?? ScreenShotController(),
          child: ClipRRect(
            child: Container(
              color: widget.backgroundColor,
              child: CustomPaint(
                painter: _MergePainter(
                    widget.imageList, widget.direction, widget.fit, scale),
                size: Size(totalWidth.toDouble(), totalHeight.toDouble()),
              ),
            ),
          ),
        );
      },
    );
  }

  ///calculating width and height of canvas
  _calculate(BoxConstraints constraint) {
    //calculate the max width/height of images
    for (var image in widget.imageList) {
      if (widget.direction == Axis.vertical) {
        if (totalWidth < image.width) totalWidth = image.width;
      } else {
        if (totalHeight < image.height) totalHeight = image.height;
      }
    }
    //calculate the constraint of parent
    if (widget.direction == Axis.vertical &&
        constraint.hasBoundedWidth &&
        totalWidth > constraint.maxWidth) {
      scale = constraint.maxWidth / totalWidth;
      totalWidth = constraint.maxWidth.floor();
    } else if (widget.direction == Axis.horizontal &&
        constraint.hasBoundedHeight &&
        totalHeight > constraint.maxHeight) {
      scale = constraint.maxHeight / totalHeight;
      totalHeight = constraint.maxHeight.floor();
    }
    //calculate the opposite
    for (var image in widget.imageList) {
      if (widget.direction == Axis.vertical) {
        if (image.width < totalWidth && !widget.fit) {
          totalHeight += image.height;
        } else {
          if (!widget.fit) {
            totalHeight += (image.height * scale).floor();
          } else {
            totalHeight += (image.height * totalWidth / image.width).floor();
          }
        }
      } else {
        if (image.height < totalHeight && !widget.fit) {
          totalWidth += image.width;
        } else {
          if (!widget.fit) {
            totalWidth += (image.width * scale).floor();
          } else {
            totalWidth += (image.width * totalHeight / image.height).floor();
          }
        }
      }
    }
  }
}
