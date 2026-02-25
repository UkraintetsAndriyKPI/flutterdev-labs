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
      home: EmissionCalculator(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class EmissionCalculator extends StatefulWidget {
  const EmissionCalculator({super.key});

  @override
  State<EmissionCalculator> createState() => _EmissionCalculatorState();
}

class _EmissionCalculatorState extends State<EmissionCalculator> {
  final coalController = TextEditingController();
  final oilController = TextEditingController();
  final gasController = TextEditingController();

  String result = "";
  bool showResult = false;

  double parse(TextEditingController c) => double.tryParse(c.text) ?? 0.0;

  void calculate() {
    try {
      const nCleaning = 0.985;

      const qrCoal = 20.47;
      const qrOil = 39.48;
      const qrGas = 33.08;

      const aOutCoal = 0.8;
      const aOutOil = 1.0;
      const aOutGas = 0.0;

      const AInCoal = 25.20;
      const AInOil = 0.15;
      const AInGas = 0.0;

      const GoutCoal = 1.5;
      const GoutOil = 0.0;
      const GoutGas = 0.0;

      double coalAmount = parse(coalController);
      double oilAmount = parse(oilController);
      double gasAmount = parse(gasController);

      double coalKTB =
          (pow(10, 6) / qrCoal) *
          aOutCoal *
          (AInCoal / (100 - GoutCoal)) *
          (1 - nCleaning);

      double coalETB = pow(10, -6) * coalKTB * qrCoal * coalAmount;

      double oilKTB =
          (pow(10, 6) / qrOil) *
          aOutOil *
          (AInOil / (100 - GoutOil)) *
          (1 - nCleaning);

      double oilETB = pow(10, -6) * oilKTB * qrOil * oilAmount;

      double gasKTB =
          (pow(10, 6) / qrGas) *
          aOutGas *
          (AInGas / (100 - GoutGas)) *
          (1 - nCleaning);

      double gasETB = pow(10, -6) * gasKTB * qrGas * gasAmount;

      setState(() {
        result =
            """
Вугілля:
kₜᵦ = ${coalKTB.toStringAsFixed(6)}
Eₜᵦ = ${coalETB.toStringAsFixed(6)}

Мазут:
kₜᵦ = ${oilKTB.toStringAsFixed(6)}
Eₜᵦ = ${oilETB.toStringAsFixed(6)}

Газ:
kₜᵦ = ${gasKTB.toStringAsFixed(6)}
Eₜᵦ = ${gasETB.toStringAsFixed(6)}
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
        title: const Text("Emission Calculator"),
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            input("Coal amount (t)", coalController),
            input("Oil amount (t)", oilController),
            input("Gas amount (t)", gasController),

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
                  style: const TextStyle(fontSize: 15, fontFamily: 'monospace'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
