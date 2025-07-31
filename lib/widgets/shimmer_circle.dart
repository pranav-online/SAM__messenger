import 'package:flutter/material.dart';

class ShimmerCircle extends StatefulWidget {
  final double radius;
  const ShimmerCircle({super.key, required this.radius});

  @override
  State<ShimmerCircle> createState() => _ShimmerCircleState();
}

class _ShimmerCircleState extends State<ShimmerCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: widget.radius * 2,
        height: widget.radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade800,
              Colors.grey.shade700,
              Colors.grey.shade800,
            ],
            begin: Alignment(-1 + _c.value * 2, -1),
            end: Alignment(1 + _c.value * 2, 1),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
}

class ShimmerLine extends StatelessWidget {
  const ShimmerLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
