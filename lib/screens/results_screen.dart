import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class ResultsScreen extends StatefulWidget {
  final String filename;
  final List<Map<String, dynamic>> transactions;

  const ResultsScreen({
    super.key,
    required this.filename,
    required this.transactions,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> get _filtered {
    if (_searchQuery.isEmpty) return widget.transactions;
    final q = _searchQuery.toLowerCase();
    return widget.transactions.where((t) {
      return (t['desc'] ?? '').toLowerCase().contains(q) ||
          (t['date'] ?? '').toLowerCase().contains(q) ||
          (t['amount']?.toString() ?? '').contains(q);
    }).toList();
  }

  double get _totalCredit => widget.transactions
      .where((t) => t['type'] == 'CR')
      .fold(0.0, (sum, t) => sum + (t['amount'] ?? 0.0));

  double get _totalDebit => widget.transactions
      .where((t) => t['type'] == 'DR')
      .fold(0.0, (sum, t) => sum + (t['amount'] ?? 0.0));

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final surface = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final border = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
    final muted = isDark ? AppTheme.darkMuted : AppTheme.lightMuted;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.gold, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analysis',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
            ),
            Text(
              widget.filename,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: muted,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeNotifier.isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
              color: AppTheme.gold,
              size: 20,
            ),
            onPressed: () => themeNotifier.toggle(),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: border),
        ),
      ),
      body: Column(
        children: [
          // STATS ROW
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: Row(
              children: [
                _StatChip(
                  label: 'Transactions',
                  value: '${widget.transactions.length}',
                  color: AppTheme.gold,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Credits',
                  value: '₹${_formatAmount(_totalCredit)}',
                  color: const Color(0xFF4ADE80),
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Debits',
                  value: '₹${_formatAmount(_totalDebit)}',
                  color: const Color(0xFFF87171),
                ),
              ],
            ),
          ),

          // SEARCH BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: muted, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      hintStyle: GoogleFonts.dmSans(color: muted, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: Icon(Icons.close, color: muted, size: 18),
                  ),
              ],
            ),
          ),

          // RESULTS COUNT
          if (_searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Text(
                '${_filtered.length} results for "$_searchQuery"',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: muted,
                  letterSpacing: 0.3,
                ),
              ),
            ),

          // TRANSACTION LIST
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, color: muted, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 20,
                            color: muted,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      color: border,
                      indent: 16,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, i) {
                      final t = _filtered[i];
                      final isCR = t['type'] == 'CR';
                      return _TransactionTile(
                        date: t['date'] ?? '—',
                        desc: t['desc'] ?? '—',
                        amount: t['amount'],
                        balance: t['balance'],
                        isCR: isCR,
                        isDark: isDark,
                        textColor: textColor,
                        muted: muted,
                        surface: surface,
                        border: border,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: color.withOpacity(0.7),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final String date;
  final String desc;
  final double? amount;
  final double? balance;
  final bool isCR;
  final bool isDark;
  final Color textColor;
  final Color muted;
  final Color surface;
  final Color border;

  const _TransactionTile({
    required this.date,
    required this.desc,
    required this.amount,
    required this.balance,
    required this.isCR,
    required this.isDark,
    required this.textColor,
    required this.muted,
    required this.surface,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final amountColor = isCR ? const Color(0xFF4ADE80) : const Color(0xFFF87171);
    final badgeBg = isCR
        ? const Color(0xFF4ADE80).withOpacity(0.1)
        : const Color(0xFFF87171).withOpacity(0.1);
    final badgeBorder = isCR
        ? const Color(0xFF4ADE80).withOpacity(0.3)
        : const Color(0xFFF87171).withOpacity(0.3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT: Date + Badge
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: muted,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    border: Border.all(color: badgeBorder),
                  ),
                  child: Text(
                    isCR ? 'CR' : 'DR',
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: amountColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // MIDDLE: Description
          Expanded(
            child: Text(
              desc,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: textColor,
                height: 1.4,
                fontWeight: FontWeight.w300,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),

          // RIGHT: Amount + Balance
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount != null
                    ? '${isCR ? '+' : '-'}₹${amount!.toStringAsFixed(2)}'
                    : '—',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: amountColor,
                ),
              ),
              if (balance != null) ...[
                const SizedBox(height: 4),
                Text(
                  '₹${balance!.toStringAsFixed(2)}',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: muted,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
