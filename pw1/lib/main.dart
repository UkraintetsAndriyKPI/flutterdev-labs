import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: CalculatorTabs());
  }
}

class CalculatorTabs extends StatelessWidget {
  const CalculatorTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey.shade800,
          foregroundColor: Colors.white,
          title: const Text("Heat Calculator"),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
            tabs: const [
              Tab(text: "Calculator 1"),
              Tab(text: "Calculator 2"),
            ],
          ),
        ),
        body: const TabBarView(children: [CalculatorOne(), CalculatorTwo()]),
      ),
    );
  }
}

class CalculatorOne extends StatefulWidget {
  const CalculatorOne({super.key});

  @override
  State<CalculatorOne> createState() => _CalculatorOneState();
}

class _CalculatorOneState extends State<CalculatorOne> {
  final hp = TextEditingController();
  final cp = TextEditingController();
  final sp = TextEditingController();
  final np = TextEditingController();
  final op = TextEditingController();
  final wp = TextEditingController();
  final ap = TextEditingController();

  String result = "";

  double parse(TextEditingController c) => double.tryParse(c.text) ?? 0;

  void calculate() {
    double HP = parse(hp);
    double CP = parse(cp);
    double SP = parse(sp);
    double NP = parse(np);
    double OP = parse(op);
    double WP = parse(wp);
    double AP = parse(ap);

    if (WP >= 100 || WP + AP >= 100) {
      setState(() => result = "Invalid input values");
      return;
    }

    double KPC = 100 / (100 - WP);
    double KPG = 100 / (100 - WP - AP);

    double HC = HP * KPC;
    double CC = CP * KPC;
    double SC = SP * KPC;
    double NC = NP * KPC;
    double OC = OP * KPC;
    double AC = AP * KPC;

    double HG = HP * KPG;
    double CG = CP * KPG;
    double SG = SP * KPG;
    double NG = NP * KPG;
    double OG = OP * KPG;

    double QPH = (339 * CP + 1030 * HP - 108.8 * (OP - SP) - 25 * WP) / 1000;

    double QCH = (QPH + 0.025 * WP) * KPC;
    double QGH = (QPH + 0.025 * WP) * KPG;

    setState(() {
      result =
          """
KPC = ${KPC.toStringAsFixed(4)}
KPG = ${KPG.toStringAsFixed(4)}

HC = ${HC.toStringAsFixed(4)}
CC = ${CC.toStringAsFixed(4)}
SC = ${SC.toStringAsFixed(4)}
NC = ${NC.toStringAsFixed(4)}
OC = ${OC.toStringAsFixed(4)}
AC = ${AC.toStringAsFixed(4)}

HG = ${HG.toStringAsFixed(4)}
CG = ${CG.toStringAsFixed(4)}
SG = ${SG.toStringAsFixed(4)}
NG = ${NG.toStringAsFixed(4)}
OG = ${OG.toStringAsFixed(4)}

QPH = ${QPH.toStringAsFixed(4)}
QCH = ${QCH.toStringAsFixed(4)}
QGH = ${QGH.toStringAsFixed(4)}
""";
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
          input("HP", hp),
          input("CP", cp),
          input("SP", sp),
          input("NP", np),
          input("OP", op),
          input("WP", wp),
          input("AP", ap),
          ElevatedButton(onPressed: calculate, child: const Text("Calculate")),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: SelectableText(
              result,
              style: const TextStyle(fontSize: 15, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}

class CalculatorTwo extends StatefulWidget {
  const CalculatorTwo({super.key});

  @override
  State<CalculatorTwo> createState() => _CalculatorTwoState();
}

class _CalculatorTwoState extends State<CalculatorTwo> {
  final hg = TextEditingController();
  final cg = TextEditingController();
  final sg = TextEditingController();
  final og = TextEditingController();
  final wg = TextEditingController();
  final ag = TextEditingController();
  final qi = TextEditingController();

  String result = "";

  double parse(TextEditingController c) => double.tryParse(c.text) ?? 0;

  void calculate() {
    double HG = parse(hg);
    double CG = parse(cg);
    double SG = parse(sg);
    double OG = parse(og);
    double WG = parse(wg);
    double AG = parse(ag);
    double QI = parse(qi);

    if (WG + AG >= 100) {
      setState(() => result = "Invalid input values");
      return;
    }

    double coefficient = (100 - WG - AG) / 100;

    double HP = HG * coefficient;
    double CP = CG * coefficient;
    double SP = SG * coefficient;
    double OP = OG * coefficient;
    double AP = (AG * (100 - WG)) / 100;

    double QPI = QI * coefficient - 0.025 * WG;

    setState(() {
      result =
          """
HP = ${HP.toStringAsFixed(4)}
CP = ${CP.toStringAsFixed(4)}
SP = ${SP.toStringAsFixed(4)}
OP = ${OP.toStringAsFixed(4)}
AP = ${AP.toStringAsFixed(4)}

QPI = ${QPI.toStringAsFixed(4)}
""";
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
          input("HG", hg),
          input("CG", cg),
          input("SG", sg),
          input("OG", og),
          input("WG", wg),
          input("AG", ag),
          input("QI", qi),
          ElevatedButton(onPressed: calculate, child: const Text("Calculate")),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: SelectableText(
              result,
              style: const TextStyle(fontSize: 15, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
