import 'package:flutter/material.dart';

/// Widget input untuk menulis balasan
class ReplyInput extends StatefulWidget {
  final String? replyingToName;
  final bool isLoading;
  final Function(String) onSubmit;
  final VoidCallback? onCancel;

  const ReplyInput({
    super.key,
    this.replyingToName,
    this.isLoading = false,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<ReplyInput> createState() => _ReplyInputState();
}

class _ReplyInputState extends State<ReplyInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Set initial @mention if replying to someone (nama lengkap)
    if (widget.replyingToName != null) {
      _controller.text = '@${widget.replyingToName} ';
      // Move cursor to end
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void didUpdateWidget(ReplyInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update @mention when replyingToName changes
    if (widget.replyingToName != oldWidget.replyingToName) {
      if (widget.replyingToName != null) {
        _controller.text = '@${widget.replyingToName} ';
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
        _focusNode.requestFocus();
      } else {
        _controller.clear();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSubmit(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tambahkan Balasan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              if (widget.replyingToName != null && widget.onCancel != null)
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Batal'),
                ),
            ],
          ),
        ),
        // Input field
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Toolbar (simplified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    _buildToolbarButton('Normal', null),
                    const SizedBox(width: 8),
                    _buildToolbarIcon(Icons.format_bold),
                    _buildToolbarIcon(Icons.format_italic),
                    _buildToolbarIcon(Icons.format_underline),
                    _buildToolbarIcon(Icons.format_list_numbered),
                    _buildToolbarIcon(Icons.format_list_bulleted),
                  ],
                ),
              ),
              // Text input
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: 4,
                minLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tulis sesuatu di sini...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
                enabled: !widget.isLoading,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Submit button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Kirim Balasan'),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildToolbarButton(String text, VoidCallback? onPressed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(fontSize: 12)),
          const Icon(Icons.arrow_drop_down, size: 16),
        ],
      ),
    );
  }

  Widget _buildToolbarIcon(IconData icon) {
    return IconButton(
      icon: Icon(icon, size: 18),
      onPressed: () {},
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(),
      color: Colors.grey.shade600,
    );
  }
}
