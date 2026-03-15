import 'package:supabase_flutter/supabase_flutter.dart';

class CardService {

  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getUserCards() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return [];
    }

    final data = await supabase
        .from('user_cards')
        .select('''
        id,
        price,
        quantity,
        cards(
          id,
          name,
          series,
          rarity,
          image_url
        )
        ''')
        .eq('user_id', user.id);

    return data;
  }

  Future<void> addCard({
    String? cardId,
    required String name,
    required String series,
    required String rarity,
    String? imageUrl,
    required int price,
    required int quantity,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User harus login untuk menambahkan kartu');
    }

    String finalCardId = cardId ?? '';
    if (finalCardId.isEmpty) {
      final inserted = await supabase.from('cards').insert({
        'name': name,
        'series': series,
        'rarity': rarity,
        'image_url': imageUrl,
      }).select('id').single();
      if (inserted['id'] == null) {
        throw Exception('Gagal membuat kartu baru');
      }
      finalCardId = inserted['id'].toString();
    } else {
      await supabase.from('cards').update({
        'name': name,
        'series': series,
        'rarity': rarity,
        'image_url': imageUrl,
      }).eq('id', finalCardId);
    }

    await supabase.from('user_cards').insert({
      'user_id': user.id,
      'card_id': finalCardId,
      'price': price,
      'quantity': quantity,
    });
  }

  Future<void> updateCardAndUserCard({
    required String userCardId,
    required String cardId,
    required String name,
    required String series,
    required String rarity,
    String? imageUrl,
    required int price,
    required int quantity,
  }) async {
    await supabase.from('cards').update({
      'name': name,
      'series': series,
      'rarity': rarity,
      'image_url': imageUrl,
    }).eq('id', cardId);

    await supabase.from('user_cards').update({
      'price': price,
      'quantity': quantity,
    }).eq('id', userCardId);
  }

  Future<void> updateCard({
    required String id,
    required int price,
    required int quantity,
  }) async {

    await supabase
        .from('user_cards')
        .update({
          "price": price,
          "quantity": quantity,
        })
        .eq("id", id);
  }

  Future<void> deleteCard(String id) async {

    await supabase
        .from('user_cards')
        .delete()
        .eq("id", id);
  }
}