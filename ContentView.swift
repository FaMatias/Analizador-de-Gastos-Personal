import SwiftUI
import Foundation

// MARK: - 1. Modelo de Datos (struct)
// Define la estructura de cada transacción
struct Transaction: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
    let category: String
}

// MARK: - 2. Lógica de Big Data
class FinancialAnalyzer: ObservableObject {
    @Published var analysisResult = ""
    @Published var isAnalyzing = false

    private let categories = ["Alimentos", "Transporte", "Ocio", "Facturas", "Salario", "Otros"]
    private let categoryWeights = [0.3, 0.2, 0.15, 0.15, 0.1, 0.1]

    // Genera datos sintéticos
    private func generateFinancialData(numTransactions: Int) -> [Transaction] {
        var transactions: [Transaction] = []
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: endDate)!
        let timeInterval = endDate.timeIntervalSince(startDate)

        for _ in 0..<numTransactions {
            let randomDate = startDate.addingTimeInterval(TimeInterval.random(in: 0...timeInterval))
            let category = weightedChoice(categories, weights: categoryWeights)
            var amount: Double

            switch category {
            case "Salario":
                amount = Double.random(in: 1500.0...3000.0)
            case "Facturas":
                amount = -Double.random(in: 50.0...300.0)
            default:
                amount = -Double.random(in: 5.0...150.0)
                if Double.random(in: 0...1) < 0.005 { // Simular anomalía
                    amount = -Double.random(in: 200.0...800.0)
                }
            }
            transactions.append(Transaction(date: randomDate, amount: amount, category: category))
        }
        return transactions
    }

    private func weightedChoice<T>(_ items: [T], weights: [Double]) -> T {
        let totalWeight = weights.reduce(0, +)
        var randomNumber = Double.random(in: 0..<totalWeight)
        
        for (index, weight) in weights.enumerated() {
            randomNumber -= weight
            if randomNumber <= 0 {
                return items[index]
            }
        }
        return items.last!
    }

    // Realiza el análisis de datos
    @MainActor
    func analyzeData() async {
        isAnalyzing = true
        analysisResult = "Analizando, por favor espera..."
        
        // Simular un proceso de análisis
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        let transactions = generateFinancialData(numTransactions: 5000)
        let expenses = transactions.filter { $0.amount < 0 }

        var resultsBuilder = ""

        resultsBuilder += "--- Análisis de Hábitos Financieros ---\n\n"
        resultsBuilder += "Se generaron y analizaron \(transactions.count) transacciones de 1 año.\n\n"
        
        // Gasto por categoría
        let spendByCategory = Dictionary(grouping: expenses, by: { $0.category })
            .mapValues { $0.sum(of: \.amount) * -1 }
            .sorted { $0.value > $1.value }
        
        resultsBuilder += "1. Gasto Total por Categoría:\n"
        for (category, total) in spendByCategory {
            resultsBuilder += "\(category): \(String(format: "%.2f", total)) €\n"
        }
        resultsBuilder += "\n"
        
        // Detección de anomalías
        let anomalies = expenses.filter { $0.amount < -300 }
                                .sorted { $0.amount < $1.amount }
        
        resultsBuilder += "2. ALERTA: Posibles Gastos Atípicos:\n"
        if !anomalies.isEmpty {
            for anomaly in anomalies {
                resultsBuilder += "🚨 Monto: \(String(format: "%.2f", anomaly.amount)) €, Categoría: \(anomaly.category), Fecha: \(anomaly.date.formatted(date: .numeric, time: .omitted))\n"
            }
        } else {
            resultsBuilder += "No se detectaron gastos inusualmente altos.\n"
        }
        
        isAnalyzing = false
        analysisResult = resultsBuilder
    }
}

// MARK: - 3. Interfaz de Usuario (SwiftUI)
struct FinancialAnalyzerView: View {
    @StateObject private var analyzer = FinancialAnalyzer()

    var body: some View {
        VStack(spacing: 20) {
            Text("Analizador de Big Data Personal")
                .font(.title)
                .bold()
                .foregroundStyle(.blue)
                .multilineTextAlignment(.center)
            
            Text("Haz clic para generar y analizar miles de transacciones.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Analizar Datos") {
                Task {
                    await analyzer.analyzeData()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(analyzer.isAnalyzing)
            
            if analyzer.isAnalyzing {
                ProgressView()
            }
            
            ScrollView {
                Text(analyzer.analysisResult)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

// Vista previa para Xcode
#Preview {
    FinancialAnalyzerView()
}

// Extensión para simplificar la suma
extension Sequence where Element: Transaction {
    func sum<T: AdditiveArithmetic>(of property: KeyPath<Element, T>) -> T {
        reduce(.zero) { $0 + $1[keyPath: property] }
    }
}

