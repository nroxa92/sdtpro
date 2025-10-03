import 'package:flutter/material.dart';
import 'main_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'O Aplikaciji SDT',
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Omogućava skrolanje ako je tekst duži
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SDT - Sustav za Dijagnostiku i Testiranje',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Verzija: 1.0.0',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 24),
              Text(
                'Ova aplikacija je razvijena kao dio završnog rada i služi za dijagnostiku i testiranje elektroničkih sustava vozila putem CAN sabirnice.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Autor: [Tvoje Ime i Prezime]', // <-- OVDJE UPIŠI SVOJE IME
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 16),
              Text(
                'Mentor: [Ime Mentora]', // <-- OVDJE UPIŠI IME MENTORA
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
