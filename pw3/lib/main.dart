import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PowerStationCalculator(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PowerStationCalculator extends StatefulWidget {
  const PowerStationCalculator({super.key});

  @override
  State<PowerStationCalculator> createState() =>
      _PowerStationCalculatorState();
}

class _PowerStationCalculatorState extends State<PowerStationCalculator> {
  final avgPowerController = TextEditingController();
  final deviationController = TextEditingController();
  final priceController = TextEditingController();

  String result = "";
  bool showResult = false;

  double parse(TextEditingController c) =>
      double.tryParse(c.text) ?? 0.0;

  void calculate() {
    try {
      double avgPower = parse(avgPowerController);
      double deviation = parse(deviationController);
      double price = parse(priceController);

      // BEFORE improvements
      double omegaW1 =
          integration(4.75, 5.25, 8, avgPower, deviation) / 100;

      double W11 = 24 * avgPower * omegaW1;
      double W12 = 24 * avgPower * (1 - omegaW1);

      double profit1 = 24 * avgPower * omegaW1 * price;
      double fine1 = 24 * avgPower * (1 - omegaW1) * price;

      double clearProfit1 = profit1 - fine1;

      String conclusion1 = clearProfit1 > 0
          ? "Electro station is profitable. Positive profit"
          : "Electro station is not profitable. Negative profit";

      // AFTER improvements
      double omegaW2 =
          integration(4.75, 5.25, 26, avgPower, deviation) / 100;

      double W21 = 24 * avgPower * omegaW2;
      double W22 = 24 * avgPower * (1 - omegaW2);

      double profit2 = 24 * avgPower * omegaW2 * price;
      double fine2 = 24 * avgPower * (1 - omegaW2) * price;

      double clearProfit2 = profit2 - fine2;

      String conclusion2 = clearProfit2 > 0
          ? "Electro station is profitable. Positive profit"
          : "Electro station is not profitable. Negative profit";

      setState(() {
        result = """
BEFORE improvements:
δW1 = ${omegaW1.toStringAsFixed(6)}
W1 = ${W11.toStringAsFixed(6)}
W2 = ${W12.toStringAsFixed(6)}
profit = ${profit1.toStringAsFixed(6)}
fine = ${fine1.toStringAsFixed(6)}
clear profit = ${clearProfit1.toStringAsFixed(6)}
conclusion = $conclusion1

AFTER improvements:
δW2 = ${omegaW2.toStringAsFixed(6)}
W1 = ${W21.toStringAsFixed(6)}
W2 = ${W22.toStringAsFixed(6)}
profit = ${profit2.toStringAsFixed(6)}
fine = ${fine2.toStringAsFixed(6)}
clear profit = ${clearProfit2.toStringAsFixed(6)}
conclusion = $conclusion2
""";
        showResult = true;
      });
    } catch (e) {
      setState(() {
        result = "Something went wrong.";
        showResult = true;
      });
    }
  }

  double integration(double start, double end, int steps,
      double avgPower, double deviation) {
    double sum = 0.0;
    double step = (end - start) / steps;

    for (double i = start; i < end; i += step) {
      sum += expression(i, avgPower, deviation);
    }

    return sum;
  }

  double expression(double p, double avgPower, double deviation) {
    return (1 / (deviation * sqrt(2 * pi))) *
        exp(-pow(p - avgPower, 2) /
            (2 * pow(deviation, 2)));
  }

  Widget input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Power Station Profit Calculator"),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            input("Average daily power", avgPowerController),
            input("Standard deviation", deviationController),
            input("Electricity price", priceController),

            ElevatedButton(
              onPressed: calculate,
              child: const Text("Calculate"),
            ),

            const SizedBox(height: 20),

            if (showResult)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade700),
                ),
                child: SelectableText(
                  result,
                  style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'monospace'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
