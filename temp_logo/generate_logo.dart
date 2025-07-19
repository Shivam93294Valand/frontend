import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // Logo dimensions
  const size = Size(40, 40);
  
  // Draw background
  final bgPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.fill;
  canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, bgPaint);
  
  // Draw text
  const textStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  
  final textSpan = TextSpan(
    text: 'A',
    style: textStyle,
  );
  
  final textPainter = TextPainter(
    text: textSpan,
    textDirection: TextDirection.ltr,
  );
  
  textPainter.layout(
    minWidth: 0,
    maxWidth: size.width,
  );
  
  textPainter.paint(
    canvas,
    Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    ),
  );
  
  // Convert to image
  final picture = recorder.endRecording();
  final img = await picture.toImage(size.width.toInt(), size.height.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();
  
  // Save to file
  final file = File('ic_logo.png');
  await file.writeAsBytes(buffer);
  
  print('Logo generated at ${file.path}');
  exit(0);
}