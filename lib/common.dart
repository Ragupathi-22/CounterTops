import 'package:countertops/Lshape.dart';
import 'package:countertops/rectangle.dart';
import 'package:flutter/material.dart';

// Abstract class defining common properties for shapes
abstract class Shape {
  void move(double dx, double dy); // Method to move shape by dx, dy
  bool contains(Offset offset); // Method to check if shape contains a point
}

// CustomPainter to handle drawing shapes on the canvas
class ShapePainter extends CustomPainter {
  final List<Shape> shapes; // List of shapes to be drawn
  final Offset? start; // Starting point for new shape
  final Offset? end; // Ending point for new shape
  final bool isLShapeMode; // Flag to check if drawing L-shape
  final List<Offset> customPoints; // Custom points for free drawing mode

  ShapePainter({
    required this.shapes,
    required this.start,
    required this.end,
    required this.isLShapeMode,
    required this.customPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black // Set paint color to black
      ..strokeWidth = 2.0 // Set stroke width
      ..style = PaintingStyle.stroke; // Set style to stroke (outline)

    // Loop through all shapes and draw them
    for (final shape in shapes) {
      if (shape is Rectangle) {
        final rect = Rect.fromPoints(shape.topLeft, shape.bottomRight);
        canvas.drawRect(rect, paint); // Draw rectangle
        _drawRectangleDimensions(
            canvas, shape.topLeft, shape.bottomRight); // Draw dimensions
      } else if (shape is LShape) {
        final path = Path()
          ..moveTo(shape.start.dx, shape.start.dy)
          ..lineTo(shape.start.dx + shape.width1, shape.start.dy)
          ..lineTo(
              shape.start.dx + shape.width1, shape.start.dy + shape.height1)
          ..lineTo(shape.start.dx + shape.width1 - shape.width2,
              shape.start.dy + shape.height1)
          ..lineTo(shape.start.dx + shape.width1 - shape.width2,
              shape.start.dy + shape.height1 - shape.height2)
          ..lineTo(
              shape.start.dx, shape.start.dy + shape.height1 - shape.height2)
          ..close();
        canvas.drawPath(path, paint); // Draw L-shape
        _drawLShapeDimensions(canvas, shape.start, shape.width1, shape.height1,
            shape.width2, shape.height2); // Draw dimensions
        _drawLeftLineDimension(
            canvas, shape.start, shape.height1); // Draw left line dimension
      }
    }

    // Draw the currently being created shape
    if (start != null && end != null) {
      if (isLShapeMode) {
        final width1 = (end!.dx - start!.dx).abs();
        final height1 = (end!.dy - start!.dy).abs();
        final width2 = (end!.dx - start!.dx).abs() / 2;
        final height2 = (end!.dy - start!.dy).abs() / 2;

        final path = Path()
          ..moveTo(start!.dx, start!.dy)
          ..lineTo(start!.dx + width1, start!.dy)
          ..lineTo(start!.dx + width1, start!.dy + height1)
          ..lineTo(start!.dx + width1 - width2, start!.dy + height1)
          ..lineTo(start!.dx + width1 - width2, start!.dy + height1 - height2)
          ..lineTo(start!.dx, start!.dy + height1 - height2)
          ..close();
        canvas.drawPath(path, paint); // Draw L-shape in creation

        _drawLShapeDimensions(canvas, start!, width1, height1, width2,
            height2); // Draw dimensions
        _drawLeftLineDimension(
            canvas, start!, height1); // Draw left line dimension
      } else {
        final rect = Rect.fromPoints(start!, end!);
        canvas.drawRect(rect, paint); // Draw rectangle in creation
        _drawRectangleDimensions(canvas, start!, end!); // Draw dimensions
      }
    }

    // Draw custom points if in custom mode
    if (customPoints.isNotEmpty) {
      for (int i = 0; i < customPoints.length - 1; i++) {
        canvas.drawLine(
            customPoints[i], customPoints[i + 1], paint); // Draw custom lines
      }
    }
  }

  // Draw dimensions for rectangle
  void _drawRectangleDimensions(
      Canvas canvas, Offset topLeft, Offset bottomRight) {
    final widthTextSpan = TextSpan(
      text: (bottomRight.dx - topLeft.dx).toStringAsFixed(2),
      style: const TextStyle(color: Colors.black, fontSize: 12),
    );
    final widthTextPainter = TextPainter(
      text: widthTextSpan,
      textDirection: TextDirection.ltr,
    );
    widthTextPainter.layout(minWidth: 0, maxWidth: double.infinity);
    final widthOffset = Offset(
        (topLeft.dx + bottomRight.dx) / 2 - widthTextPainter.width / 2,
        topLeft.dy - 20);
    widthTextPainter.paint(canvas, widthOffset); // Draw width

    final heightTextSpan = TextSpan(
      text: (bottomRight.dy - topLeft.dy).toStringAsFixed(2),
      style: const TextStyle(color: Colors.black, fontSize: 12),
    );
    final heightTextPainter = TextPainter(
      text: heightTextSpan,
      textDirection: TextDirection.ltr,
    );
    heightTextPainter.layout(minWidth: 0, maxWidth: double.infinity);
    final heightOffset = Offset(bottomRight.dx + 10,
        (topLeft.dy + bottomRight.dy) / 2 - heightTextPainter.height / 2);
    heightTextPainter.paint(canvas, heightOffset); // Draw height
  }

  // Draw dimensions for L-shape
  void _drawLShapeDimensions(Canvas canvas, Offset start, double width1,
      double height1, double width2, double height2) {
    final widthTextSpan = TextSpan(
      text: width1.toStringAsFixed(2),
      style: const TextStyle(color: Colors.black, fontSize: 12),
    );
    final widthTextPainter = TextPainter(
      text: widthTextSpan,
      textDirection: TextDirection.ltr,
    );
    widthTextPainter.layout(minWidth: 0, maxWidth: double.infinity);
    final widthOffset = Offset(
        start.dx + width1 / 2 - widthTextPainter.width / 2, start.dy - 20);
    widthTextPainter.paint(canvas, widthOffset); // Draw width1

    final height1TextSpan = TextSpan(
      text: height1.toStringAsFixed(2),
      style: const TextStyle(color: Colors.black, fontSize: 12),
    );
    final height1TextPainter = TextPainter(
      text: height1TextSpan,
      textDirection: TextDirection.ltr,
    );
    height1TextPainter.layout(minWidth: 0, maxWidth: double.infinity);
    final height1Offset = Offset(start.dx - height1TextPainter.width - 10,
        start.dy + height1 / 2 - height1TextPainter.height / 2);
    height1TextPainter.paint(canvas, height1Offset); // Draw height1

    final width2TextSpan = TextSpan(
      text: width2.toStringAsFixed(2),
      style: const TextStyle(color: Colors.black, fontSize: 12),
    );
    final width2TextPainter = TextPainter(
      text: width2TextSpan,
      textDirection: TextDirection.ltr,
    );
    width2TextPainter.layout(minWidth: 0, maxWidth: double.infinity);
    final width2Offset = Offset(
        start.dx + width1 - width2 / 2 - width2TextPainter.width / 2,
        start.dy + height1 + 10);
    width2TextPainter.paint(canvas, width2Offset); // Draw width2

    final height2TextSpan = TextSpan(
      text: height2.toStringAsFixed(2),
      style: const TextStyle(color: Colors.black, fontSize: 12),
    );
    final height2TextPainter = TextPainter(
      text: height2TextSpan,
      textDirection: TextDirection.ltr,
    );
    height2TextPainter.layout(minWidth: 0, maxWidth: double.infinity);
    final height2Offset = Offset(start.dx + width1 - width2 + 10,
        start.dy + height1 - height2 / 2 - height2TextPainter.height / 2);
    height2TextPainter.paint(canvas, height2Offset); // Draw height2
  }

  // Draw left line dimension
  void _drawLeftLineDimension(Canvas canvas, Offset start, double height) {
    final distanceTextSpan = TextSpan(
      text: height.toStringAsFixed(2),
      style: const TextStyle(color: Colors.black, fontSize: 12),
    );
    final distanceTextPainter = TextPainter(
      text: distanceTextSpan,
      textDirection: TextDirection.ltr,
    );
    distanceTextPainter.layout(minWidth: 0, maxWidth: double.infinity);
    final distanceOffset = Offset(start.dx - distanceTextPainter.width - 10,
        start.dy + height / 2 - distanceTextPainter.height / 2);
    distanceTextPainter.paint(canvas, distanceOffset); // Draw height
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // Repaint whenever the CustomPainter is updated
  }
}
