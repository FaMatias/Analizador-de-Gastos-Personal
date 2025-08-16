using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;

namespace AnalizadorDeDatos
{
    // Clase auxiliar para representar una transacción
    public class Transaction
    {
        public DateTime Date { get; set; }
        public decimal Amount { get; set; }
        public string Category { get; set; }
    }

    /// <summary>
    /// Lógica de interacción para MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        // --- 1. Lógica de Big Data (Generación y Análisis) ---

        // Método para generar datos sintéticos
        private List<Transaction> GenerateFinancialData(int numTransactions = 5000)
        {
            var transactions = new List<Transaction>();
            var random = new Random();
            var endDate = DateTime.Now;
            var startDate = endDate.AddYears(-1);

            string[] categories = { "Alimentos", "Transporte", "Ocio", "Facturas", "Salario", "Otros" };
            double[] categoryWeights = { 0.3, 0.2, 0.15, 0.15, 0.1, 0.1 };
            
            for (int i = 0; i < numTransactions; i++)
            {
                var daysRange = (endDate - startDate).Days;
                var randomDate = startDate.AddDays(random.Next(daysRange));
                
                var category = categories[WeightedChoice(random, categoryWeights)];
                decimal amount;

                if (category == "Salario")
                {
                    amount = (decimal)(random.NextDouble() * 1500 + 1500);
                }
                else if (category == "Facturas")
                {
                    amount = (decimal)(random.NextDouble() * -250 - 50);
                }
                else
                {
                    amount = (decimal)(random.NextDouble() * -145 - 5);
                    // Simular una anomalía
                    if (random.NextDouble() < 0.005)
                    {
                        amount = (decimal)(random.NextDouble() * -600 - 200);
                    }
                }

                transactions.Add(new Transaction
                {
                    Date = randomDate,
                    Amount = Math.Round(amount, 2),
                    Category = category
                });
            }

            return transactions;
        }

        private int WeightedChoice(Random random, double[] weights)
        {
            double totalWeight = weights.Sum();
            double randomNumber = random.NextDouble() * totalWeight;

            for (int i = 0; i < weights.Length; i++)
            {
                randomNumber -= weights[i];
                if (randomNumber <= 0)
                {
                    return i;
                }
            }
            return weights.Length - 1;
        }

        // --- 2. Evento del botón (conexión entre Frontend y Backend) ---

        private void AnalizarBtn_Click(object sender, RoutedEventArgs e)
        {
            ResultadosTextBlock.Text = "Generando 5000 transacciones...\n\n";

            // Generar los datos
            var transactions = GenerateFinancialData();
            
            // Analizar y construir los resultados
            var resultsBuilder = new StringBuilder();
            
            resultsBuilder.AppendLine("--- Análisis de Hábitos Financieros ---");
            resultsBuilder.AppendLine($"\nSe generaron y analizaron {transactions.Count} transacciones de 1 año.\n");

            // Gasto por categoría usando LINQ
            var spendByCategory = transactions.Where(t => t.Amount < 0)
                                              .GroupBy(t => t.Category)
                                              .Select(g => new { Category = g.Key, Total = g.Sum(t => -t.Amount) })
                                              .OrderByDescending(x => x.Total);
            
            resultsBuilder.AppendLine("1. Gasto Total por Categoría:");
            foreach (var item in spendByCategory)
            {
                resultsBuilder.AppendLine($"{item.Category}: {item.Total:N2} €");
            }
            resultsBuilder.AppendLine();

            // Detección de anomalías
            var anomalies = transactions.Where(t => t.Amount < -300)
                                        .OrderBy(t => t.Amount);

            resultsBuilder.AppendLine("2. ALERTA: Posibles Gastos Atípicos (Anomalías):");
            if (anomalies.Any())
            {
                foreach (var anomaly in anomalies)
                {
                    resultsBuilder.AppendLine($"🚨 Monto: {anomaly.Amount:N2} €, Categoría: {anomaly.Category}, Fecha: {anomaly.Date.ToShortDateString()}");
                }
            }
            else
            {
                resultsBuilder.AppendLine("No se detectaron gastos inusualmente altos.");
            }
            resultsBuilder.AppendLine();

            // Gasto promedio por día de la semana
            var spendByDay = transactions.Where(t => t.Amount < 0)
                                         .GroupBy(t => t.Date.DayOfWeek)
                                         .Select(g => new { Day = g.Key, Average = g.Average(t => -t.Amount) })
                                         .OrderByDescending(x => x.Average);

            resultsBuilder.AppendLine("3. Gasto Promedio por Día de la Semana:");
            foreach (var item in spendByDay)
            {
                resultsBuilder.AppendLine($"{item.Day}: {item.Average:N2} €");
            }
            resultsBuilder.AppendLine();
            
            var dayWithHighestSpend = spendByDay.FirstOrDefault();
            if (dayWithHighestSpend != null)
            {
                resultsBuilder.AppendLine($"El día con mayor gasto promedio es el {dayWithHighestSpend.Day}.");
            }

            // Actualizar la interfaz con todos los resultados
            ResultadosTextBlock.Text = resultsBuilder.ToString();
        }
    }
}
