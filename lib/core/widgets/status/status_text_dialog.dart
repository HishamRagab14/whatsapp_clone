import 'package:flutter/material.dart';

class StatusTextDialog extends StatefulWidget {
  final void Function(String text) onSend;
  const StatusTextDialog({super.key, required this.onSend});

  @override
  State<StatusTextDialog> createState() => _StatusTextDialogState();
}

class _StatusTextDialogState extends State<StatusTextDialog> {
  final TextEditingController _controller = TextEditingController();
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _charCount = _controller.text.length;
        if (_controller.text.length > 500) {
          _controller.text = _controller.text.substring(0, 500);
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.edit_outlined, color: Colors.green[600], size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text('Text Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'What\'s on your mind?',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                maxLines: 5,
                style: const TextStyle(fontSize: 16, height: 1.4),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty) {
                    widget.onSend(text.trim());
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$_charCount/500', style: TextStyle(color: _charCount > 400 ? Colors.orange : Colors.grey[500], fontSize: 12)),
                ElevatedButton.icon(
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      widget.onSend(text);
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('Send'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 