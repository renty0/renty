import 'package:flutter/material.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/pages/home_widgets/home_item_card.dart';

class HomePopular extends StatelessWidget {
  final List<ItemListDto> items;
  const HomePopular({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: items.length,
        itemBuilder: (_, i) => SizedBox(
          width: 160,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: HomeItemCard(item: items[i]),
          ),
        ),
      ),
    );
  }
}
