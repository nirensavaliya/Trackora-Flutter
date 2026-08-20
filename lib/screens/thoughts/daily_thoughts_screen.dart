import 'package:flutter/material.dart';
import 'package:trackora/core/constants/app_colors.dart';

class ThoughtItem {
  const ThoughtItem({
    required this.id,
    required this.text,
    required this.date,
    required this.active,
  });

  final String id;
  final String text;
  final String date;
  final bool active;
}

class DailyThoughtsScreen extends StatefulWidget {
  const DailyThoughtsScreen({super.key});

  @override
  State<DailyThoughtsScreen> createState() => _DailyThoughtsScreenState();
}

class _DailyThoughtsScreenState extends State<DailyThoughtsScreen> {
  final _search = TextEditingController();

  final _thoughts = const [
    ThoughtItem(
      id: '1',
      text:
          "Success doesn't come from what you do occasionally. It comes from what you do consistently.",
      date: '20 Aug 2026',
      active: true,
    ),
    ThoughtItem(
      id: '2',
      text: 'Small daily improvements lead to stunning results over time.',
      date: '19 Aug 2026',
      active: true,
    ),
    ThoughtItem(
      id: '3',
      text:
          'Discipline is choosing between what you want now and what you want most.',
      date: '18 Aug 2026',
      active: true,
    ),
    ThoughtItem(
      id: '4',
      text:
          'Your attitude determines your direction. Stay focused and keep going.',
      date: '17 Aug 2026',
      active: true,
    ),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<ThoughtItem> get _visible {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _thoughts;
    return _thoughts.where((t) => t.text.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _visible;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daily Thoughts',
          style: TextStyle(
            fontFamily: 'Inter_Bold',
            color: AppColors.textDark,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add, color: AppColors.textDark),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search thought...',
                hintStyle: const TextStyle(
                  fontFamily: 'Inter_Regular',
                  color: AppColors.textGrey,
                  fontSize: 14,
                ),
                suffixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE6EBEA)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.appColor),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return _ThoughtCard(index: index + 1, item: list[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ThoughtCard extends StatelessWidget {
  const _ThoughtCard({required this.index, required this.item});

  final int index;
  final ThoughtItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '$index',
              style: const TextStyle(
                fontFamily: 'Inter_SemiBold',
                color: AppColors.textGrey,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.text,
                  style: const TextStyle(
                    fontFamily: 'Inter_SemiBold',
                    color: AppColors.textDark,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      item.date,
                      style: const TextStyle(
                        fontFamily: 'Inter_Regular',
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.appColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          fontFamily: 'Inter_Medium',
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textGrey),
            onSelected: (_) {},
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}
