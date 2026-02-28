import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ReliabilityTabs(),
    );
  }
}

class ReliabilityTabs extends StatelessWidget {
  const ReliabilityTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Reliability Calculator PW5"),
          backgroundColor: Colors.blueGrey.shade800,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
            tabs: [
              Tab(text: "Надійність"),
              Tab(text: "Збитки"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [TechnicalCalculator(), EconomicCalculator()],
        ),
      ),
    );
  }
}


class TechnicalCalculator extends StatefulWidget {
  const TechnicalCalculator({super.key});

  @override
  State<TechnicalCalculator> createState() => _TechnicalCalculatorState();
}

class _TechnicalCalculatorState extends State<TechnicalCalculator> {
  final electricGasSwitchAmount = TextEditingController();
  final electricPL100kBlen = TextEditingController();
  final converter110kBAmount = TextEditingController();
  final switcher10kBAmount = TextEditingController();
  final connector10kBamount = TextEditingController();

  String result = "";
  bool showResult = false;

  double parse(TextEditingController c) => double.tryParse(c.text) ?? 0;

  void calculateTechnical() {
    const electricGasSwitchFRate = 0.01;
    const electricPL100kBFRate = 0.007;
    const converter110kBFRate = 0.015;
    const switcher10kBFRate = 0.02;
    const connector10kBFRate = 0.03;

    double failureRate1 =
        electricGasSwitchFRate * parse(electricGasSwitchAmount) +
        electricPL100kBFRate * parse(electricPL100kBlen) +
        converter110kBFRate * parse(converter110kBAmount) +
        switcher10kBFRate * parse(switcher10kBAmount) +
        connector10kBFRate * parse(connector10kBamount);

    double accidentCoeff = failureRate1 / 8760;
    double idleCoeff = 1.2 * 43 / 8760;

    double failureRate2 =
        2 * failureRate1 * (accidentCoeff + idleCoeff) + switcher10kBFRate;

    String conclusion = failureRate1 > failureRate2
        ? "Двоколова система надійніша"
        : "Одноколова система надійніша";

    setState(() {
      result =
          """
Частота відмови 1-колової:
${failureRate1.toStringAsFixed(6)} рік^-1

Частота відмови 2-колової:
${failureRate2.toStringAsFixed(6)} рік^-1

Висновок:
$conclusion
""";
      showResult = true;
    });
  }

  Widget input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          input("Electric Gas Switch Amount", electricGasSwitchAmount),
          input("Electric PL 100kB Length", electricPL100kBlen),
          input("Converter 110kB Amount", converter110kBAmount),
          input("Switcher 10kB Amount", switcher10kBAmount),
          input("Connector 10kB Amount", connector10kBamount),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: calculateTechnical,
            child: const Text("Calculate Reliability"),
          ),

          const SizedBox(height: 20),

          if (showResult) resultBox(result),
        ],
      ),
    );
  }
}


class EconomicCalculator extends StatefulWidget {
  const EconomicCalculator({super.key});

  @override
  State<EconomicCalculator> createState() => _EconomicCalculatorState();
}

class _EconomicCalculatorState extends State<EconomicCalculator> {
  final accidentCost = TextEditingController();
  final scheduleCost = TextEditingController();
  final denyRate = TextEditingController();
  final avgAccidentDenyTime = TextEditingController();
  final avgScheduleDenyTime = TextEditingController();

  String result = "";
  bool showResult = false;

  double parse(TextEditingController c) => double.tryParse(c.text) ?? 0;

  void calculateEconomic() {
    double mathHopeAccident =
        parse(denyRate) * parse(avgAccidentDenyTime) * 5120 * 6451;

    double mathHopeSchedule = parse(avgScheduleDenyTime) * 5120 * 6451;

    double accidentCostResult = mathHopeAccident * parse(accidentCost);

    double scheduleCostResult = mathHopeSchedule * parse(scheduleCost);

    double total = accidentCostResult + scheduleCostResult;

    setState(() {
      result =
          """
Аварійне невідпущення:
${mathHopeAccident.toStringAsFixed(2)} кВт*год

Планове невідпущення:
${mathHopeSchedule.toStringAsFixed(2)} кВт*год

Збитки аварійні:
${accidentCostResult.toStringAsFixed(2)} грн

Збитки планові:
${scheduleCostResult.toStringAsFixed(2)} грн

Загальні збитки:
${total.toStringAsFixed(2)} грн
""";
      showResult = true;
    });
  }

  Widget input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          input("Accident Cost (грн/кВт*год)", accidentCost),
          input("Schedule Cost (грн/кВт*год)", scheduleCost),
          input("Deny Rate", denyRate),
          input("Avg Accident Deny Time", avgAccidentDenyTime),
          input("Avg Schedule Deny Time", avgScheduleDenyTime),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: calculateEconomic,
            child: const Text("Calculate Losses"),
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
      color: Colors.green.shade100,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.green.shade700),
    ),
    child: SelectableText(
      result,
      style: const TextStyle(fontSize: 15, fontFamily: 'monospace'),
    ),
  );
}
