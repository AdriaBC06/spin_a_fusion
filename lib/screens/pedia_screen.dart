import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/fusion_pedia_provider.dart';
import '../providers/game_provider.dart';
import '../features/fusion/widgets/pedia_fusion_tile.dart';

class PediaScreen extends StatefulWidget {
  const PediaScreen({super.key});

  @override
  State<PediaScreen> createState() => _PediaScreenState();
}

class _PediaScreenState extends State<PediaScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSearchDialog() {
    _searchController.text = _query;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Buscar en Pedia'),
        content: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nombre de la fusión o Pokémon',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() => _query = value.trim());
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _query = '');
              Navigator.pop(context);
            },
            child: const Text('Limpiar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pedia = context.watch<FusionPediaProvider>();
    final allFusions = pedia.sortedFusions;
    final pendingCount = pedia.pendingCount;
    final totalCount = allFusions.length;
    final query = _query.toLowerCase();

    final fusions = query.isEmpty
        ? allFusions
        : allFusions.where((fusion) {
            final fusionName = fusion.fusionName.toLowerCase();
            final p1 = fusion.p1.name.toLowerCase();
            final p2 = fusion.p2.name.toLowerCase();

            return fusionName.contains(query) ||
                p1.contains(query) ||
                p2.contains(query);
          }).toList();

    if (pedia.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF111C33), Color(0xFF182647)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF00D1FF).withOpacity(0.4),
            ),
          ),
          child: const Text(
            'Aún no hay fusiones desbloqueadas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0B1020),
            Color(0xFF0E1B36),
            Color(0xFF1A0F3A),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.book_rounded,
                      color: Color(0xFFFFD645),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pedia',
                      style:
                          Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF00D1FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF00D1FF)
                              .withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        totalCount.toString(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (pendingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF2D95)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFF2D95)
                                .withOpacity(0.6),
                          ),
                        ),
                        child: Text(
                          '$pendingCount pendientes',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (pendingCount > 0)
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final claimed = context
                            .read<FusionPediaProvider>()
                            .claimAllPending();
                        if (claimed > 0) {
                          context
                              .read<GameProvider>()
                              .addDiamonds(claimed);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF2D95),
                        foregroundColor: Colors.white,
                      ),
                      child:
                          Text('Reclamar todos ($pendingCount)'),
                    ),
                  ),
                ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: fusions.length,
                  itemBuilder: (context, index) {
                    return PediaFusionTile(
                      fusion: fusions[index],
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: _openSearchDialog,
              backgroundColor: const Color(0xFF00D1FF),
              foregroundColor: Colors.black,
              child: const Icon(Icons.search),
            ),
          ),
        ],
      ),
    );
  }
}
