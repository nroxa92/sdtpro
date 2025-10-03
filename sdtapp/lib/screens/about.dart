import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("O Aplikaciji"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SeaDoo miniTool (SDmT)",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text("Verzija 1.0.0"),
            const SizedBox(height: 24),
            const Text(
              "Prijenosni dijagnostički alat za Seadoo plovila, dizajniran za brzu i efikasnu dijagnostiku na terenu.",
            ),
            const SizedBox(height: 24),
            Text(
              "Autor",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              "Aplikaciju i hardver razvio je jetski.doctor.",
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text("@jetski.doctor"),
              onPressed: () {
                // Ovdje se može dodati link za otvaranje Instagrama
              },
            ),
          ],
        ),
      ),
    );
  }
}

