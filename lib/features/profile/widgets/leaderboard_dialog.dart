import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderboardDialog extends StatelessWidget {
  LeaderboardDialog({super.key});

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _fetch(String field) async {
    final snap = await _firestore
        .collection('users')
        .orderBy(field, descending: true)
        .limit(15)
        .get();
    return snap.docs;
  }

  String _username(Map<String, dynamic> data) {
    return (data['username'] ??
            data['displayName'] ??
            data['email'] ??
            'Unknown')
        .toString();
  }

  Widget _buildEntry({
    required int index,
    required String name,
    required String value,
  }) {
    final bool isTop3 = index < 3;
    final Color nameColor = switch (index) {
      0 => const Color(0xFFFFD645),
      1 => const Color(0xFFC0C7D1),
      2 => const Color(0xFFCD7F32),
      _ => Colors.white,
    };

    final Color borderColor = switch (index) {
      0 => const Color(0xFFFFD645),
      1 => const Color(0xFFC0C7D1),
      2 => const Color(0xFFCD7F32),
      _ => const Color(0xFF00D1FF),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isTop3
              ? [
                  borderColor.withOpacity(0.2),
                  const Color(0xFF111C33),
                ]
              : const [Color(0xFF111C33), Color(0xFF182647)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor.withOpacity(0.5)),
        boxShadow: isTop3
            ? [
                BoxShadow(
                  color: borderColor.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#${index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: nameColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: nameColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList({
    required String field,
    required String emptyLabel,
    required String Function(Map<String, dynamic>) formatter,
  }) {
    return FutureBuilder<
        List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
      future: _fetch(field),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final docs = snapshot.data ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Text(
              emptyLabel,
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            return _buildEntry(
              index: index,
              name: _username(data),
              value: formatter(data),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 380,
        height: 520,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0B1020), Color(0xFF151E2C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF00D1FF).withOpacity(0.35),
          ),
        ),
        child: DefaultTabController(
          length: 4,
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events,
                      color: Color(0xFFFFD645)),
                  const SizedBox(width: 8),
                  Text(
                    'Clasificación',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const TabBar(
                isScrollable: false,
                tabs: [
                  Tab(text: 'Dinero'),
                  Tab(text: 'Spins'),
                  Tab(text: 'Pedia'),
                  Tab(text: 'Tiempo'),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildList(
                      field: 'money',
                      emptyLabel: 'No hay datos aún',
                      formatter: (data) =>
                          (data['money'] ?? 0).toString(),
                    ),
                    _buildList(
                      field: 'totalSpins',
                      emptyLabel: 'No hay datos aún',
                      formatter: (data) =>
                          (data['totalSpins'] ?? 0).toString(),
                    ),
                    _buildList(
                      field: 'pediaCount',
                      emptyLabel: 'No hay datos aún',
                      formatter: (data) =>
                          (data['pediaCount'] ?? 0).toString(),
                    ),
                    _buildList(
                      field: 'playTimeMinutes',
                      emptyLabel: 'No hay datos aún',
                      formatter: (data) =>
                          '${data['playTimeMinutes'] ?? 0} min',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
