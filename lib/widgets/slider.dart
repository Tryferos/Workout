import 'package:flutter/material.dart';
import 'package:vertical_weight_slider/vertical_weight_slider.dart';

class CustomBottomSlider extends StatefulWidget {
  const CustomBottomSlider(
      {super.key,
      required this.max,
      required this.min,
      required this.onChange,
      required this.label,
      required this.formatUnit,
      required this.init,
      this.interval});

  final int max;
  final int min;
  final double? interval;
  final dynamic Function(double) formatUnit;
  final String label;
  final void Function(double) onChange;
  final double init;

  @override
  State<CustomBottomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomBottomSlider> {
  WeightSliderController? _sliderController;
  double init = 0;
  @override
  void initState() {
    super.initState();
    setState(() {
      init = widget.init;
      _sliderController = WeightSliderController(
          initialWeight: widget.init,
          interval: widget.interval ?? 1,
          minWeight: widget.min,
          itemExtent: 30);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, updateState) {
      return Container(
        height: 425,
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Container(
              width: 35,
              decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(15)),
              height: 3.5,
            ),
            const SizedBox(
              height: 32,
            ),
            Text('${widget.formatUnit(init)} ${widget.label}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(
              height: 32,
              color: Colors.grey[300],
            ),
            VerticalWeightSlider(
              controller: _sliderController ??
                  WeightSliderController(
                      initialWeight: widget.init,
                      interval: 1,
                      minWeight: widget.min,
                      itemExtent: 30),
              decoration: const PointerDecoration(
                width: 130.0,
                height: 3.0,
                largeColor: Color(0xFF898989),
                mediumColor: Color.fromARGB(255, 184, 181, 181),
                smallColor: Color.fromARGB(255, 216, 214, 214),
                gap: 20.0,
              ),
              onChanged: (double value) {
                setState(() {
                  init = value;
                  widget.onChange(value);
                });
              },
              maxWeight: widget.max,
              indicator: Container(
                height: 3.0,
                width: 200.0,
                alignment: Alignment.centerLeft,
                color: Colors.red[300],
              ),
            )
          ],
        ),
      );
    });
  }
}
