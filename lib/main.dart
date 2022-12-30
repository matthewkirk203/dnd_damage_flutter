// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D&D Power Shot',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const MyHomePage(title: 'D&D Power Shot'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {

  final _formKey = GlobalKey<FormState>();

  // User Input Values
  int _targetAC = 0;
  int _attackBonus = 0;
  int _numDice = 0;
  int _numSides = 0;
  int _damageBonus = 0;
  List<int> _rerollNumbers = [];
  bool _powerShot = false;

  // Cacluated Values
  double _averageHitDamage = 0;
  double _hitChance = 0;
  double _totalAverageDamage = 0;

  void _calculate() {
    _formKey.currentState?.save();
    setState(() {
      if (_powerShot) {
        _attackBonus -= 5;
        _damageBonus += 10;
      }
      _averageHitDamage = _calculateAvgDamage(_numDice, _numSides)+_damageBonus;
      _hitChance = _calculateHitChance(_targetAC, _attackBonus);
      _totalAverageDamage = (_calculateAvgDamageWithRerolls(_numDice, _numSides, _rerollNumbers)+_damageBonus) * _hitChance;
    });
  }

  static double _calculateAvgDamage(int numDice, int numSides) {
    double sum = numSides*(numSides + 1 ) / 2;
    double avgSingleDiceDamage = sum/numSides;
    double totalAvgDamage = numDice * avgSingleDiceDamage;
    return totalAvgDamage;
  }

  static double _calculateAvgDamageWithRerolls(int numDice, int numSides, List<int> rerolls) {
    final avgDamage = _calculateAvgDamage(numDice, numSides);
    List<double> sides = [];
    for (int i = 1; i < numSides; ++i) {
      if (rerolls.contains(i)) {
        sides.add(avgDamage);
      }
      else {
        sides.add(i.toDouble());
      }
    }
    return sides.average * numDice;
  }

  static double _calculateHitChance(int ac, int attackBonus) {
    double hitChance = (21+attackBonus-ac)/20;
    // Take into accout crit success and failures
    if (hitChance > .95) {
        hitChance = .95;
    }
    else if (hitChance < .05) {
        hitChance = .05;
    }
    return hitChance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Power Shot?")),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Target AC"), 
            TextFormField(onSaved: (String? value){_targetAC = int.parse(value ?? '0');}, initialValue: "12", textAlign: TextAlign.center, keyboardType: TextInputType.number,),
            Text("Attack Bonus"),
            TextFormField(onSaved: (String? value){_attackBonus = int.parse(value ?? '0');}, initialValue: "0", textAlign: TextAlign.center, keyboardType: TextInputType.number,),
            Text("Damage"),
            Row(children: [
              Flexible(child: TextFormField(onSaved: (String? value){_numDice = int.parse(value ?? '1');},initialValue: "1", textAlign: TextAlign.center, keyboardType: TextInputType.number,)),
              Text("d"),
              Flexible(child: TextFormField(onSaved: (String? value){_numSides = int.parse(value ?? '6');},initialValue: "6", textAlign: TextAlign.center, keyboardType: TextInputType.number,)),
              Text("+"),
              Flexible(child: TextFormField(onSaved: (String? value){_damageBonus = int.parse(value ?? '0');},initialValue: "0", textAlign: TextAlign.center, keyboardType: TextInputType.number,)),
              ],),
              Text("Reroll (once, comma separated)"),
              Flexible(
                child: TextFormField(
                  onSaved: (String? value) {
                    _rerollNumbers = [];
                    if (value == null || value == "") return;
                    for (String str in value.split(',')) {
                      _rerollNumbers.add(int.parse(str));
                    }
                  },
                  decoration: InputDecoration(hintText: "1,2,3"),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                ),
              ),
            Row(children: [
              Checkbox(value: _powerShot, onChanged: (bool? newValue){setState(() {
                _powerShot = newValue ?? false;
              });}),
              Text("Power Shot? (-5 Attack, +10 Damage)"),
            ],),
            ElevatedButton(onPressed: _calculate, child: const Text("Calculate"),),

            const Divider(color: Colors.blue, thickness: 5,),

            Text("Average Hit Damage: ${_averageHitDamage.toStringAsFixed(1)}"),
            Text("Hit Chance: $_hitChance"),
            Text("Total Average Damage: ${_totalAverageDamage.toStringAsFixed(1)}"),
          ],
        ),
      )
    );
  }
}
