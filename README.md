Mi Proyecto: Analizador de Gastos Personal (Multiplataforma)
¡Hola! ¡Bienvenidos a mi proyecto! Este es un repositorio que creé para explorar cómo un mismo concepto—un analizador de gastos que detecta patrones y anomalías—puede ser implementado en diferentes lenguajes y frameworks.
La idea es simular un conjunto de "Big Data" (5000 transacciones financieras) y luego aplicar análisis para encontrar insights útiles, todo dentro de una aplicación funcional.
Tabla de Contenidos
Versión Web: HTML, CSS & JavaScript
Versión de Escritorio: Python con PySimpleGUI
Versión de Escritorio: C# con .NET y WPF
Versión Nativa Móvil: Kotlin con Android Studio
Versión Nativa Móvil: Swift con SwiftUI
1. Versión Web: HTML, CSS & JavaScript
Esta fue la primera versión que hice. Es una aplicación web estática, lo que significa que no necesita un servidor para funcionar. La lógica de generación y análisis de datos está completamente en el navegador.
index.html: La estructura principal de la página.
style.css: El estilo visual, para que la app se vea bien.
script.js: La magia del análisis. Genera las 5000 transacciones y procesa los resultados.
¿Cómo funciona?
Es súper simple. Solo tienes que abrir el archivo index.html en tu navegador web (Chrome, Firefox, etc.) y listo.
2. Versión de Escritorio: Python con PySimpleGUI
Para esta versión, quise crear una aplicación de escritorio que funcionara de forma local. Usé Python por su potencia en el análisis de datos y PySimpleGUI para hacer una interfaz gráfica muy sencilla.
analizador_app.py: Todo el código está en este único archivo.
¿Cómo funciona?
Necesitas tener Python instalado y las bibliotecas pandas y PySimpleGUI.
Abre tu terminal.
Instala las dependencias: pip install pandas PySimpleGUI
Ejecuta el archivo: python analizador_app.py
3. Versión de Escritorio: C# con .NET y WPF
Aquí me aventuré en el mundo de las aplicaciones de escritorio para Windows. Usé C# con el framework WPF para separar la interfaz de usuario de la lógica, lo cual fue un aprendizaje muy interesante.
MainWindow.xaml: Define el diseño de la interfaz de la ventana.
MainWindow.xaml.cs: Contiene el código de C# que genera y analiza los datos.
¿Cómo funciona?
Necesitas tener Visual Studio instalado.
Crea un nuevo proyecto de "WPF Application".
Copia el código del MainWindow.xaml y del MainWindow.xaml.cs en sus respectivos archivos del proyecto.
Ejecuta el proyecto desde Visual Studio (presionando F5).
4. Versión Nativa Móvil: Kotlin con Android Studio
Para esta versión, me concentré en crear una aplicación nativa para Android. Usé Android Studio y Kotlin, que es el lenguaje recomendado por Google para este tipo de desarrollo.
activity_main.xml: Define la interfaz de usuario de la pantalla de Android.
MainActivity.kt: Contiene toda la lógica de la aplicación en Kotlin.
¿Cómo funciona?
Necesitas tener Android Studio instalado.
Crea un nuevo proyecto con la plantilla "Empty Views Activity" y selecciona Kotlin como lenguaje.
Copia el código en los archivos activity_main.xml y MainActivity.kt de tu proyecto.
Ejecuta la aplicación en un emulador o un dispositivo Android.
5. Versión Nativa Móvil: Swift con SwiftUI
Finalmente, para la versión de iOS, usé Swift y SwiftUI, el framework más moderno de Apple para la interfaz de usuario. Fue increíble ver cómo funcionaba con un solo archivo.
ContentView.swift: Contiene tanto la lógica de la interfaz como el análisis de datos.
¿Cómo funciona?
Necesitas tener Xcode instalado en un Mac.
Crea un nuevo proyecto "App" y selecciona SwiftUI como Interfaz.
Copia y pega el código del ContentView.swift en tu proyecto.
Ejecuta la aplicación en un simulador de iPhone.
