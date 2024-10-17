import 'package:flutter/material.dart';
import 'authenticate.dart';

class Sobre extends StatelessWidget {
  const Sobre({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre'),
        backgroundColor: const Color(0xFF448D9C),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título principal
              Center(
                child: const Text(
                  'Zen Journey',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF193339),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Texto descritivo
              const Text(
                'O Zen Journey é um aplicativo dedicado a ajudar você a alcançar uma vida melhor através de pequenas mudanças diárias. Nossa missão é guiá-lo em uma jornada de autodescoberta e bem-estar, fornecendo ferramentas e recursos para melhorar sua saúde mental, física e emocional.',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF193339),
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: screenHeight * 0.05),

              // Título de propósito
              Center(
                child: const Text(
                  'Propósito',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF193339),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),

              // Texto de propósito
              const Text(
                'Nosso propósito é criar um ambiente onde você possa crescer e se desenvolver de maneira saudável e sustentável. Acreditamos que pequenas mudanças podem ter um grande impacto ao longo do tempo, e estamos aqui para apoiar você em cada passo dessa jornada.',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF193339),
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: screenHeight * 0.05),

              // Adicionando um novo título de seções
              Center(
                child: const Text(
                  'Por que escolher o Zen Journey?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF193339),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),

              // Texto explicativo adicional
              const Text(
                'Nosso aplicativo oferece uma abordagem única para a saúde e bem-estar. Com recursos interativos e uma comunidade de apoio, você nunca estará sozinho em sua jornada. Junte-se a nós para transformar sua vida!',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF193339),
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: screenHeight * 0.05),

              // Botão para criar conta
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Authenticate()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.2,
                      vertical: 15,
                    ),
                    backgroundColor: const Color(0xFF448D9C),
                  ),
                  child: const Text(
                    'Criar Conta',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
