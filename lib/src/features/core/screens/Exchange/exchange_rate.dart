import 'package:flutter/material.dart';

class ExchangeRate extends StatelessWidget {
  const ExchangeRate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exchange Rates"),
        backgroundColor: Colors.green[500],
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Handle profile navigation
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Peak time charging price field
            TextField(
              decoration: const InputDecoration(
                labelText: 'Peak Time Charging Price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Discharging price field
            TextField(
              decoration: const InputDecoration(
                labelText: 'Discharging Price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            // Graph Section - CustomPainter for simple line graph
            Container(
              height: 200,
              width: double.infinity,
              child: CustomPaint(
                painter: LineChartPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final Paint pointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // Define a list of data points (for simplicity, you can replace these with actual data)
    List<Offset> points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.3),
      Offset(size.width, size.height * 0.1),
    ];

    // Draw the lines between points
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], linePaint);
    }

    // Draw the data points (optional)
    for (var point in points) {
      canvas.drawCircle(point, 5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false; // Redraw when needed
  }
}


