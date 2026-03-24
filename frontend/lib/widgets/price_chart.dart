import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/price_data.dart';

class PriceChart extends StatefulWidget {
  final bool isGold;
  final String timeframe;
  final Color lineColor;

  const PriceChart({
    super.key,
    required this.isGold,
    this.timeframe = 'Max',
    required this.lineColor,
  });

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> with SingleTickerProviderStateMixin {
  double? touchX;
  bool isDragging = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          isDragging = true;
          touchX = details.localPosition.dx;
        });
      },
      onPanEnd: (_) => setState(() => isDragging = false),
      onPanCancel: () => setState(() => isDragging = false),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: PriceChartPainter(
              isGold: widget.isGold,
              timeframe: widget.timeframe,
              lineColor: widget.lineColor,
              touchX: isDragging ? touchX : null,
              pulseValue: _pulseAnimation.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class PriceChartPainter extends CustomPainter {
  final bool isGold;
  final String timeframe;
  final Color lineColor;
  final double? touchX;
  final double pulseValue;

  PriceChartPainter({
    required this.isGold,
    required this.timeframe,
    required this.lineColor,
    this.touchX,
    this.pulseValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawLabels(canvas, size);
    _drawCurve(canvas, size);
    if (touchX != null) {
      _drawTooltip(canvas, size, touchX!);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const int cols = 8;
    const int rows = 5;

    for (int i = 0; i <= cols; i++) {
      double x = (size.width / cols) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (int i = 0; i <= rows; i++) {
      double y = (size.height / rows) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawLabels(Canvas canvas, Size size) {
    // Top Right 'Price' Vertical Label
    final span = TextSpan(
      style: GoogleFonts.inter(color: const Color(0xFFCBD5E1), fontSize: 11, fontWeight: FontWeight.w600),
      text: 'Price',
    );
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    
    canvas.save();
    canvas.translate(size.width + 25, size.height / 2 + tp.width / 2);
    canvas.rotate(-1.5708); // 90 deg counter-clockwise
    tp.paint(canvas, Offset.zero);
    canvas.restore();
    
    // Bottom labels based on timeframe
    late List<String> labels;
    switch (timeframe) {
      case '6M':
        labels = ['Sep\'25', 'Dec\'25', 'Mar\'26'];
        break;
      case '1Y':
        labels = ['Mar\'25', 'Sep\'25', 'Mar\'26'];
        break;
      case '3Y':
        labels = ['Mar\'23', 'Mar\'24', 'Mar\'26'];
        break;
      case '5Y':
        labels = ['Mar\'21', 'Mar\'23', 'Mar\'26'];
        break;
      default: // Max
        labels = ['Feb\'18', 'Feb\'22', 'Mar\'26'];
    }

    for(int i=0; i<labels.length; i++) {
      final lSpan = TextSpan(
        style: GoogleFonts.inter(color: const Color(0xFFCBD5E1), fontSize: 10, fontWeight: FontWeight.w600),
        text: labels[i],
      );
      final ltp = TextPainter(text: lSpan, textDirection: TextDirection.ltr);
      ltp.layout();
      double x = (size.width / (labels.length - 1)) * i - (ltp.width / 2);
      // Ensure vertical labels are drawn with enough padding
      ltp.paint(canvas, Offset(x, size.height + 15));
    }
  }

  void _drawCurve(Canvas canvas, Size size) {
    final path = Path();
    final points = isGold ? [0.8, 0.75, 0.7, 0.65, 0.62, 0.6, 0.58, 0.55, 0.52, 0.45, 0.3, 0.15] 
                         : [0.85, 0.82, 0.84, 0.81, 0.79, 0.8, 0.78, 0.75, 0.72, 0.68, 0.6, 0.35];
    
    final stepX = size.width / (points.length - 1);
    
    path.moveTo(0, size.height * points[0]);
    
    for (int i = 1; i < points.length; i++) {
      double x1 = stepX * (i - 0.5);
      double y1 = size.height * points[i - 1];
      double x2 = stepX * (i - 0.5);
      double y2 = size.height * points[i];
      double x3 = stepX * i;
      double y3 = size.height * points[i];
      path.cubicTo(x1, y1, x2, y2, x3, y3);
    }

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Fill under curve
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withOpacity(0.2), lineColor.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
    
    // Draw dot at the end only if NOT dragging
    if (touchX == null) {
      final lastPoint = Offset(size.width, size.height * points.last);
      
      // Outer Pulse
      canvas.drawCircle(
        lastPoint, 
        8 * pulseValue, 
        Paint()..color = lineColor.withOpacity(0.15 * (2 - pulseValue))
      );
      
      // Core Dot
      canvas.drawCircle(lastPoint, 5, paint..style = PaintingStyle.fill);
    }
  }

  void _drawTooltip(Canvas canvas, Size size, double x) {
    final points = isGold ? [0.8, 0.75, 0.7, 0.65, 0.62, 0.6, 0.58, 0.55, 0.52, 0.45, 0.3, 0.15] 
                         : [0.85, 0.82, 0.84, 0.81, 0.79, 0.8, 0.78, 0.75, 0.72, 0.68, 0.6, 0.35];
    
    double clampedX = x.clamp(0.0, size.width);
    double t = clampedX / size.width;
    int index = (t * (points.length - 1)).floor();
    double remainder = (t * (points.length - 1)) - index;
    
    double y;
    if (index < points.length - 1) {
      y = size.height * (points[index] * (1 - remainder) + points[index + 1] * remainder);
    } else {
      y = size.height * points.last;
    }

    final paint = Paint()..color = lineColor;
    
    canvas.drawCircle(Offset(clampedX, y), 6, paint..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(clampedX, y), 10, paint..color = lineColor.withOpacity(0.2));

    double startPrice = isGold ? PriceData.goldPrice * 0.8 : PriceData.silverPrice * 0.8;
    double endPrice = isGold ? PriceData.goldPrice : PriceData.silverPrice;
    double currentPrice = startPrice + (endPrice - startPrice) * (1 - (y/size.height));
    
    List<String> mockDates = ['12 Jan', '25 Feb', '14 Mar', '30 Apr', '15 May', '22 Jun', '08 Jul', '19 Aug', '02 Sep', '24 Oct', '30 Dec', '15 Mar'];
    String date = mockDates[index % mockDates.length] + "'25";

    final tooltipWidth = 100.0;
    final tooltipHeight = 45.0;
    double rectX = clampedX - tooltipWidth / 2;
    double rectY = y - tooltipHeight - 15;
    
    if (rectY < 0) rectY = y + 15;
    rectX = rectX.clamp(0.0, size.width - tooltipWidth);

    final RRect rrect = RRect.fromLTRBR(rectX, rectY, rectX + tooltipWidth, rectY + tooltipHeight, const Radius.circular(8));
    
    canvas.drawShadow(Path()..addRRect(rrect), Colors.black, 10, true);
    canvas.drawRRect(rrect, Paint()..color = Colors.white);

    final dateSpan = TextSpan(
      style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w600),
      text: date,
    );
    final priceSpan = TextSpan(
      style: GoogleFonts.manrope(color: const Color(0xFF111827), fontSize: 11, fontWeight: FontWeight.w800),
      text: '₹${currentPrice.toStringAsFixed(1)}',
    );

    final dateTp = TextPainter(text: dateSpan, textDirection: TextDirection.ltr)..layout();
    final priceTp = TextPainter(text: priceSpan, textDirection: TextDirection.ltr)..layout();

    dateTp.paint(canvas, Offset(rectX + (tooltipWidth - dateTp.width) / 2, rectY + 8));
    priceTp.paint(canvas, Offset(rectX + (tooltipWidth - priceTp.width) / 2, rectY + 22));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
