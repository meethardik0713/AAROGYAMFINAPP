import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:aarogyamfin/theme/app_theme.dart';
import 'package:aarogyamfin/main.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

// ── Plan Model ────────────────────────────────────────────
class _Plan {
  final String name;
  final int price;
  final int inputTokens;
  final int outputTokens;
  final String validity;
  final String description;
  final bool isPopular;

  const _Plan({
    required this.name,
    required this.price,
    required this.inputTokens,
    required this.outputTokens,
    required this.validity,
    required this.description,
    this.isPopular = false,
  });

  String get inputDisplay {
    if (inputTokens >= 100000) return '${(inputTokens / 100000).toStringAsFixed(0)}L';
    return '${(inputTokens / 1000).toStringAsFixed(0)}K';
  }
}

const List<_Plan> _plans = [
  _Plan(
    name: 'Basic',
    price: 10,
    inputTokens: 25000,
    outputTokens: 5000,
    validity: '24 hrs',
    description: 'Perfect for a quick analysis',
  ),
  _Plan(
    name: 'Standard',
    price: 49,
    inputTokens: 100000,
    outputTokens: 5000,
    validity: '75 hrs',
    description: 'For detailed monthly review',
  ),
  _Plan(
    name: 'Pro',
    price: 99,
    inputTokens: 300000,
    outputTokens: 5000,
    validity: '125 hrs',
    description: 'For heavy users & CAs',
    isPopular: true,
  ),
  _Plan(
    name: 'Elite',
    price: 499,
    inputTokens: 1500000,
    outputTokens: 5000,
    validity: '200 hrs',
    description: 'Maximum power, maximum insight',
  ),
];

// ── Payment Screen ────────────────────────────────────────
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  bool _isLoading = false;
  int _selectedIndex = 1; // Standard selected by default

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onThemeChange);
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  void _onThemeChange() => setState(() {});

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChange);
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _startPayment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    final selectedPlan = _plans[_selectedIndex];

    final response = await ApiService.createOrder(
      user.uid,
      user.email ?? '',
      amount: selectedPlan.price,
      planName: selectedPlan.name,
    );

    setState(() => _isLoading = false);

    if (!response['success']) {
      _showError(response['error'] ?? 'Order creation failed');
      return;
    }

    final data = response['data'];
    final options = {
      'key': data['key_id'],
      'amount': data['amount'],
      'currency': data['currency'],
      'order_id': data['order_id'],
      'name': 'AarogyamFin',
      'description': '${selectedPlan.name} Plan — ${selectedPlan.inputDisplay} tokens',
      'prefill': {'email': data['email']},
      'theme': {'color': '#C9A84C'},
    };

    _razorpay.open(options);
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    final selectedPlan = _plans[_selectedIndex];

    final result = await ApiService.verifyPayment(
      user.uid,
      response.orderId ?? '',
      response.paymentId ?? '',
      response.signature ?? '',
      planName: selectedPlan.name,
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
      }
    } else {
      _showError('Payment verification failed');
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    _showError('Payment failed: ${response.message}');
  }

  void _onExternalWallet(ExternalWalletResponse response) {}

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFF87171),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final selectedPlan = _plans[_selectedIndex];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.gold, size: 18),
                  ),
                  Text('CHOOSE PLAN', style: AppTheme.label(11)),
                ],
              ),
            ),

            Container(height: 1, color: borderColor, margin: const EdgeInsets.only(top: 12)),

            // ── Scrollable Content ────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                children: [
                  // Hero text
                  Text('AI Financial\nIntelligence', style: AppTheme.heading(32, isDark: isDark)),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a plan and unlock the full power of AI analysis.',
                    style: AppTheme.mutedStyle(13, isDark: isDark),
                  ),
                  const SizedBox(height: 28),

                  // ── Plan Cards ───────────────────────
                  ...List.generate(_plans.length, (i) {
                    final plan = _plans[i];
                    final isSelected = i == _selectedIndex;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedIndex = i);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.gold.withOpacity(0.06)
                              : isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.gold.withOpacity(0.5)
                                : borderColor,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Radio
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppTheme.gold : borderColor,
                                  width: 1.5,
                                ),
                                color: isSelected
                                    ? AppTheme.gold.withOpacity(0.15)
                                    : Colors.transparent,
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.gold,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),

                            const SizedBox(width: 16),

                            // Plan info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        plan.name,
                                        style: AppTheme.heading(16, isDark: isDark),
                                      ),
                                      if (plan.isPopular) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.gold.withOpacity(0.15),
                                            border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
                                          ),
                                          child: Text(
                                            'POPULAR',
                                            style: AppTheme.label(8).copyWith(color: AppTheme.gold),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    plan.description,
                                    style: AppTheme.mutedStyle(11, isDark: isDark),
                                  ),
                                  
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Price
                            Text(
                              '₹${plan.price}',
                              style: AppTheme.heading(22, isDark: isDark)
                                  .copyWith(color: AppTheme.gold),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 8),

                  // ── Selected Plan Summary ─────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withOpacity(0.04),
                      border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${selectedPlan.name} Plan',
                              style: AppTheme.heading(14, isDark: isDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              selectedPlan.description,
                              style: AppTheme.mutedStyle(11, isDark: isDark),
                            ),
                          ],
                        ),
                        Text(
                          '₹${selectedPlan.price}',
                          style: AppTheme.heading(20, isDark: isDark)
                              .copyWith(color: AppTheme.gold),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Pay Button ───────────────────────
                  GestureDetector(
                    onTap: _isLoading ? null : _startPayment,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      color: AppTheme.gold,
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Color(0xFF060810),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'PAY ₹${selectedPlan.price} & UNLOCK CHAT',
                                style: AppTheme.label(12).copyWith(
                                  color: const Color(0xFF060810),
                                  letterSpacing: 2,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Security note
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                          size: 12,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Secured by Razorpay · 256-bit SSL',
                          style: AppTheme.mutedStyle(11, isDark: isDark),
                        ),
                      ],
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
}

// ── Token Chip ────────────────────────────────────────────
class _TokenChip extends StatelessWidget {
  final String label;
  final bool isDark;
  const _TokenChip({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.gold.withOpacity(0.08),
        border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: AppTheme.mutedStyle(10, isDark: isDark).copyWith(
          color: AppTheme.gold.withOpacity(0.8),
        ),
      ),
    );
  }
}
