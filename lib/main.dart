import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adivina el Número',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late int _numeroSecreto;
  int _intentos = 0;
  int _intentosRestantes = 5; // Límite de 5 intentos
  String _mensaje = '';
  final TextEditingController _controller = TextEditingController();
  bool _juegoTerminado = false;
  bool _juegoPerdido = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _mensajesIniciales = [
    '🎯 ¿Podrás adivinar el número? (5 intentos)',
    '🔮 Concéntrate... solo 5 oportunidades',
    '✨ La suerte está de tu lado - 5 intentos',
    '🌟 Adivina el número secreto en 5 intentos',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _iniciarJuego();
  }

  void _iniciarJuego() {
    setState(() {
      _numeroSecreto = Random().nextInt(100) + 1;
      _intentos = 0;
      _intentosRestantes = 5;
      _mensaje = _mensajesIniciales[Random().nextInt(_mensajesIniciales.length)];
      _juegoTerminado = false;
      _juegoPerdido = false;
      _controller.clear();
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _verificarAdivinanza() {
    if (_juegoTerminado || _juegoPerdido) return;

    final String texto = _controller.text.trim();
    if (texto.isEmpty) {
      _mostrarMensajeTemporal('📝 ¡Ingresa un número!', Colors.orange);
      return;
    }

    final int? adivinanza = int.tryParse(texto);
    if (adivinanza == null || adivinanza < 1 || adivinanza > 100) {
      _mostrarMensajeTemporal('⚠️ Solo números entre 1 y 100', Colors.orange);
      return;
    }

    setState(() {
      _intentos++;
      _intentosRestantes--;
      _controller.clear();

      if (adivinanza == _numeroSecreto) {
        _mensaje = '🎉 ¡CORRECTO! 🎉\nLo lograste en $_intentos ${_intentos == 1 ? 'intento' : 'intentos'}';
        _juegoTerminado = true;
      } else if (_intentosRestantes == 0) {
        _mensaje = '😢 ¡GAME OVER! 😢\nEl número secreto era $_numeroSecreto';
        _juegoPerdido = true;
      } else if (adivinanza < _numeroSecreto) {
        _mensaje = '⬆️ ¡Más alto! (Te quedan $_intentosRestantes intentos)';
      } else {
        _mensaje = '⬇️ ¡Más bajo! (Te quedan $_intentosRestantes intentos)';
      }
    });
    
    _animationController.reset();
    _animationController.forward();
  }

  void _mostrarMensajeTemporal(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getMensajeColor() {
    if (_juegoTerminado) return Colors.green;
    if (_juegoPerdido) return Colors.red;
    if (_mensaje.contains('alto')) return Colors.blue;
    if (_mensaje.contains('bajo')) return Colors.red;
    return Colors.indigo;
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade50,
              Colors.white,
              Colors.indigo.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header con animación
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            TweenAnimationBuilder(
                              duration: const Duration(seconds: 2),
                              tween: Tween<double>(begin: 0, end: 2 * pi),
                              builder: (context, double value, child) {
                                return Transform.rotate(
                                  angle: value,
                                  child: child,
                                );
                              },
                              child: Icon(
                                _juegoPerdido ? Icons.sentiment_dissatisfied : Icons.psychology_alt,
                                size: 60,
                                color: _juegoPerdido ? Colors.red : Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Contenedor del mensaje principal
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _getMensajeColor().withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          _mensaje,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: _getMensajeColor(),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Contador de intentos 
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: _intentosRestantes <= 2 ? Colors.red.shade50 : Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: _intentosRestantes <= 2 ? Colors.red.shade200 : Colors.indigo.shade200,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _intentosRestantes <= 2 ? Icons.warning : Icons.hourglass_bottom,
                              color: _intentosRestantes <= 2 ? Colors.red : Colors.indigo,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Intentos restantes: $_intentosRestantes',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _intentosRestantes <= 2 ? Colors.red : Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Campo de texto 
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          enabled: !_juegoTerminado && !_juegoPerdido,
                          style: const TextStyle(fontSize: 18),
                          decoration: InputDecoration(
                            hintText: 'Escribe tu número aquí',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.casino, color: Colors.indigo),
                            suffixIcon: _controller.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.grey),
                                    onPressed: () => _controller.clear(),
                                  )
                                : null,
                          ),
                          onSubmitted: (_) => _verificarAdivinanza(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Botón principal 
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: (_juegoTerminado || _juegoPerdido) ? null : _verificarAdivinanza,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _juegoTerminado 
                                ? Colors.green 
                                : (_juegoPerdido ? Colors.red : Colors.indigo),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: _juegoTerminado 
                                ? Colors.green.shade100 
                                : (_juegoPerdido ? Colors.red.shade100 : Colors.indigo.shade100),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _juegoTerminado 
                                    ? Icons.emoji_events 
                                    : (_juegoPerdido ? Icons.sentiment_very_dissatisfied : Icons.check_circle_outline)
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _juegoTerminado 
                                    ? '¡Felicidades!' 
                                    : (_juegoPerdido ? 'Perdiste' : 'Adivinar'),
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Botón de reinicio con animación
                      if (_juegoTerminado || _juegoPerdido)
                        TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 500),
                          tween: Tween<double>(begin: 0, end: 1),
                          builder: (context, double value, child) {
                            return Transform.scale(
                              scale: value,
                              child: child,
                            );
                          },
                          child: OutlinedButton.icon(
                            onPressed: _iniciarJuego,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.indigo,
                              side: const BorderSide(color: Colors.indigo, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            ),
                            icon: const Icon(Icons.replay),
                            label: const Text(
                              'Jugar de nuevo',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}