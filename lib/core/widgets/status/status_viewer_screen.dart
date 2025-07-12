import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../model/status/status_model.dart';
import '../../../view_model/controllers/status_controller.dart';
import '../../services/firestore_user_service.dart';
import 'status_options_bottom_sheet.dart';
import 'status_viewers_list.dart';

class StatusViewerScreen extends StatefulWidget {
  final List<StatusModel> statuses;
  final int initialIndex;
  const StatusViewerScreen({super.key, required this.statuses, this.initialIndex = 0});
  @override
  State<StatusViewerScreen> createState() => _StatusViewerScreenState();
}

class _StatusViewerScreenState extends State<StatusViewerScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  late StatusController _statusController;
  late AnimationController _animationController;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    widget.statuses.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _statusController = Get.find<StatusController>();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _animationController.addStatusListener(_handleAnimationStatus);
    _startProgress();
    if (widget.statuses.isNotEmpty) {
      _markStatusAsSeen(widget.statuses[_currentIndex]);
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_isPaused) {
      _goToNextStatus();
    }
  }

  void _startProgress() {
    _animationController.forward(from: 0);
  }

  void _pauseProgress() {
    _animationController.stop();
    setState(() { _isPaused = true; });
  }

  void _resumeProgress() {
    _animationController.forward();
    setState(() { _isPaused = false; });
  }

  void _goToNextStatus() {
    if (_currentIndex < widget.statuses.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pop(context);
    }
  }

  void _goToPreviousStatus() {
    if (_currentIndex > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _markStatusAsSeen(StatusModel status) {
    if (!_statusController.isMyStatus(status)) {
      _statusController.markStatusAsSeen(status.id);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildStatusContent(StatusModel status) {
    switch (status.type) {
      case StatusType.text:
        return Container(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              status.text ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      case StatusType.image:
        return status.mediaUrl != null
            ? Image.network(
                status.mediaUrl!,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
              )
            : const Center(
                child: Text('Image not found', style: TextStyle(color: Colors.white)),
              );
      case StatusType.audio:
        return status.mediaUrl != null
            ? const Center(
                child: Text(
                  'Audio Player',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : const Center(
                child: Text('Audio not found', style: TextStyle(color: Colors.white)),
              );
    }
  }

  String _getStatusTimeAgo(StatusModel status) {
    final now = DateTime.now();
    final difference = now.difference(status.timestamp);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showStatusOptions(StatusModel status) {
    final isMine = _statusController.isMyStatus(status);
    if (!isMine) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatusOptionsBottomSheet(
        isMyStatus: true,
        onDelete: () {
          _statusController.deleteStatus(status.id);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showViewersList(StatusModel status) async {
    final List<String> viewerIds = status.seenBy;
    final viewers = await Future.wait(viewerIds.map((id) => FirestoreUserService().getUserById(id)));
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatusViewersList(viewers: viewers),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.statuses.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: Text('No statuses found', style: TextStyle(color: Colors.white)),
        ),
      );
    }
    final currentStatus = widget.statuses[_currentIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onLongPress: _pauseProgress,
          onLongPressUp: _resumeProgress,
          onTapDown: (details) {
            final width = MediaQuery.of(context).size.width;
            if (details.globalPosition.dx < width / 3) {
              _goToPreviousStatus();
            } else if (details.globalPosition.dx > 2 * width / 3) {
              _goToNextStatus();
            }
          },
          child: Column(
            children: [
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: List.generate(widget.statuses.length, (i) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            double value = 0;
                            if (i < _currentIndex) value = 1;
                            else if (i == _currentIndex) value = _animationController.value;
                            return LinearProgressIndicator(
                              value: value,
                              backgroundColor: Colors.grey[800],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 3,
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      backgroundImage: currentStatus.profileImageUrl != null
                          ? NetworkImage(currentStatus.profileImageUrl!)
                          : null,
                      child: currentStatus.profileImageUrl == null
                          ? Text(currentStatus.userName[0].toUpperCase())
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentStatus.userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _getStatusTimeAgo(currentStatus),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showStatusOptions(currentStatus),
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Status content
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                        _animationController.removeStatusListener(_handleAnimationStatus);
                        _animationController.reset();
                        _animationController.addStatusListener(_handleAnimationStatus);
                        _startProgress();
                        _markStatusAsSeen(widget.statuses[index]);
                      },
                      itemCount: widget.statuses.length,
                      itemBuilder: (context, index) {
                        return _buildStatusContent(widget.statuses[index]);
                      },
                    ),
                    // Viewers count for my own status
                    if (_statusController.isMyStatus(widget.statuses[_currentIndex]))
                      Positioned(
                        bottom: 24,
                        left: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showViewersList(widget.statuses[_currentIndex]),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.remove_red_eye, color: Colors.white70, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.statuses[_currentIndex].seenBy.length} viewers',
                                style: const TextStyle(color: Colors.white70, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 