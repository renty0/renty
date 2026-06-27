import 'package:flutter/material.dart';

class HomeDestinations extends StatelessWidget {
  const HomeDestinations({super.key});

  static const _destinations = [
    {'name': 'Dahab',   'desc': 'Water sports & diving paradise', 'emoji': '🏄'},
    {'name': 'El Gouna','desc': 'Lagoons, kite & padel',          'emoji': '🪁'},
    {'name': 'Cairo',   'desc': 'Urban rentals & fitness gear',    'emoji': '🏙️'},
    {'name': 'Soma Bay','desc': 'World-class watersports hub',     'emoji': '🌊'},
  ];

  // Unique gradients per destination
  static const _gradients = [
    [Color(0xFF0369A1), Color(0xFF0EA5E9)],
    [Color(0xFF065F46), Color(0xFF10B981)],
    [Color(0xFF1E3A5F), Color(0xFF2563EB)],
    [Color(0xFF0C4A6E), Color(0xFF0891B2)],
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _destinations.length,
        itemBuilder: (context, i) {
          final d = _destinations[i];
          final colors = _gradients[i];
          return Container(
            width: 145,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withValues(alpha: 0.3),
                  blurRadius: 10, offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d['emoji']!, style: const TextStyle(fontSize: 26)),
                  const Spacer(),
                  Text(
                    d['name']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    d['desc']!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 11,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
