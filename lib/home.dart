import 'dart:io';
import 'package:countertops/common.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'rectangle.dart';
import 'Lshape.dart';
import 'dxf_converter_helperfunction.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Offset? start; // Starting point for drawing shapes
  Offset? end; // Ending point for drawing shapes
  List<Shape> shapes = []; // List to store all shapes drawn
  Shape? selectedShape; // Currently selected shape for editing
  Offset? dragStartOffset; // Starting offset for dragging a shape
  bool isLShapeMode = false; // Flag to determine the shape mode

  List<Offset> customPoints = []; // List to store custom points
  double canvasHeight = 0.0; // Add a variable for canvas height

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF80A873),
        title: const Text(
          'CounterTops',
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(
                  context, '/login'); // Navigate to login screen
            },
            icon: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.logout_outlined, color: Color(0XFF004E05)),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        isLShapeMode = false; // Set mode to rectangle
                        start = null;
                        end = null;
                        customPoints.clear(); // Clear custom points
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (states) => isLShapeMode
                            ? const Color.fromARGB(255, 89, 190, 52)
                            : const Color(
                                0XFF004E05), // Change color based on mode
                      ),
                      shape: WidgetStateProperty.all<OutlinedBorder>(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      minimumSize: WidgetStateProperty.all<Size>(
                        const Size(double.infinity, 50),
                      ),
                      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.zero,
                      ),
                    ),
                    child: const Text(
                      'Rectangle',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        isLShapeMode = true; // Set mode to L-shape
                        start = null;
                        end = null;
                        customPoints.clear(); // Clear custom points
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (states) => isLShapeMode
                            ? const Color(0XFF004E05)
                            : const Color.fromARGB(
                                255, 89, 190, 52), // Change color based on mode
                      ),
                      shape: WidgetStateProperty.all<OutlinedBorder>(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      minimumSize: WidgetStateProperty.all<Size>(
                        const Size(double.infinity, 50),
                      ),
                      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.zero,
                      ),
                    ),
                    child: const Text(
                      'L-Shape',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final directory =
                          await getExternalStorageDirectory(); // Use getExternalStorageDirectory for root directory access
                      final counterTopsDirectory =
                          Directory('${directory!.path}/CounterTops');

                      // Create CounterTops directory if it doesn't exist
                      if (!(await counterTopsDirectory.exists())) {
                        await counterTopsDirectory.create();
                      }

                      final filePath =
                          '${counterTopsDirectory.path}/shapes.dxf'; // Define file path
                      print('Saving DXF to $filePath');

                      final dxf = DXF();

                      for (final shape in shapes) {
                        if (shape is Rectangle) {
                          dxf.entities.add(Polyline(
                            vertices: [
                              Vertex(shape.topLeft.dx,
                                  canvasHeight - shape.topLeft.dy),
                              Vertex(shape.bottomRight.dx,
                                  canvasHeight - shape.topLeft.dy),
                              Vertex(shape.bottomRight.dx,
                                  canvasHeight - shape.bottomRight.dy),
                              Vertex(shape.topLeft.dx,
                                  canvasHeight - shape.bottomRight.dy),
                              Vertex(shape.topLeft.dx,
                                  canvasHeight - shape.topLeft.dy),
                            ],
                            isClosed: true,
                          ));
                        } else if (shape is LShape) {
                          dxf.entities.add(Polyline(
                            vertices: [
                              Vertex(shape.start.dx,
                                  canvasHeight - shape.start.dy),
                              Vertex(shape.start.dx + shape.width1,
                                  canvasHeight - shape.start.dy),
                              Vertex(
                                  shape.start.dx + shape.width1,
                                  canvasHeight -
                                      (shape.start.dy + shape.height2)),
                              Vertex(
                                  shape.start.dx + shape.width2,
                                  canvasHeight -
                                      (shape.start.dy + shape.height2)),
                              Vertex(
                                  shape.start.dx + shape.width2,
                                  canvasHeight -
                                      (shape.start.dy + shape.height1)),
                              Vertex(
                                  shape.start.dx,
                                  canvasHeight -
                                      (shape.start.dy + shape.height1)),
                              Vertex(shape.start.dx,
                                  canvasHeight - shape.start.dy),
                            ],
                            isClosed: true,
                          ));
                        }
                      }

                      final file = File(filePath);
                      await file.writeAsString(
                          dxf.toDXFString()); // Write DXF string to file
                      print('DXF file saved successfully');

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Export DXF'),
                          content: const Text(
                              'DXF file has been saved successfully!'), // Show success dialog
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                        const Color.fromARGB(255, 143, 214, 145),
                      ),
                      shape: WidgetStateProperty.all<OutlinedBorder>(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      minimumSize: WidgetStateProperty.all<Size>(
                        const Size(double.infinity, 50),
                      ),
                      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.zero,
                      ),
                    ),
                    child: const Text(
                      'Export DXF',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                canvasHeight = constraints.maxHeight; // Set canvas height
                return GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      selectedShape = _getShapeAtPosition(details
                          .localPosition); // Get the shape at the pan start position
                      if (selectedShape != null) {
                        dragStartOffset =
                            details.localPosition; // Set drag start offset
                      } else {
                        start = details.localPosition; // Set start position
                        end = details.localPosition; // Set end position
                      }
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      if (selectedShape != null && dragStartOffset != null) {
                        final dx =
                            details.localPosition.dx - dragStartOffset!.dx;
                        final dy =
                            details.localPosition.dy - dragStartOffset!.dy;
                        selectedShape!.move(dx, dy); // Move the selected shape
                        dragStartOffset =
                            details.localPosition; // Update drag start offset
                      } else {
                        end = details.localPosition; // Update end position
                      }
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      if (selectedShape != null) {
                        selectedShape = null; // Deselect the shape
                        dragStartOffset = null; // Reset drag start offset
                      } else {
                        if (start != null && end != null) {
                          if (isLShapeMode) {
                            shapes.add(LShape(start!, end!)); // Add L-shape
                          } else {
                            shapes
                                .add(Rectangle(start!, end!)); // Add rectangle
                          }
                          start = null; // Reset start position
                          end = null; // Reset end position
                        }
                      }
                    });
                  },
                  onDoubleTapDown: (details) {
                    setState(() {
                      selectedShape = _getShapeAtPosition(details
                          .localPosition); // Get the shape at the double-tap position
                      if (selectedShape != null) {
                        _showEditDialog(
                            selectedShape!); // Show edit dialog for the shape
                      }
                    });
                  },
                  child: CustomPaint(
                    painter: ShapePainter(
                      shapes: shapes,
                      start: start,
                      end: end,
                      isLShapeMode: isLShapeMode,
                      customPoints: customPoints,
                    ),
                    child: Container(),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                shapes.clear(); // Clear all shapes
              });
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Shape? _getShapeAtPosition(Offset position) {
    for (final shape in shapes) {
      if (shape.contains(position)) {
        // Check if shape contains the position
        return shape;
      }
    }
    return null; // Return null if no shape is found at the position
  }

  void _showEditDialog(Shape shape) {
    final TextEditingController widthController = TextEditingController();
    final TextEditingController heightController = TextEditingController();
    final TextEditingController width1Controller = TextEditingController();
    final TextEditingController height1Controller = TextEditingController();
    final TextEditingController width2Controller = TextEditingController();
    final TextEditingController height2Controller = TextEditingController();

    if (shape is Rectangle) {
      widthController.text = shape.width.toString(); // Set width for rectangle
      heightController.text =
          shape.height.toString(); // Set height for rectangle
    } else if (shape is LShape) {
      width1Controller.text = shape.width1.toString(); // Set width1 for L-shape
      height1Controller.text =
          shape.height1.toString(); // Set height1 for L-shape
      width2Controller.text = shape.width2.toString(); // Set width2 for L-shape
      height2Controller.text =
          shape.height2.toString(); // Set height2 for L-shape
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Shape'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                if (shape is Rectangle)
                  Column(
                    children: [
                      TextField(
                        controller: widthController,
                        decoration: const InputDecoration(labelText: 'Width'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: heightController,
                        decoration: const InputDecoration(labelText: 'Height'),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                if (shape is LShape)
                  Column(
                    children: [
                      TextField(
                        controller: width1Controller,
                        decoration: const InputDecoration(labelText: 'Width 1'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: height1Controller,
                        decoration:
                            const InputDecoration(labelText: 'Height 1'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: width2Controller,
                        decoration: const InputDecoration(labelText: 'Width 2'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: height2Controller,
                        decoration:
                            const InputDecoration(labelText: 'Height 2'),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                Container(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (shape is Rectangle) {
                    final width = double.tryParse(widthController.text);
                    final height = double.tryParse(heightController.text);
                    if (width != null && height != null) {
                      shape.width = width; // Update width
                      shape.height = height; // Update height
                    }
                  } else if (shape is LShape) {
                    final width1 = double.tryParse(width1Controller.text);
                    final height1 = double.tryParse(height1Controller.text);
                    final width2 = double.tryParse(width2Controller.text);
                    final height2 = double.tryParse(height2Controller.text);
                    if (width1 != null &&
                        height1 != null &&
                        width2 != null &&
                        height2 != null) {
                      shape.width1 = width1; // Update width1
                      shape.height1 = height1; // Update height1
                      shape.width2 = width2; // Update width2
                      shape.height2 = height2; // Update height2
                    }
                  }
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
