import 'dart:math';
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
      home: PW6Calculator(),
    );
  }
}

class PW6Calculator extends StatefulWidget {
  const PW6Calculator({super.key});

  @override
  State<PW6Calculator> createState() => _PW6CalculatorState();
}

class _PW6CalculatorState extends State<PW6Calculator> {

  final grindingNominalController = TextEditingController();
  final polishingUsageController = TextEditingController();
  final circularReactiveController = TextEditingController();

  final double loadVoltage = 0.38;

  Map<String, double> amountEP = {
    "GrindingMachine": 4,
    "DrillingMachine": 2,
    "GroutingMachine": 4,
    "CircularSaw": 1,
    "Press": 1,
    "PolishingMachine": 1,
    "MillingMachine": 2,
    "Fan": 1,
    "WeldingTransformer": 2,
    "DryerWardrobe": 2,
  };

  Map<String, double> nominalPower = {
    "GrindingMachine": 20,
    "DrillingMachine": 14,
    "GroutingMachine": 42,
    "CircularSaw": 36,
    "Press": 20,
    "PolishingMachine": 40,
    "MillingMachine": 32,
    "Fan": 20,
    "WeldingTransformer": 100,
    "DryerWardrobe": 120,
  };

  Map<String, double> usageCoeff = {
    "GrindingMachine": 0.15,
    "DrillingMachine": 0.12,
    "GroutingMachine": 0.15,
    "CircularSaw": 0.3,
    "Press": 0.5,
    "PolishingMachine": 0.2,
    "MillingMachine": 0.2,
    "Fan": 0.65,
    "WeldingTransformer": 0.2,
    "DryerWardrobe": 0.8,
  };

  Map<String, double> reactivePowerCoeff = {
    "GrindingMachine": 1.33,
    "DrillingMachine": 1.0,
    "GroutingMachine": 1.33,
    "CircularSaw": 1.52,
    "Press": 0.75,
    "PolishingMachine": 1.0,
    "MillingMachine": 1.0,
    "Fan": 0.75,
    "WeldingTransformer": 3.0,
    "DryerWardrobe": 0.0,
  };

  String result = "";
  bool showResult = false;

  List<List<String>> tableData = [];

  double parse(String value) => double.tryParse(value) ?? 0;

  void calculate() {

    // Оновлення параметрів якщо введені
    if (grindingNominalController.text.isNotEmpty) {
      nominalPower["GrindingMachine"] =
          parse(grindingNominalController.text);
    }

    if (polishingUsageController.text.isNotEmpty) {
      usageCoeff["PolishingMachine"] =
          parse(polishingUsageController.text);
    }

    if (circularReactiveController.text.isNotEmpty) {
      reactivePowerCoeff["CircularSaw"] =
          parse(circularReactiveController.text);
    }

    Map<String, double> stream = {};
    Map<String, double> nPnKB = {};
    Map<String, double> nPnKBtg = {};
    Map<String, double> nPnpow2 = {};

    for (var key in amountEP.keys) {
      stream[key] = amountEP[key]! * nominalPower[key]!;
      nPnKB[key] = stream[key]! * usageCoeff[key]!;
      nPnKBtg[key] = nPnKB[key]! * reactivePowerCoeff[key]!;
      nPnpow2[key] = amountEP[key]! * pow(nominalPower[key]!, 2);
    }

    double sumStream = stream.values.reduce((a, b) => a + b);
    double sumPnKB = nPnKB.values.reduce((a, b) => a + b);
    double sumPnKBtg = nPnKBtg.values.reduce((a, b) => a + b);
    double sumPnpow2 = nPnpow2.values.reduce((a, b) => a + b);

    double effectiveEPamount =
        pow(sumStream -
                stream["WeldingTransformer"]! -
                stream["DryerWardrobe"]!,
            2) /
            sumPnpow2;

    double calculatedActiveLoad = 1.25 * sumPnKB;
    double fullPower =
        sqrt(pow(calculatedActiveLoad, 2) + pow(sumPnKBtg, 2));

    double cehUsageCoeff = sumPnKB / sumStream;
    double cehUsageCoeffAtAll = 1.25 * cehUsageCoeff;
    double calculatedActiveLoadOnTires =
        cehUsageCoeffAtAll * sumStream;

    double fullPowerOnTires = sqrt(
        pow(calculatedActiveLoadOnTires, 2) +
            pow(sumPnKBtg, 2));

    double calculatedCurrentOnTires =
        fullPowerOnTires / loadVoltage / sqrt(3);

    // Формування таблиці
    tableData = [];
    for (var key in amountEP.keys) {
      tableData.add([
        key,
        amountEP[key]!.toStringAsFixed(0),
        stream[key]!.toStringAsFixed(2),
        usageCoeff[key]!.toStringAsFixed(2),
        nPnKB[key]!.toStringAsFixed(2),
        nPnKBtg[key]!.toStringAsFixed(2),
        nPnpow2[key]!.toStringAsFixed(2),
      ]);
    }

    setState(() {
      result = """
Ефективна к-сть ЕП: ${effectiveEPamount.toStringAsFixed(2)}
Активне навантаження: ${calculatedActiveLoad.toStringAsFixed(2)} кВт
Повна потужність: ${fullPower.toStringAsFixed(2)} кВА
----------------------------------------
Активне навантаження на шинах: ${calculatedActiveLoadOnTires.toStringAsFixed(2)} кВт
Повна потужність на шинах: ${fullPowerOnTires.toStringAsFixed(2)} кВА
Струм: ${calculatedCurrentOnTires.toStringAsFixed(2)} А
""";
      showResult = true;
    });
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

  Widget buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Назва ЕП")),
          DataColumn(label: Text("К-сть")),
          DataColumn(label: Text("Ipr")),
          DataColumn(label: Text("Кв")),
          DataColumn(label: Text("n*Pн*Кв")),
          DataColumn(label: Text("n*Pн*Кв*tgφ")),
          DataColumn(label: Text("n*Pн²")),
        ],
        rows: tableData
            .map(
              (row) => DataRow(
                cells: row
                    .map((cell) => DataCell(Text(cell)))
                    .toList(),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget resultBox() {
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
        style: const TextStyle(fontFamily: 'monospace'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PW6 Calculator"),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            input("Шліфувальний верстат - Рн (кВт)",
                grindingNominalController),

            input("Полірувальний верстат - Кв",
                polishingUsageController),

            input("Циркулярна пила - tgφ",
                circularReactiveController),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: calculate,
              child: const Text("Розрахувати"),
            ),

            const SizedBox(height: 20),

            if (showResult) resultBox(),

            const SizedBox(height: 20),

            if (tableData.isNotEmpty) buildTable(),
          ],
        ),
      ),
    );
  }
}
