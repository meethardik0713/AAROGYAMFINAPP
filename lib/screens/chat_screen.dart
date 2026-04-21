import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aarogyamfin/theme/app_theme.dart';
import 'package:aarogyamfin/main.dart';
import '../services/api_service.dart';
import 'payment_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _sessionId = '';
  final List<Map<String, dynamic>> _messages = [];
  final List<Map<String, dynamic>> _history = [];

  bool _isLoading = false;
  bool _isPdfLoaded = false;
  bool _isUploading = false;
  bool _checkingPayment = true;
  bool _hasAccess = false;
  int _messagesLeft = 25;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    _checkAccess();
    themeNotifier.addListener(_onThemeChange);
  }

  void _onThemeChange() => setState(() {});

  Future<void> _checkAccess() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _checkingPayment = false);
      return;
    }
    final status = await ApiService.checkPaymentStatus(user.uid);
    if (mounted) {
      setState(() {
        _hasAccess       = status['has_access'] == true;
        _messagesLeft    = status['messages_left'] ?? 25;
        _checkingPayment = false;
        _sessionId       = status['session_id'] ?? '';
        _isPdfLoaded     = status['pdf_loaded'] == true;

        // Load saved chat history
        final savedMessages = status['messages'] as List?;
        if (savedMessages != null && savedMessages.isNotEmpty) {
          _messages.clear();
          _history.clear();
          for (final msg in savedMessages) {
            final role    = msg['role'] as String;
            final content = msg['content'] as String;
            _messages.add({'role': role, 'content': content});
            _history.add({'role': role, 'content': content});
          }
          _isPdfLoaded = true;
        }
      });

      // Scroll to bottom after history loads
      if (_messages.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
      }
    }
  }

  Future<void> _pickAndUploadPdf() async {
    HapticFeedback.mediumImpact();

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result == null) return;

    setState(() {
      _isUploading = true;
      _fileName = result.files.single.name;
    });

    final fileBytes = result.files.single.bytes;
    final filePath = kIsWeb ? null : result.files.single.path;

    final response = await ApiService.uploadChatPdf(
      _sessionId,
      filePath,
      _fileName!,
      bytes: fileBytes != null ? List<int>.from(fileBytes) : null,
    );

    setState(() => _isUploading = false);

    if (response['success']) {
      setState(() => _isPdfLoaded = true);
      _addBotMessage('Statement loaded! ${response['data']['transaction_count']} transactions indexed. Kuch bhi poochho apne finances ke baare mein!');
    } else {
      _addBotMessage('Upload failed: ${response['error']}');
    }
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add({'role': 'assistant', 'content': text});
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final msg = _msgController.text.trim();
    if (msg.isEmpty || _isLoading) return;
    if (!_isPdfLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pehle PDF upload karo!'),
          backgroundColor: Color(0xFFF87171),
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    _msgController.clear();

    setState(() {
      _messages.add({'role': 'user', 'content': msg});
      _isLoading = true;
    });
    _scrollToBottom();

    final response = await ApiService.sendChatMessage(_sessionId, msg, _history);

    if (response['success']) {
      final reply = response['data']['reply'] as String;
      _history.add({'role': 'user', 'content': msg});
      _history.add({'role': 'assistant', 'content': reply});
      _addBotMessage(reply);
    } else {
      _addBotMessage('Error: ${response['error']}');
    }

    setState(() => _isLoading = false);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChange);
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;

    if (_checkingPayment) {
      return Scaffold(
        backgroundColor: bg,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.gold),
        ),
      );
    }

    if (!_hasAccess) {
      return const PaymentScreen();
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              decoration: BoxDecoration(
                color: bg,
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Chat', style: AppTheme.heading(20, isDark: isDark)),
                      const SizedBox(height: 2),
                      Text(
                        _isPdfLoaded ? '● Statement loaded' : '● Upload PDF to start',
                        style: TextStyle(
                          fontSize: 11,
                          color: _isPdfLoaded ? const Color(0xFF4ADE80) : AppTheme.gold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Theme toggle
                      GestureDetector(
                        onTap: () => themeNotifier.toggle(),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                            border: Border.all(color: borderColor),
                          ),
                          child: Icon(
                            isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                            color: AppTheme.gold,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Upload PDF button
                      GestureDetector(
                        onTap: _pickAndUploadPdf,
                        child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: _isPdfLoaded
                            ? const Color(0xFF4ADE80).withOpacity(0.1)
                            : AppTheme.gold.withOpacity(0.1),
                        border: Border.all(
                          color: _isPdfLoaded
                              ? const Color(0xFF4ADE80).withOpacity(0.4)
                              : AppTheme.gold.withOpacity(0.4),
                        ),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                color: AppTheme.gold,
                                strokeWidth: 1.5,
                              ),
                            )
                          : Row(
                              children: [
                                Icon(
                                  _isPdfLoaded
                                      ? Icons.check_circle_outline
                                      : Icons.upload_file_outlined,
                                  color: _isPdfLoaded
                                      ? const Color(0xFF4ADE80)
                                      : AppTheme.gold,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isPdfLoaded ? 'Loaded' : 'Upload PDF',
                                  style: TextStyle(
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                    color: _isPdfLoaded
                                        ? const Color(0xFF4ADE80)
                                        : AppTheme.gold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Messages ────────────────────────────
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState(isDark, surfaceColor, borderColor)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return _buildTypingIndicator(isDark);
                        }
                        final msg = _messages[index];
                        final isUser = msg['role'] == 'user';
                        return _buildMessage(msg['content'], isUser, isDark, surfaceColor, borderColor);
                      },
                    ),
            ),

            // ── Input ───────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: bg,
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        border: Border.all(color: borderColor),
                      ),
                      child: TextField(
                        controller: _msgController,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppTheme.darkText : AppTheme.lightText,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Kuch bhi poochho...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      color: AppTheme.gold,
                      child: const Icon(
                        Icons.arrow_upward,
                        color: Color(0xFF060810),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color surfaceColor, Color borderColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.gold.withOpacity(0.08),
                border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
              ),
              child: const Icon(Icons.chat_bubble_outline, color: AppTheme.gold, size: 28),
            ),
            const SizedBox(height: 20),
            Text('AI Financial Assistant', style: AppTheme.heading(18, isDark: isDark)),
            const SizedBox(height: 8),
            Text(
              'Upload your bank statement and ask anything about your finances',
              style: AppTheme.mutedStyle(13, isDark: isDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickAndUploadPdf,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                color: AppTheme.gold,
                child: Text(
                  'UPLOAD PDF',
                  style: AppTheme.label(11).copyWith(
                    color: const Color(0xFF060810),
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(String content, bool isUser, bool isDark, Color surfaceColor, Color borderColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.gold.withOpacity(0.1),
                border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
              ),
              child: const Icon(Icons.auto_awesome, color: AppTheme.gold, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.gold.withOpacity(0.1) : surfaceColor,
                border: Border.all(
                  color: isUser ? AppTheme.gold.withOpacity(0.3) : borderColor,
                ),
              ),
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: isDark ? AppTheme.darkText : AppTheme.lightText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.gold.withOpacity(0.1),
              border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
            ),
            child: const Icon(Icons.auto_awesome, color: AppTheme.gold, size: 14),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
            ),
            child: const SizedBox(
              width: 40,
              height: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Dot(delay: 0),
                  _Dot(delay: 150),
                  _Dot(delay: 300),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: AppTheme.gold,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
