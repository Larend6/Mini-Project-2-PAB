import 'card_model.dart';

class UserCardModel {
  final String id;
  final int price;
  final int quantity;
  final CardModel card;

  UserCardModel({
    required this.id,
    required this.price,
    required this.quantity,
    required this.card,
  });

  factory UserCardModel.fromJson(Map<String, dynamic> json) {
    return UserCardModel(
      id: json['id'],
      price: json['price'],
      quantity: json['quantity'],
      card: CardModel.fromJson(json['cards']),
    );
  }
}