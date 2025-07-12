import 'package:flutter/material.dart';
import 'package:whatsapp_clone/core/constants.dart';

class VoiceMessageBubble extends StatefulWidget {
  final bool isMe;
  final String? audioUrl;
  final bool isUploading;
  final String userImageUrl;
  final String messageTime;
  final VoidCallback? onTap;
  final Function(double)? onSeek;
  final double progress;
  final String duration;
  final String currentTime;
  final bool isPlaying;

  const VoiceMessageBubble({
    super.key,
    required this.isMe,
    this.audioUrl,
    this.isUploading = false,
    required this.userImageUrl,
    required this.messageTime,
    this.onTap,
    this.onSeek,
    this.progress = 0.0,
    this.duration = '0:00',
    this.currentTime = '0:00',
    this.isPlaying = false,
  });

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  double? _draggingProgress;

  @override
  Widget build(BuildContext context) {
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.7;
    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.isMe ? 60 : 8,
          right: widget.isMe ? 8 : 60,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxBubbleWidth, minWidth: 120),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color:
                        widget.isMe
                            ? kMyMessageBubbleColor
                            : kOtherMessageBubbleColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!widget.isMe) ...[
                        Container(
                          width: 32,
                          height: 32,
                          margin: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image:
                                  widget.userImageUrl.startsWith('http')
                                      ? NetworkImage(widget.userImageUrl)
                                      : AssetImage(widget.userImageUrl)
                                          as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                widget.isMe
                                    ? Colors.white.withAlpha(
                                      (0.2 * 255).toInt(),
                                    )
                                    : Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              child: Icon(
                                widget.isUploading
                                    ? Icons.mic
                                    : (widget.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow),
                                key: ValueKey(widget.isPlaying),
                                color:
                                    widget.isMe
                                        // ? Colors.white
                                        ?
                                        Colors.grey[500]
                                        : Colors.grey[700],
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      // شريط التقدم التفاعلي مع دعم السحب
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final barWidth = constraints.maxWidth;
                            final progress =
                                _draggingProgress ?? widget.progress;
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapDown: (details) {
                                final local = (context.findRenderObject()
                                        as RenderBox)
                                    .globalToLocal(details.globalPosition);
                                final relative = (local.dx / barWidth).clamp(
                                  0.0,
                                  1.0,
                                );
                                if (widget.onSeek != null) {
                                  widget.onSeek!(relative);
                                }
                              },
                              onHorizontalDragStart: (details) {
                                setState(() {
                                  final local = (context.findRenderObject()
                                          as RenderBox)
                                      .globalToLocal(details.globalPosition);
                                  _draggingProgress = (local.dx / barWidth)
                                      .clamp(0.0, 1.0);
                                });
                              },
                              onHorizontalDragUpdate: (details) {
                                setState(() {
                                  final local = (context.findRenderObject()
                                          as RenderBox)
                                      .globalToLocal(details.globalPosition);
                                  _draggingProgress = (local.dx / barWidth)
                                      .clamp(0.0, 1.0);
                                });
                              },
                              onHorizontalDragEnd: (details) {
                                if (_draggingProgress != null &&
                                    widget.onSeek != null) {
                                  widget.onSeek!(_draggingProgress!);
                                }
                                setState(() {
                                  _draggingProgress = null;
                                });
                              },
                              child: Container(
                                height: 6,
                                alignment: Alignment.centerLeft,
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color:
                                            widget.isMe
                                                // ? Colors.white.withAlpha(
                                                //   (0.3 * 255).toInt(),
                                                // )
                                                ? Colors.black12
                                                : Colors.grey[400],
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: progress,
                                      child: Container(
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color:
                                              widget.isMe
                                                  ? Colors.white
                                                  : Colors.grey[600],
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                      ),
                                    ),
                                    ...(progress > 0
                                        ? [
                                          Positioned(
                                            left: ((progress) * (barWidth - 12))
                                                .clamp(0.0, barWidth - 12),
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color:
                                                    widget.isMe
                                                        ? Colors.white
                                                        : Colors.grey[800],
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withAlpha(
                                                          (0.2 * 255).toInt(),
                                                        ),
                                                    blurRadius: 3,
                                                    offset: Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ]
                                        : []),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        child: Text(
                          widget.isUploading
                              ? 'Recording...'
                              : '${widget.currentTime}/${widget.duration}',
                          key: ValueKey(
                            '${widget.currentTime}_${widget.duration}',
                          ),
                          style: TextStyle(
                            color:
                                widget.isMe ? Colors.grey[600] : Colors.grey[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.isMe) ...[
                SizedBox(width: 4),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.done_all, size: 16, color: Colors.blue),
                    SizedBox(height: 2),
                    Text(
                      widget.messageTime,
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
