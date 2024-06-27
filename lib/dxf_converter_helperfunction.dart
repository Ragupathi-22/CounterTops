import 'dart:math';

class Vertex {
  final double x;
  final double y;

  Vertex(this.x, this.y);

  @override
  String toString() {
    return 'Vertex($x, $y)';
  }
}

class Polyline {
  final List<Vertex> vertices;
  final bool isClosed;

  Polyline({
    required this.vertices,
    this.isClosed = false,
  });

  @override
  String toString() {
    return 'Polyline(vertices: $vertices, isClosed: $isClosed)';
  }
}

class DXF {
  List<Polyline> entities = [];

  String toDXFString() {
    StringBuffer buffer = StringBuffer();

    // Header section
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('HEADER');
    buffer.writeln('0');
    buffer.writeln('ENDSEC');

    // Entities section
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('ENTITIES');

    // Add top space
    double topSpace = 50.0; // Adjust as needed
    buffer.writeln('0');
    buffer.writeln('LINE');
    buffer.writeln('8');
    buffer.writeln('LAYER'); // Specify top space layer
    buffer.writeln('10');
    buffer.writeln('0.0'); // Start X
    buffer.writeln('20');
    buffer.writeln('$topSpace'); // Start Y
    buffer.writeln('11');
    buffer.writeln('100.0'); // End X (adjust as needed)
    buffer.writeln('21');
    buffer.writeln('$topSpace'); // End Y (adjust as needed)

    double maxY = getMaxY(entities) + topSpace;

    for (var polyline in entities) {
      buffer.writeln('0');
      buffer.writeln('POLYLINE');
      buffer.writeln('8');
      buffer.writeln('0'); // Layer 0

      // Set color to deep black (color number 0)
      buffer.writeln('62');
      buffer.writeln('0'); // Color number (0 = black)

      buffer.writeln('66');
      buffer.writeln('1'); // Closed flag (1=closed, 0=open)

      for (var vertex in polyline.vertices) {
        buffer.writeln('0');
        buffer.writeln('VERTEX');
        buffer.writeln('10');
        buffer.writeln('${-vertex.x}');
        buffer.writeln('20');
        buffer.writeln('${vertex.y + topSpace}'); // Adjust Y for top space
      }

      if (polyline.isClosed) {
        buffer.writeln('0');
        buffer.writeln('SEQEND');
      }

      // Add dimensions
      addDimensions(buffer, polyline, topSpace);
    }

    // Add bottom space
    double bottomSpace = 50.0; // Adjust as needed
    buffer.writeln('0');
    buffer.writeln('LINE');
    buffer.writeln('8');
    buffer.writeln('LAYER'); // Specify bottom space layer
    buffer.writeln('10');
    buffer.writeln('0.0'); // Start X
    buffer.writeln('20');
    buffer.writeln('${maxY + bottomSpace}'); // Start Y (adjust as needed)
    buffer.writeln('11');
    buffer.writeln('100.0'); // End X (adjust as needed)
    buffer.writeln('21');
    buffer.writeln('${maxY + bottomSpace}'); // End Y (adjust as needed)

    buffer.writeln('0');
    buffer.writeln('ENDSEC');
    buffer.writeln('0');
    buffer.writeln('EOF');

    return buffer.toString();
  }

  void addDimensions(
      StringBuffer buffer, Polyline polyline, double textHeight) {
    if (polyline.vertices.length >= 2) {
      for (int i = 0; i < polyline.vertices.length - 1; i++) {
        final startVertex = polyline.vertices[i];
        final endVertex = polyline.vertices[i + 1];

        // Calculate dimension text position
        final textX = (startVertex.x + endVertex.x) / 2;
        final textY = (startVertex.y + endVertex.y) / 2;

        // Calculate distance between vertices
        final distance = calculateDistance(startVertex, endVertex);

        // Add dimension text
        buffer.writeln('0');
        buffer.writeln('TEXT');
        buffer.writeln('8');
        buffer.writeln('DIMENSIONS'); // Specify dimension layer
        buffer.writeln('10');
        buffer.writeln('-$textX'); // Text position X (adjust as needed)
        buffer.writeln('20');
        buffer.writeln(
            '${textY + textHeight / 4}'); // Text position Y (adjust as needed)
        buffer.writeln('40');
        buffer.writeln(
            '${textHeight * 0.15}'); // Text height (reduce further if needed)
        buffer.writeln('1');
        buffer.writeln(distance.toStringAsFixed(2)); // Text content
      }
    }
  }

// Function to calculate distance between two vertices
  double calculateDistance(Vertex v1, Vertex v2) {
    return sqrt(pow(v2.x - v1.x, 2) + pow(v2.y - v1.y, 2));
  }

  double getMaxY(List<Polyline> entities) {
    double maxY = 0.0;
    for (var polyline in entities) {
      for (var vertex in polyline.vertices) {
        if (vertex.y > maxY) {
          maxY = vertex.y;
        }
      }
    }
    return maxY;
  }
}
