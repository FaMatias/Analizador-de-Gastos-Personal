// --- 1. Generación de Datos Sintéticos ---
// Esto simula la "carga de datos" sin necesidad de un servidor o archivo.
function generarDatosFinancieros(numTransacciones = 5000) {
    const categorias = ['Alimentos', 'Transporte', 'Ocio', 'Facturas', 'Salario', 'Otros'];
    const pesosCategorias = [0.3, 0.2, 0.15, 0.15, 0.1, 0.1];
    const transacciones = [];
    const fechaActual = new Date();
    const unAnioEnMs = 365 * 24 * 60 * 60 * 1000;

    for (let i = 0; i < numTransacciones; i++) {
        const fecha = new Date(fechaActual.getTime() - Math.floor(Math.random() * unAnioEnMs));
        const categoria = categorias[Math.floor(Math.random() * categorias.length)];
        let monto = 0;

        if (categoria === 'Salario') {
            monto = (Math.random() * 1500 + 1500).toFixed(2);
        } else if (categoria === 'Facturas') {
            monto = -(Math.random() * 250 + 50).toFixed(2);
        } else {
            monto = -(Math.random() * 145 + 5).toFixed(2);
            // Simular un gasto atípico (anomalía)
            if (Math.random() < 0.005) {
                monto = -(Math.random() * 600 + 200).toFixed(2);
            }
        }

        transacciones.push({
            fecha: fecha,
            monto: parseFloat(monto),
            categoria: categoria,
            diaSemana: fecha.toLocaleDateString('es-ES', { weekday: 'long' })
        });
    }

    return transacciones;
}

// --- 2. Análisis de los Datos ---
function analizarGastos(transacciones) {
    const resultados = {
        gastoMensual: {},
        gastoPorCategoria: {},
        gastosAtipicos: [],
        gastoPorDiaSemana: {},
        totalGasto: 0
    };

    const diasSemana = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
    diasSemana.forEach(dia => resultados.gastoPorDiaSemana[dia] = { monto: 0, count: 0 });

    transacciones.forEach(transaccion => {
        const mesAnio = `${transaccion.fecha.getFullYear()}-${(transaccion.fecha.getMonth() + 1).toString().padStart(2, '0')}`;
        const monto = transaccion.monto;

        // Si es un gasto (monto negativo)
        if (monto < 0) {
            resultados.totalGasto += Math.abs(monto);
            
            // Gasto mensual
            resultados.gastoMensual[mesAnio] = (resultados.gastoMensual[mesAnio] || 0) + Math.abs(monto);
            
            // Gasto por categoría
            resultados.gastoPorCategoria[transaccion.categoria] = (resultados.gastoPorCategoria[transaccion.categoria] || 0) + Math.abs(monto);
            
            // Gasto por día de la semana
            const diaSemana = transaccion.diaSemana.toLowerCase();
            if (resultados.gastoPorDiaSemana[diaSemana]) {
                resultados.gastoPorDiaSemana[diaSemana].monto += Math.abs(monto);
                resultados.gastoPorDiaSemana[diaSemana].count += 1;
            }

            // Detección de anomalías
            if (monto < -300) {
                resultados.gastosAtipicos.push(transaccion);
            }
        }
    });

    // Calcular promedios por día de la semana
    for (const dia in resultados.gastoPorDiaSemana) {
        if (resultados.gastoPorDiaSemana[dia].count > 0) {
            resultados.gastoPorDiaSemana[dia].promedio = (resultados.gastoPorDiaSemana[dia].monto / resultados.gastoPorDiaSemana[dia].count).toFixed(2);
        } else {
            resultados.gastoPorDiaSemana[dia].promedio = 0;
        }
    }

    return resultados;
}

// --- 3. Renderizar los Resultados en la Interfaz ---
function renderizarResultados(datos) {
    const resultadosDiv = document.getElementById('resultados');
    resultadosDiv.innerHTML = ''; // Limpiar resultados anteriores
    
    // Total de transacciones
    resultadosDiv.innerHTML += `
        <p>Se generaron y analizaron **${datos.length}** transacciones de 1 año.</p>
    `;

    // 1. Gasto por categoría
    const categoriasOrdenadas = Object.keys(datos.gastoPorCategoria).sort((a, b) => datos.gastoPorCategoria[b] - datos.gastoPorCategoria[a]);
    let htmlCategoria = '<h2>1. Gasto Total por Categoría</h2><ul>';
    categoriasOrdenadas.forEach(cat => {
        htmlCategoria += `<li>${cat}: ${datos.gastoPorCategoria[cat].toFixed(2)} €</li>`;
    });
    htmlCategoria += '</ul>';
    resultadosDiv.innerHTML += htmlCategoria;

    // 2. Gasto por día de la semana
    const diasOrdenados = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
    let htmlDias = '<h2>2. Gasto Promedio por Día de la Semana</h2><ul>';
    diasOrdenados.forEach(dia => {
        const promedio = datos.gastoPorDiaSemana[dia].promedio;
        htmlDias += `<li>${dia}: ${promedio} €</li>`;
    });
    htmlDias += '</ul>';
    const diaMax = Object.keys(datos.gastoPorDiaSemana).reduce((a, b) => parseFloat(datos.gastoPorDiaSemana[a].promedio) > parseFloat(datos.gastoPorDiaSemana[b].promedio) ? a : b);
    htmlDias += `<p><strong>El día de la semana con mayor gasto promedio es el ${diaMax}.</strong></p>`;
    resultadosDiv.innerHTML += htmlDias;

    // 3. Alerta de gastos atípicos
    let htmlAtipicos = '<h2>3. ALERTA: Posibles Gastos Atípicos</h2>';
    if (datos.gastosAtipicos.length > 0) {
        htmlAtipicos += '<p>Se han detectado los siguientes gastos inusuales:</p><ul>';
        datos.gastosAtipicos.forEach(gasto => {
            htmlAtipicos += `<li class="anomalia">Monto: ${gasto.monto.toFixed(2)} €, Categoría: ${gasto.categoria}, Fecha: ${gasto.fecha.toLocaleDateString()}</li>`;
        });
        htmlAtipicos += '</ul>';
    } else {
        htmlAtipicos += '<p>No se detectaron gastos atípicos por encima del umbral de -300€.</p>';
    }
    resultadosDiv.innerHTML += htmlAtipicos;
}

// --- 4. Event Listener para el botón ---
document.getElementById('analizarBtn').addEventListener('click', () => {
    // 1. Generar los datos
    const transacciones = generarDatosFinancieros();
    // 2. Analizar los datos
    const resultadosAnalisis = analizarGastos(transacciones);
    // 3. Renderizar en la página
    renderizarResultados(resultadosAnalisis);
});

