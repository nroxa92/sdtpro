// Potpuno zamijenite staru _buildInfoPanel metodu s ovom
  Widget _buildInfoPanel() {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold);
    final subtitleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.blueAccent);

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Referentni Podaci', style: titleStyle),
            const SizedBox(height: 16),
            
            Text('Otpor (NTC Senzori)', style: subtitleStyle),
            const SizedBox(height: 8),
            _buildInfoRow('20°C:', '~2500 Ω'),
            _buildInfoRow('25°C:', '~2100 Ω'),
            _buildInfoRow('30°C:', '~1700 Ω'),
            _buildInfoRow('35°C:', '~1450 Ω'),
            _buildInfoRow('40°C:', '~1200 Ω'),
            
            const Divider(height: 32, thickness: 1),

            Text('ECU Pinout', style: subtitleStyle),
            const SizedBox(height: 8),
            _buildInfoRow('EGTS:', 'B-G4 / F3'),
            _buildInfoRow('ECTS:', 'A-A1 / J2'),
            _buildInfoRow('EOTS:', 'A-H4 / J4'),
            _buildInfoRow('MATS:', 'A-H2 / H3'),
            _buildInfoRow('LTS:', 'B-E2 / G2'),
          ],
        ),
      ),
    );
  }

  // Dodajte ovu novu pomoćnu metodu bilo gdje unutar _TemperatureSensorsScreenState klase
  Widget _buildInfoRow(String label, String value) {
    final valueStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.bold,
      fontFamily: 'monospace', // Odlično za pinoute i vrijednosti
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          SelectableText(value, style: valueStyle), // SelectableText da se može kopirati
        ],
      ),
    );
  }