import 'package:flutter/material.dart';

class EditButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;

  const EditButton({
    super.key,
    required this.onTap,
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  State<EditButton> createState() => _EditButtonState();
}

class _EditButtonState extends State<EditButton> {
  double _scale = 1.0;

  void _onTapDown(_) {
    setState(() => _scale = 0.9);
  }

  void _onTapUp(_) {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(widget.icon, color: widget.iconColor),
        ),
      ),
    );
  }
}
