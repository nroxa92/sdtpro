class LiveData {
  final double rpm;
  final double throttle;
  final double ect; // Engine Coolant Temperature
  final double eot; // Engine Oil Temperature
  final double speed;
  final double fuel;
  final double map; // Manifold Absolute Pressure
  final double mat; // Manifold Air Temperature
  final double egt; // Exhaust Gas Temperature

  LiveData({
    required this.rpm,
    required this.throttle,
    required this.ect,
    required this.eot,
    required this.speed,
    required this.fuel,
    required this.map,
    required this.mat,
    required this.egt,
  });

  // Tvornica za kreiranje objekta iz JSON-a
  factory LiveData.fromJson(Map<String, dynamic> json) {
    // Pomoćna funkcija da se izbjegne greška ako podatak nije broj
    double parseDouble(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }
      return -1.0;
    }

    return LiveData(
      rpm: parseDouble(json['rpm']),
      throttle: parseDouble(json['throttle']),
      ect: parseDouble(json['ect']),
      eot: parseDouble(json['eot']),
      speed: parseDouble(json['speed']),
      fuel: parseDouble(json['fuel']),
      map: parseDouble(json['map']),
      mat: parseDouble(json['mat']),
      egt: parseDouble(json['egt']),
    );
  }

  // Tvornica za početno, prazno stanje
  factory LiveData.initial() {
    return LiveData(
      rpm: -1,
      throttle: -1,
      ect: -1,
      eot: -1,
      speed: -1,
      fuel: -1,
      map: -1,
      mat: -1,
      egt: -1,
    );
  }
}