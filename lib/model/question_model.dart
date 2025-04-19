class Question {
  final int id;
  final String konu;
  final String soru;
  final int cevap;
  final String aciklama;
  final List<String> secenekler;

  Question({
    required this.konu,
    required this.soru,
    required this.cevap,
    required this.aciklama,
    required this.secenekler,
    required this.id,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      konu: json['konu'] ?? '',
      soru: json['soru'] ?? '',
      cevap: json['cevap'] ?? 0,
      aciklama: json['aciklama'] ?? '',
      secenekler: List<String>.from(json['secenekler'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'konu': konu,
      'soru': soru,
      'cevap': cevap,
      'aciklama': aciklama,
      'secenekler': secenekler,
    };
  }
}
