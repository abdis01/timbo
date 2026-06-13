import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/offline_banner.dart';
import '../../providers/providers.dart';
import '../../theme/colors.dart';
import 'widgets/folder_card.dart';
import 'widgets/ai_insight_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hasAnimated = true;
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final folders = ref.watch(foldersProvider);
    final insight = ref.watch(aiInsightProvider);
    final greeting = ref.watch(userGreetingProvider);
    final userName = ref.watch(userNameProvider);
    final date = ref.watch(formattedDateProvider);

    return Scaffold(
      backgroundColor: TimboColors.appBackground,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: OfflineBanner()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$greeting, $userName', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: TimboColors.ink)),
                    const SizedBox(height: 2),
                    Text(date, style: const TextStyle(fontSize: 13, color: TimboColors.inkLight)),
                  ],
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: insight.when(
                data: (v) => AiInsightCard(insight: v),
                loading: () => const AiInsightCard(insight: ''),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          folders.when(
            data: (list) {
              if (list.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_stories_outlined, size: 64, color: TimboColors.inkFaint),
                          SizedBox(height: 16),
                          Text(
                            'No Timbos yet',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: TimboColors.ink),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tap + to create your first Timbo',
                            style: TextStyle(fontSize: 13, color: TimboColors.inkFaint),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final folder = list[index];
                    final delay = index * 60;
                    final itemAnim = CurvedAnimation(
                      parent: _animController,
                      curve: Interval(
                        delay / _animController.duration!.inMilliseconds,
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
                    );
                    return AnimatedBuilder(
                      animation: itemAnim,
                      builder: (_, child) => Opacity(
                        opacity: _hasAnimated ? itemAnim.value : 1.0,
                        child: Transform.translate(
                          offset: Offset(0, _hasAnimated ? 16 * (1 - itemAnim.value) : 0),
                          child: child,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: FolderCard(folder: folder),
                      ),
                    );
                  },
                  childCount: list.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => const SliverToBoxAdapter(
              child: Center(child: Text('Error loading folders')),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
      ),
      floatingActionButton: _FabButton(onTap: () async {
        final folder = await ref.read(folderRepositoryProvider).getOrCreateTodayFolder();
        final timboId = await ref.read(timboRepositoryProvider).createTimbo(folderId: folder.id);
        if (context.mounted) context.push('/timbo/$timboId');
      }),
    );
  }
}

class _FabButton extends StatefulWidget {
  final VoidCallback onTap;

  const _FabButton({required this.onTap});

  @override
  State<_FabButton> createState() => _FabButtonState();
}

class _FabButtonState extends State<_FabButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: TimboColors.ink,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
