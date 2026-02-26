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
      debugShowCheckedModeBanner: false,
      home: ElectricalTabs(),
    );
  }
}

class ElectricalTabs extends StatelessWidget {
  const ElectricalTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey.shade800,
          foregroundColor: Colors.white,
          title: const Text("Electrical Calculator PW4"),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
            tabs: [
              Tab(text: "Cable"),
              Tab(text: "Short Circuit 1"),
              Tab(text: "Short Circuit 2"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CableCalculator(),
            ShortCircuitOne(),
            ShortCircuitTwo(),
          ],
        ),
      ),
    );
  }
}


class CableCalculator extends StatefulWidget {
  const CableCalculator({super.key});

  @override
  State<CableCalculator> createState() => _CableCalculatorState();
}

class _CableCalculatorState extends State<CableCalculator> {
  final electricCurrent = TextEditingController();
  final load = TextEditingController();

  String result = "";
  bool showResult = false;

  double parse(TextEditingController c) =>
      double.tryParse(c.text) ?? 0;

  void calculate() {
    const voltage = 10.0;

    double normal =
        parse(load) / (sqrt(3) * 2 * voltage);

    double emergency = 2 * normal;
    double sek = normal / 1.4;
    double smin = parse(electricCurrent) * 1000;

    setState(() {
      result =
          """
Тип: ААБ кабель

Нормальний струм = ${normal.toStringAsFixed(4)}
Аварійний струм = ${emergency.toStringAsFixed(4)}
Економічний переріз = ${sek.toStringAsFixed(4)}
Мінімальний переріз = ${smin.toStringAsFixed(4)}
""";
      showResult = true;
    });
  }

  Widget input(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          input("Load", load),
          input("Electric current", electricCurrent),
          ElevatedButton(
            onPressed: calculate,
            child: const Text("Calculate"),
          ),
          const SizedBox(height: 20),
          if (showResult) resultBox(result),
        ],
      ),
    );
  }
}

class ShortCircuitOne extends StatefulWidget {
  const ShortCircuitOne({super.key});

  @override
  State<ShortCircuitOne> createState() =>
      _ShortCircuitOneState();
}

class _ShortCircuitOneState
    extends State<ShortCircuitOne> {

  final powerMBA = TextEditingController();

  String result = "";
  bool showResult = false;

  double parse(TextEditingController c) =>
      double.tryParse(c.text) ?? 0;

  void calculate() {
    const voltage = 10.5;

    double Xc = pow(voltage, 2) / parse(powerMBA);
    double Xt =
        voltage / 100 * pow(voltage, 2) / 6.3;

    double Xsum = Xc + Xt;
    double I0 =
        voltage / (sqrt(3) * Xsum);

    setState(() {
      result =
          """
Xc = ${Xc.toStringAsFixed(4)}
Xt = ${Xt.toStringAsFixed(4)}
Xsum = ${Xsum.toStringAsFixed(4)}

Початковий струм КЗ = ${I0.toStringAsFixed(4)}
""";
      showResult = true;
    });
  }

  Widget input(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          input("Power MBA", powerMBA),
          ElevatedButton(
            onPressed: calculate,
            child: const Text("Calculate"),
          ),
          const SizedBox(height: 20),
          if (showResult) resultBox(result),
        ],
      ),
    );
  }
}

class ShortCircuitTwo extends StatefulWidget {
  const ShortCircuitTwo({super.key});

  @override
  State<ShortCircuitTwo> createState() =>
      _ShortCircuitTwoState();
}

class _ShortCircuitTwoState
    extends State<ShortCircuitTwo> {

  final resistanceMax = TextEditingController();
  final resistanceBH = TextEditingController();
  final Rcn = TextEditingController();
  final Xcn = TextEditingController();
  final RcnMin = TextEditingController();
  final XcnMin = TextEditingController();

  String result = "";
  bool showResult = false;

  double parse(TextEditingController c) =>
      double.tryParse(c.text) ?? 0;

  void calculate() {
    double Xt =
        (parse(resistanceMax) *
                pow(parse(resistanceBH), 2)) /
            (100 * 6.3);

    double Z =
        sqrt(pow(parse(Rcn), 2) +
            pow(parse(Xcn) + Xt, 2));

    double Zmin =
        sqrt(pow(parse(RcnMin), 2) +
            pow(parse(XcnMin) + Xt, 2));

    double I3 =
        (parse(resistanceBH) * 1000) /
            (sqrt(3) * Z);

    double I3min =
        (parse(resistanceBH) * 1000) /
            (sqrt(3) * Zmin);

    setState(() {
      result =
          """
Xt = ${Xt.toStringAsFixed(4)}

Нормальний режим:
I3 = ${I3.toStringAsFixed(4)}

Мінімальний режим:
I3min = ${I3min.toStringAsFixed(4)}
""";
      showResult = true;
    });
  }

  Widget input(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          input("Resistance max", resistanceMax),
          input("Resistance BH", resistanceBH),
          input("Rcn", Rcn),
          input("Xcn", Xcn),
          input("Rcn MIN", RcnMin),
          input("Xcn MIN", XcnMin),
          ElevatedButton(
            onPressed: calculate,
            child: const Text("Calculate"),
          ),
          const SizedBox(height: 20),
          if (showResult) resultBox(result),
        ],
      ),
    );
  }
}

Widget resultBox(String result) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade400),
    ),
    child: SelectableText(
      result,
      style: const TextStyle(
        fontSize: 15,
        fontFamily: 'monospace',
      ),
    ),
  );
}
