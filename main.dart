import 'dart:math';
import 'package:flutter/material.dart';

// --- 1. Modelo de Datos (Clase Transaction) ---
// Define la estructura de cada transacción, similar a un objeto o una fila en una base de datos.
class Transaction {
  final DateTime date;
  final double amount;
  final String category;

  Transaction({required this.date, required this.amount, required this.category});
}

// --- 2. Interfaz de Usuario y Lógica (StatefulWidget) ---
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analizador Big Data',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const FinancialAnalyzerPage(),
    );
  }
}

class FinancialAnalyzerPage extends StatefulWidget {
  const FinancialAnalyzerPage({super.key});

  @override
  State<FinancialAnalyzerPage> createState() => _FinancialAnalyzerPageState();
}

class _FinancialAnalyzerPageState extends State<FinancialAnalyzerPage> {
  String _resultText = 'Presiona el botón para comenzar el análisis.';
  bool _isAnalyzing = false;

  // --- 3. Generación de Datos ---
  // Este método simula la obtención de grandes volúmenes de datos.
  Future<List<Transaction>> _generateFinancialData({int numTransactions = 5000}) async {
    final random = Random();
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 365));
    final transactions = <Transaction>[];

    final categories = ['Alimentos', 'Transporte', 'Ocio', 'Facturas', 'Salario', 'Otros'];
    final categoryWeights = [0.3, 0.2, 0.15, 0.15, 0.1, 0.1];

    for (int i = 0; i < numTransactions; i++) {
      final randomDays = random.nextInt(365);
      final randomDate = startDate.add(Duration(days: randomDays));
      
      final category = categories[_weightedChoice(random, categoryWeights)];
      double amount;

      if (category == 'Salario') {
        amount = random.nextDouble() * 1500 + 1500;
      } else if (category == 'Facturas') {
        amount = -(random.nextDouble() * 250 + 50);
      } else {
        amount = -(random.nextDouble() * 145 + 5);
        if (random.nextDouble() < 0.005) { // Simular anomalía
          amount = -(random.nextDouble() * 600 + 200);
        }
      }

      transactions.add(Transaction(
        date: randomDate,
        amount: double.parse(amount.toStringAsFixed(2)),
        category: category,
      ));
    }
    return transactions;
  }
  
  int _weightedChoice(Random random, List<double> weights) {
    final totalWeight = weights.reduce((a, b) => a + b);
    var randomNumber = random.nextDouble() * totalWeight;

    for (int i = 0; i < weights.length; i++) {
      randomNumber -= weights[i];
      if (randomNumber <= 0) {
        return i;
      }
    }
    return weights.length - 1;
  }

  // --- 4. Lógica de Análisis ---
  // Procesa los datos para encontrar patrones.
  Future<void> _runAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _resultText = 'Analizando, por favor espera...';
    });

    // Simular un proceso de análisis más largo
    await Future.delayed(const Duration(milliseconds: 500));

    // Generar los datos
    final transactions = await _generateFinancialData();
    final expenses = transactions.where((t) => t.amount < 0);
    
    final spendByCategory = <String, double>{};
    final anomalies = <Transaction>[];

    for (var t in expenses) {
      // Gasto por categoría
      spendByCategory.update(
        t.category,
        (value) => value + t.amount.abs(),
        ifAbsent: () => t.amount.abs(),
      );

      // Detección de anomalías
      if (t.amount < -300) {
        anomalies.add(t);
      }
    }

    // Construir el texto de los resultados
    final buffer = StringBuffer();
    buffer.writeln('--- Análisis de Hábitos Financieros ---');
    buffer.writeln('\nSe analizaron ${transactions.length} transacciones de 1 año.');

    // 1. Gasto por categoría
    buffer.writeln('\n1. Gasto Total por Categoría:');
    spendByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      .forEach((entry) => buffer.writeln('${entry.key}: ${entry.value.toStringAsFixed(2)} €'));

    // 2. Detección de anomalías
    buffer.writeln('\n2. ALERTA: Posibles Gastos Atípicos (Anomalías):');
    if (anomalies.isNotEmpty) {
      for (var anom in anomalies) {
        buffer.writeln('🚨 Monto: ${anom.amount.toStringAsFixed(2)} €, Categoría: ${anom.category}, Fecha: ${anom.date.toLocal().toString().split(' ')[0]}');
      }
    } else {
      buffer.writeln('No se detectaron gastos atípicos.');
    }

    setState(() {
      _isAnalyzing = false;
      _resultText = buffer.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analizador de Big Data'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Generador y Analizador de Transacciones',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Presiona el botón para simular el análisis de un gran volumen de datos.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isAnalyzing ? null : _runAnalysis,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              child: _isAnalyzing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Analizar Datos'),
            ),
            const SizedBox(height: 20),
            if (!_isAnalyzing)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 5),
                  ],
                ),
                child: Text(_resultText, style: const TextStyle(fontFamily: 'Courier')),
              ),
          ],
        ),
      ),
    );
  }
}
