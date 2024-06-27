import 'dart:ui';
import 'package:countertops/common.dart';

// Rectangle class extending Shape, representing a rectangular object
class Rectangle extends Shape {
  Offset topLeft; // Top-left corner of the rectangle
  Offset bottomRight; // Bottom-right corner of the rectangle

  // Getter for the width of the rectangle
  double get width => bottomRight.dx - topLeft.dx;

  // Getter for the height of the rectangle
  double get height => bottomRight.dy - topLeft.dy;

  // Setter for the width of the rectangle
  set width(double value) {
    bottomRight = Offset(
        topLeft.dx + value, bottomRight.dy); // Update bottom-right x coordinate
  }

  // Setter for the height of the rectangle
  set height(double value) {
    bottomRight = Offset(
        bottomRight.dx, topLeft.dy + value); // Update bottom-right y coordinate
  }

  // Constructor initializing the rectangle with top-left and bottom-right points
  Rectangle(this.topLeft, this.bottomRight);

  // Method to move the rectangle by dx and dy
  @override
  void move(double dx, double dy) {
    topLeft = Offset(topLeft.dx + dx, topLeft.dy + dy); // Update top-left point
    bottomRight = Offset(
        bottomRight.dx + dx, bottomRight.dy + dy); // Update bottom-right point
  }

  // Method to check if a given point is within the rectangle
  @override
  bool contains(Offset offset) {
    return offset.dx >= topLeft.dx &&
        offset.dx <= bottomRight.dx &&
        offset.dy >= topLeft.dy &&
        offset.dy <=
            bottomRight
                .dy; // Check if the point is within the bounds of the rectangle
  }
}
