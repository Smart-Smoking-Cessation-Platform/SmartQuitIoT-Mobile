/*
// lib/views/screens/coach_chat/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:SmartQuitIoT/models/coach.dart';
import 'package:SmartQuitIoT/providers/coach_provider.dart';
import 'package:SmartQuitIoT/views/screens/coach_chat/chat_screen_detail.dart';
import '../../../providers/conversation_provider.dart';
import '../../../models/conversation_summary.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _fullNameFromModel(Coach c) {
    final f = c.firstName.trim();
    final l = c.lastName.trim();
    final name = ('$f $l').trim();
    return name.isEmpty ? 'Coach' : name;
  }

  String _initials(String name) {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Widget _avatarWidget(String? avatarUrl, String initials, {double size = 56}) {
    final url = (avatarUrl ?? '').trim();
    if (url.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: const Color(0xFF00D09E),
        child: Text(initials,
            style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );
    }

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              color: Colors.grey.shade200,
              child: const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF00D09E),
                shape: BoxShape.circle,
              ),
              child: Text(initials,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            );
          },
        ),
      ),
    );
  }

  Widget _coachTileFromModel(Coach c) {
    final name = _fullNameFromModel(c);
    final avatar = c.avatarUrl;
    final rating = c.ratingAvg;

    return GestureDetector(
      onTap: () => _showCoachModalFromModel(c),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            _avatarWidget(avatar, _initials(name), size: 56),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 6),
                      Text(rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showCoachModalFromModel(Coach c) {
    final name = _fullNameFromModel(c);
    final avatar = c.avatarUrl;
    final rating = c.ratingAvg;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape:
      const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300], borderRadius: BorderRadius.circular(2.5))),
              const SizedBox(height: 12),
              _avatarWidget(avatar, _initials(name), size: 80),
              const SizedBox(height: 12),
              Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 6),
                Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ChatScreenDetail(
                      coachName: name,
                      coachAvatar: avatar ?? '',
                      coachAccountId: c.accountId,
                    ),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09E),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Chat Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ]),
          ),
        );
      },
    );
  }

  Widget _conversationTile(ConversationSummary conv) {
    // compute display title (prefer explicit title -> known name fields -> fallback)
    String _computeTitle(ConversationSummary conv) {
      // 1) server-provided title
      try {
        if (conv.title != null && conv.title!.trim().isNotEmpty) return conv.title!;
      } catch (_) {}

      // 2) try common alternative fields via dynamic (defensive)
      try {
        final dynamic c = conv as dynamic;
        final List<dynamic> candidates = [
          c.coachName,
          c.participantName,
          c.displayName,
          c.counterpartyName,
          c.name,
          c.title, // just in case different shape
        ];
        for (var cand in candidates) {
          if (cand != null) {
            final s = cand.toString().trim();
            if (s.isNotEmpty) return s;
          }
        }
      } catch (_) {}

      // 3) final fallback
      return 'Cuộc trò chuyện';
    }

    final title = _computeTitle(conv);
    final subtitle = conv.lastMessage ?? '';
    final timeStr = conv.lastUpdatedAt != null ? DateFormat('HH:mm').format(conv.lastUpdatedAt!) : '';
    final avatar = conv.avatarUrl ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ChatScreenDetail(
            coachName: title,
            coachAvatar: avatar,
            conversationId: conv.id,
          ),
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
              child: avatar.isEmpty ? Text((title.isNotEmpty ? title[0] : '?')) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(timeStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 6),
                if (conv.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                    child: Text('${conv.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final coachesAsync = ref.watch(coachesProvider);
    final convsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        centerTitle: true,
        title: const Text('Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: 'Coaches'), Tab(text: 'Messages')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Coaches tab
          coachesAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('No coaches found'),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: () => ref.refresh(coachesProvider), child: const Text('Reload')),
                  ]),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ref.refresh(coachesProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final coachModel = list[index];
                    return _coachTileFromModel(coachModel);
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Failed to load coaches: ${err.toString()}', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () => ref.refresh(coachesProvider), child: const Text('Retry')),
                ]),
              ),
            ),
          ),

          // Messages tab -> real conversations from provider
          convsAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Chưa có cuộc trò chuyện nào'),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: () => ref.refresh(conversationsProvider), child: const Text('Tải lại')),
                  ]),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ref.refresh(conversationsProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final conv = list[index];
                    return _conversationTile(conv);
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Không tải được cuộc hội thoại: ${err.toString()}', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () => ref.refresh(conversationsProvider), child: const Text('Thử lại')),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/
// ... giữ nguyên các import bạn đang có
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:SmartQuitIoT/models/coach.dart';
import 'package:SmartQuitIoT/providers/coach_provider.dart';
import 'package:SmartQuitIoT/views/screens/coach_chat/chat_screen_detail.dart';
import '../../../providers/conversation_provider.dart';
import '../../../models/conversation_summary.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  // Auto-refresh when app come back to foreground (helpful if changes done in web)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // ignore: avoid_print
      print('App resumed -> refresh coaches');
      _refreshCoaches(); // fire-and-forget
    }
  }

  Future<void> _refreshCoaches() async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(coachListStateProvider.notifier).refresh();
      messenger.showSnackBar(const SnackBar(content: Text('Danh sách coach đã được cập nhật')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Tải lại thất bại: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  String _fullNameFromModel(Coach c) {
    final f = c.firstName.trim();
    final l = c.lastName.trim();
    final name = ('$f $l').trim();
    return name.isEmpty ? 'Coach' : name;
  }

  String _initials(String name) {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Widget _avatarWidget(String? avatarUrl, String initials, {double size = 56}) {
    final url = (avatarUrl ?? '').trim();
    if (url.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: const Color(0xFF00D09E),
        child: Text(initials,
            style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );
    }

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              color: Colors.grey.shade200,
              child: const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF00D09E),
                shape: BoxShape.circle,
              ),
              child: Text(initials,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            );
          },
        ),
      ),
    );
  }

  Widget _coachTileFromModel(Coach c) {
    final name = _fullNameFromModel(c);
    final avatar = c.avatarUrl;
    final rating = c.ratingAvg;

    return GestureDetector(
      onTap: () => _showCoachModalFromModel(c),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            _avatarWidget(avatar, _initials(name), size: 56),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 6),
                      Text(rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showCoachModalFromModel(Coach c) {
    final name = _fullNameFromModel(c);
    final avatar = c.avatarUrl;
    final rating = c.ratingAvg;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape:
      const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300], borderRadius: BorderRadius.circular(2.5))),
              const SizedBox(height: 12),
              _avatarWidget(avatar, _initials(name), size: 80),
              const SizedBox(height: 12),
              Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 6),
                Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ChatScreenDetail(
                      coachName: name,
                      coachAvatar: avatar ?? '',
                      coachAccountId: c.accountId,
                    ),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09E),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Chat Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ]),
          ),
        );
      },
    );
  }

  Widget _conversationTile(ConversationSummary conv) {
    String _computeTitle(ConversationSummary conv) {
      try {
        if (conv.title != null && conv.title!.trim().isNotEmpty) return conv.title!;
      } catch (_) {}
      try {
        final dynamic c = conv as dynamic;
        final List<dynamic> candidates = [
          c.coachName,
          c.participantName,
          c.displayName,
          c.counterpartyName,
          c.name,
          c.title,
        ];
        for (var cand in candidates) {
          if (cand != null) {
            final s = cand.toString().trim();
            if (s.isNotEmpty) return s;
          }
        }
      } catch (_) {}
      return 'Cuộc trò chuyện';
    }

    final title = _computeTitle(conv);
    final subtitle = conv.lastMessage ?? '';
    final timeStr = conv.lastUpdatedAt != null ? DateFormat('HH:mm').format(conv.lastUpdatedAt!) : '';
    final avatar = conv.avatarUrl ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ChatScreenDetail(
            coachName: title,
            coachAvatar: avatar,
            conversationId: conv.id,
          ),
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
              child: avatar.isEmpty ? Text((title.isNotEmpty ? title[0] : '?')) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(timeStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 6),
                if (conv.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                    child: Text('${conv.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coachesAsync = ref.watch(coachesProvider);
    final convsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        centerTitle: true,
        title: const Text('Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: 'Coaches'), Tab(text: 'Messages')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Coaches tab
          coachesAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('No coaches found'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isRefreshing ? null : _refreshCoaches,
                      child: _isRefreshing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Reload'),
                    ),
                  ]),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => _refreshCoaches(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final coachModel = list[index];
                    return _coachTileFromModel(coachModel);
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Failed to load coaches: ${err.toString()}', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _isRefreshing ? null : _refreshCoaches, child: _isRefreshing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Retry')),
                ]),
              ),
            ),
          ),

          // Messages tab -> real conversations from provider
          convsAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Chưa có cuộc trò chuyện nào'),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: () =>ref.invalidate(conversationsProvider)
                        , child: const Text('Tải lại')),
                  ]),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => await ref.refresh(conversationsProvider.future),

                  child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final conv = list[index];
                    return _conversationTile(conv);
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Không tải được cuộc hội thoại: ${err.toString()}', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () => ref.invalidate(conversationsProvider)
                      , child: const Text('Thử lại')),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

