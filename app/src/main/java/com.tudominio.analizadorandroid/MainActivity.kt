package com.tudominio.analizadorandroid // Asegúrate de que este sea el nombre correcto de tu paquete

import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.ProgressBar
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.time.LocalDate
import java.time.temporal.ChronoUnit
import kotlin.random.Random

// --- 1. Modelo de Datos (data class) ---
data class Transaction(
    val date: LocalDate,
    val amount: Double,
    val category: String
)

class MainActivity : AppCompatActivity() {

    private lateinit var analyzeButton: Button
    private lateinit var progressBar: ProgressBar
    private lateinit var resultsTextView: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Obtener referencias a los elementos de la interfaz por su ID
        analyzeButton = findViewById(R.id.analyzeButton)
        progressBar = findViewById(R.id.progressBar)
        resultsTextView = findViewById(R.id.resultsTextView)

        // --- 2. Evento del botón (conexión entre Frontend y Backend) ---
        analyzeButton.setOnClickListener {
            // Iniciar el análisis en un hilo separado para no bloquear la interfaz
            CoroutineScope(Dispatchers.Main).launch {
                // Mostrar el indicador de carga y deshabilitar el botón
                progressBar.visibility = View.VISIBLE
                analyzeButton.isEnabled = false
                resultsTextView.text = "Analizando, por favor espera..."

                // Ejecutar la lógica de análisis en un hilo de fondo
                val results = withContext(Dispatchers.IO) {
                    analyzeData()
                }

                // Actualizar la interfaz con los resultados finales
                resultsTextView.text = results
                progressBar.visibility = View.GONE
                analyzeButton.isEnabled = true
            }
        }
    }

    // --- 3. Lógica de Big Data (Generación y Análisis) ---

    private suspend fun analyzeData(): String {
        // Generar los datos
        val transactions = generateFinancialData(5000)

        // Analizar y construir los resultados
        val resultsBuilder = StringBuilder()
        resultsBuilder.append("--- Análisis de Hábitos Financieros ---\n")
        resultsBuilder.append("\nSe generaron y analizaron ${transactions.size} transacciones de 1 año.\n\n")

        // Gasto por categoría usando colecciones de Kotlin
        val spendByCategory = transactions.filter { it.amount < 0 }
            .groupBy { it.category }
            .mapValues { it.value.sumOf { t -> t.amount.absoluteValue } }
            .entries.sortedByDescending { it.value }

        resultsBuilder.append("1. Gasto Total por Categoría:\n")
        spendByCategory.forEach { entry ->
            resultsBuilder.append("${entry.key}: ${String.format("%.2f", entry.value)} €\n")
        }
        resultsBuilder.append("\n")

        // Detección de anomalías
        val anomalies = transactions.filter { it.amount < -300 }
            .sortedBy { it.amount }

        resultsBuilder.append("2. ALERTA: Posibles Gastos Atípicos:\n")
        if (anomalies.isNotEmpty()) {
            anomalies.forEach { anomaly ->
                resultsBuilder.append("🚨 Monto: ${String.format("%.2f", anomaly.amount)} €, Categoría: ${anomaly.category}, Fecha: ${anomaly.date}\n")
            }
        } else {
            resultsBuilder.append("No se detectaron gastos inusualmente altos.\n")
        }
        resultsBuilder.append("\n")

        return resultsBuilder.toString()
    }

    // Método para generar datos sintéticos
    private fun generateFinancialData(numTransactions: Int): List<Transaction> {
        val transactions = mutableListOf<Transaction>()
        val random = Random.Default
        val endDate = LocalDate.now()
        val startDate = endDate.minusYears(1)

        val categories = listOf("Alimentos", "Transporte", "Ocio", "Facturas", "Salario", "Otros")
        val categoryWeights = listOf(0.3, 0.2, 0.15, 0.15, 0.1, 0.1)
        val totalWeight = categoryWeights.sum()

        for (i in 0 until numTransactions) {
            val randomDays = random.nextInt(ChronoUnit.DAYS.between(startDate, endDate).toInt())
            val randomDate = startDate.plusDays(randomDays.toLong())
            val category = weightedChoice(random, categories, categoryWeights, totalWeight)
            var amount: Double

            when (category) {
                "Salario" -> amount = random.nextDouble(1500.0, 3000.0)
                "Facturas" -> amount = -random.nextDouble(50.0, 300.0)
                else -> {
                    amount = -random.nextDouble(5.0, 150.0)
                    if (random.nextDouble() < 0.005) {
                        amount = -random.nextDouble(200.0, 800.0)
                    }
                }
            }

            transactions.add(Transaction(randomDate, amount, category))
        }
        return transactions
    }

    private fun weightedChoice(random: Random, categories: List<String>, weights: List<Double>, totalWeight: Double): String {
        var randomNumber = random.nextDouble() * totalWeight
        for (i in categories.indices) {
            randomNumber -= weights[i]
            if (randomNumber <= 0) {
                return categories[i]
            }
        }
        return categories.last()
    }
}
