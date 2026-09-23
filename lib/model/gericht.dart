class Gericht {
  const Gericht({
    this.id,
    required this.name,
    required this.beschreibung,
    required this.preis,
  });

  final int? id;
  final String name;
  final String beschreibung;
  final double preis;

  factory Gericht.fromMap(Map<String, Object?> map) => Gericht(
    id: map['id'] as int,
    name: map['name'] as String,
    beschreibung: map['beschreibung'] as String,
    preis: (map['preis'] as num).toDouble(),
  );

  Map<String, Object?> toMap() => {
    'name': name,
    'beschreibung': beschreibung,
    'preis': preis,
  };
}
