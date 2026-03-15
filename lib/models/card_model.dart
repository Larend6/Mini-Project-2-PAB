class CardModel {
  final String id;
  final String name;
  final String series;
  final String rarity;
  final String? imageUrl;

  CardModel({
    required this.id,
    required this.name,
    required this.series,
    required this.rarity,
    this.imageUrl,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      name: json['name'],
      series: json['series'],
      rarity: json['rarity'],
      imageUrl: json['image_url'],
    );
  }
}