import 'dart:ui';
import 'package:countertops/common.dart';

// LShape class extending Shape, representing an L-shaped object
class LShape extends Shape {
  Offset start; // Starting point of the L-shape
  double width1; // Width of the first rectangle in the L-shape
  double height1; // Height of the first rectangle in the L-shape
  double width2; // Width of the second rectangle in the L-shape
  double height2; // Height of the second rectangle in the L-shape

  // Constructor initializing the L-shape with start and end points
  LShape(this.start, Offset end)
      : width1 = (end.dx - start.dx).abs(),
        height1 = (end.dy - start.dy).abs(),
        width2 = (end.dx - start.dx).abs() / 2,
        height2 = (end.dy - start.dy).abs() / 2;

  // Method to move the shape by dx and dy
  @override
  void move(double dx, double dy) {
    start = Offset(start.dx + dx, start.dy + dy); // Update start point
  }

  // Method to check if a given point is within the L-shape
  @override
  bool contains(Offset offset) {
    final topLeft = start;
    final bottomRight1 = Offset(start.dx + width1,
        start.dy + height1); // Bottom-right of first rectangle
    final topLeft2 = Offset(start.dx + width1 - width2,
        start.dy + height1); // Top-left of second rectangle
    final bottomRight2 = Offset(start.dx + width1,
        start.dy + height1 - height2); // Bottom-right of second rectangle

    // Check if the point is within the first rectangle
    final inFirstRect = offset.dx >= topLeft.dx &&
        offset.dx <= bottomRight1.dx &&
        offset.dy >= topLeft.dy &&
        offset.dy <= bottomRight1.dy;

    // Check if the point is within the second rectangle
    final inSecondRect = offset.dx >= topLeft2.dx &&
        offset.dx <= bottomRight2.dx &&
        offset.dy >= topLeft2.dy &&
        offset.dy <= bottomRight2.dy;

    return inFirstRect ||
        inSecondRect; // Return true if point is in either rectangle
  }
}
