import 'package:flutter/material.dart';
import 'package:trackora/core/constants/app_colors.dart';

import '../../core/widgets/workforce_app_bar.dart';

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

  final _thoughts = [
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
      appBar: WorkforceAppBar(
        title: 'Daily Thoughts',
        actionLabel: 'Add thought',
        decorated: true,
        onTap: () {},
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
                return _ThoughtCard(
                  item: list[index],
                  onDelete: () {
                    setState(() {
                      _thoughts.removeWhere((thought) => thought.id == list[index].id);
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ThoughtCard extends StatelessWidget {
  const _ThoughtCard({required this.item, required this.onDelete});

  final ThoughtItem item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEF2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned(
            right: 16,
            top: 4,
            child: Text(
              '\u201C',
              style: TextStyle(
                fontFamily: 'Inter_Bold',
                fontSize: 72,
                height: 1,
                color: Color(0xFFE4EEEC),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 18, 16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(width: 16),
                  const ColoredBox(
                    color: Color(0xFF3DCEC0),
                    child: SizedBox(width: 3),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.text,
                          style: const TextStyle(
                            fontFamily: 'Inter_Bold',
                            color: Color(0xFF1E293B),
                            fontSize: 16,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.date,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Inter_Regular',
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 32,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8FBF3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF169A62),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item.active ? 'Active' : 'Inactive',
                                    style: const TextStyle(
                                      fontFamily: 'Inter_Bold',
                                      color: Color(0xFF157A4A),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: onDelete,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 32,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 16,
                                        color: Color(0xFF64748B),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Delete',
                                        style: TextStyle(
                                          fontFamily: 'Inter_Bold',
                                          color: Color(0xFF334155),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
