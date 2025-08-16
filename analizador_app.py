import pandas as pd
import numpy as np
import random
from datetime import datetime, timedelta
import PySimpleGUI as sg

# --- 1. Lógica de Big Data (generación y análisis) ---

def generar_datos_financieros(num_transacciones=5000):
    """
    Genera un DataFrame de Pandas con datos financieros simulados.
    Esto sustituye la carga de un archivo de Excel o base de datos.
    """
    start_date = datetime.now() - timedelta(days=365)
    fechas = [start_date + timedelta(days=random.randint(0, 365)) for _ in range(num_transacciones)]
    
    categorias = ['Alimentos', 'Transporte', 'Ocio', 'Facturas', 'Salario', 'Otros']
    pesos_categorias = [0.3, 0.2, 0.15, 0.15, 0.1, 0.1]
    
    transacciones = []
    
    for _ in range(num_transacciones):
        categoria = random.choices(categorias, weights=pesos_categorias, k=1)[0]
        monto = 0
        
        if categoria == 'Salario':
            monto = round(random.uniform(1500, 3000), 2)
        elif categoria == 'Facturas':
            monto = round(random.uniform(-50, -300), 2)
        else:
            monto = round(random.uniform(-5, -150), 2)
            if random.random() < 0.005:  # Simular una anomalía
                monto = round(random.uniform(-200, -800), 2)

        transacciones.append({
            'Fecha': random.choice(fechas),
            'Monto': monto,
            'Categoria': categoria,
            'Descripcion': f'Gasto en {categoria}'
        })
        
    df = pd.DataFrame(transacciones)
    df['Fecha'] = pd.to_datetime(df['Fecha'])
    return df

def analizar_gastos(df):
    """
    Realiza un análisis de los datos generados para encontrar patrones.
    """
    resultados_str = "--- Análisis de Hábitos Financieros ---\n\n"
    
    # Gasto total por mes
    df_gastos = df[df['Monto'] < 0]
    df_gastos['Mes'] = df_gastos['Fecha'].dt.strftime('%Y-%m')
    gasto_mensual = df_gastos.groupby('Mes')['Monto'].sum().abs()
    resultados_str += "1. Gasto Total Mensual:\n" + gasto_mensual.sort_index().to_string() + "\n\n"
    
    # Gasto por categoría
    gasto_por_categoria = df_gastos.groupby('Categoria')['Monto'].sum().abs()
    resultados_str += "2. Gasto Total por Categoría:\n" + gasto_por_categoria.sort_values(ascending=False).to_string() + "\n\n"
    
    # Detección de anomalías
    gastos_anomalos = df_gastos[df_gastos['Monto'] < -300].sort_values(by='Monto')
    resultados_str += "3. ALERTA: Posibles Gastos Atípicos (Anomalías):\n"
    if not gastos_anomalos.empty:
        resultados_str += gastos_anomalos[['Fecha', 'Monto', 'Categoria']].to_string(index=False) + "\n\n"
    else:
        resultados_str += "No se detectaron gastos inusualmente altos.\n\n"
        
    # Gasto promedio por día de la semana
    df_gastos['DiaSemana'] = df_gastos['Fecha'].dt.day_name()
    gasto_por_dia = df_gastos.groupby('DiaSemana')['Monto'].mean().abs()
    dias_semana_ordenados = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    
    resultados_str += "4. Gasto Promedio por Día de la Semana:\n" + gasto_por_dia.reindex(dias_semana_ordenados).to_string() + "\n"
    resultados_str += f"\nEl día en que más gastas es: {gasto_por_dia.idxmax()}\n"
    
    return resultados_str

# --- 2. Diseño del Frontend con PySimpleGUI ---

sg.theme('LightBlue') # Elige un tema visual

layout = [
    [sg.Text('Analizador de Big Data Personal', font=('Helvetica', 18, 'bold'), text_color='#007BFF')],
    [sg.Text('Haz clic en el botón para generar y analizar 5000 transacciones.', font=('Helvetica', 10))],
    [sg.Button('Analizar Datos', key='-ANALIZAR-', font=('Helvetica', 12, 'bold'), button_color=('white', '#007BFF'))],
    [sg.Multiline(size=(80, 25), key='-OUTPUT-', autoscroll=True, font=('Courier', 10))]
]

# Crear la ventana
window = sg.Window('Análisis de Datos Financieros', layout, finalize=True)

# --- 3. Bucle principal de la aplicación ---

while True:
    event, values = window.read()
    
    # El usuario cierra la ventana
    if event == sg.WIN_CLOSED:
        break
    
    # El usuario hace clic en el botón "Analizar Datos"
    if event == '-ANALIZAR-':
        window['-OUTPUT-'].update('Generando 5000 transacciones...\n')
        window.refresh()
        
        # Lógica de Big Data
        datos = generar_datos_financieros()
        resultados = analizar_gastos(datos)
        
        # Muestra los resultados en el campo de texto de la ventana
        window['-OUTPUT-'].update(resultados)
        
window.close()
  
