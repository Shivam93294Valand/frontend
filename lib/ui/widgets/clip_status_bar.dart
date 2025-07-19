import 'package:flutter/material.dart';
import 'package:social_media_app/app/configs/colors.dart';

class ClipStatusBar extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    // Create a rounded rectangle shape with a thumb up icon shape
    path.moveTo(0, h * 0.3);
    path.quadraticBezierTo(0, 0, w * 0.3, 0);
    path.lineTo(w * 0.7, 0);
    path.quadraticBezierTo(w, 0, w, h * 0.3);
    path.lineTo(w, h * 0.7);
    path.quadraticBezierTo(w, h, w * 0.7, h);
    path.lineTo(w * 0.3, h);
    path.quadraticBezierTo(0, h, 0, h * 0.7);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class ColorfulClipStatusBar extends StatelessWidget {
  final Widget child;
  final Color color;
  
  const ColorfulClipStatusBar({
    Key? key,
    required this.child,
    this.color = AppColors.primaryColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ClipStatusBar(),
      child: Container(
        color: color,
        child: child,
      ),
    );
  }
}

/*final w = size.width;
final h = size.height;
final path = Path();
path.quadraticBezierTo(w * 0.1, h * 0.1, w * 0.2, h * 0.1);
path.lineTo(w, h * 0.1);
path.quadraticBezierTo(w * 0.5, h * 0.1, w * 0.5, h * 0.3);
path.lineTo(w * 0.5, h * 0.7);
path.quadraticBezierTo(w * 0.5, h * 0.9, w * 0.3, h * 0.9);
path.lineTo(w, h * 0.9);
path.quadraticBezierTo(w * 0.1, h * 0.9, 0, h);
path.close();
return path;*/
