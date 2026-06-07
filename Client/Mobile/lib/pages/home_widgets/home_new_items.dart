import 'package:flutter/material.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/pages/home_widgets/home_item_card.dart';

class HomeNewItems extends StatelessWidget {
  final List<ItemListDto> items;
  const HomeNewItems({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => HomeItemCard(item: items[i]),
      ),
    );
  }
}
