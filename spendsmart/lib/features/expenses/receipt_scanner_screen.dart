import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/motion/haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/premium_motion.dart';
import '../../data/sample_data.dart';
import '../../models/category.dart';
import '../../models/expense.dart';

/// Receipt scanner screen — user picks an image (gallery or camera),
/// the scanner "reads" the receipt and extracts merchant / amount / date /
/// category, then pre-fills the Add Expense form.
///
/// Note: Real OCR (google_mlkit_text_recognition) is mobile-only and has
/// no web build. Since the app deploys to GitHub Pages (Flutter web), the
/// extraction here is a SIMULATED mock that picks a plausible merchant +
/// amount + category. The image picking itself is real (uses the
/// image_picker package which works on web, Android, and iOS).
class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  // Selected image as raw bytes — works on web (blob) + mobile (file).
  Uint8List? _imageBytes;
  // Whether a scan is currently in progress (shows shimmer overlay).
  bool _scanning = false;
  // The extracted expense — null until scan completes.
  Expense? _scanned;
  // Picked category's sample model (for icon + color preview).
  Category? _scannedCategory;

  final _picker = ImagePicker();

  Future<void> _pickFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      _onImagePicked(bytes);
    } on Exception catch (_) {
      _showErrorSnack('Could not pick image from gallery.');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      _onImagePicked(bytes);
    } on Exception catch (_) {
      _showErrorSnack('Could not access camera. Try gallery instead.');
    }
  }

  void _onImagePicked(Uint8List bytes) {
    Haptics.light();
    setState(() {
      _imageBytes = bytes;
      _scanning = true;
      _scanned = null;
    });
    _runScan();
  }

  /// Simulated OCR — picks a plausible merchant + amount + category from
  /// the sample data, then "extracts" an Expense pre-fill.
  /// In a real implementation this would call google_mlkit_text_recognition
  /// (mobile-only) or a cloud OCR API. On web (GitHub Pages) neither is
  /// available, so the demo flow simulates the result.
  Future<void> _runScan() async {
    // Simulate OCR latency — 1.8s feels realistic for a small image.
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    // Mock merchant list — each entry maps a merchant to a category id
    // so we can pre-fill the right category on AddExpenseScreen.
    final merchants = <(String, String)>[
      ('KFC', 'food'),
      ('McDonald\'s', 'food'),
      ('Subway', 'food'),
      ('Pizza Hut', 'food'),
      ('Canteen', 'food'),
      ('Uber', 'transport'),
      ('Careem', 'transport'),
      ('Metro Bus', 'transport'),
      ('Daewoo', 'transport'),
      ('Fuel Station', 'transport'),
      ('Imtiaz Mart', 'groceries'),
      ('Carrefour', 'groceries'),
      ('Naheed', 'groceries'),
      ('K-Electric', 'bills'),
      ('SSGC Gas', 'bills'),
      ('Water Board', 'bills'),
      ('Nayatel', 'internet'),
      ('PTCL', 'internet'),
      ('Transworld', 'internet'),
      ('Netflix', 'entertainment'),
      ('Cinepax', 'entertainment'),
      ('HBL', 'others'),
      ('Daraz', 'shopping'),
      ('Servis', 'shopping'),
      ('Staples', 'others'),
    ];

    final rng = Random();
    final entry = merchants[rng.nextInt(merchants.length)];
    final merchantName = entry.$1;
    final categoryId = entry.$2;
    // Plausible amount ranges per category
    final amountRange = switch (categoryId) {
      'food' => (150.0, 1500.0),
      'transport' => (50.0, 800.0),
      'groceries' => (500.0, 8000.0),
      'bills' => (1000.0, 12000.0),
      'internet' => (1500.0, 5000.0),
      'entertainment' => (300.0, 2500.0),
      'shopping' => (500.0, 10000.0),
      _ => (100.0, 2000.0),
    };
    final amount =
        (amountRange.$1 + rng.nextDouble() * (amountRange.$2 - amountRange.$1))
            .roundToDouble();

    final expense = Expense(
      id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
      title: merchantName,
      amount: amount,
      categoryId: categoryId,
      date: DateTime.now(),
      note: 'Scanned from receipt image',
    );

    final category = SampleData.categoryById(categoryId);
    setState(() {
      _scanned = expense;
      _scannedCategory = category;
      _scanning = false;
    });
    Haptics.success();
  }

  void _showErrorSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _addAsExpense() {
    if (_scanned == null) return;
    Haptics.selection();
    // Pop back to the caller with the scanned Expense.
    // - When launched from AddExpense AppBar, the caller receives the
    //   result and pre-fills the form.
    // - When launched from Home quick action, the caller does
    //   pushReplacement(AddExpenseScreen(prefill: result)).
    // Both flows are handled by the caller via Navigator.pop(scanned).
    Navigator.of(context).pop(_scanned);
  }

  void _reset() {
    setState(() {
      _imageBytes = null;
      _scanning = false;
      _scanned = null;
      _scannedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          if (_imageBytes != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Start over',
              onPressed: _reset,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Headline + subtitle ──
              Text(
                'Scan a receipt to auto-fill an expense',
                style: TextStyles.h2(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Pick an image of a receipt — we\'ll extract the merchant, amount, and date for you.',
                style: TextStyles.body(
                  context,
                  color: AppColorsOf.secondaryText(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // ── Image area: empty state / preview / scanning overlay ──
              if (_imageBytes == null) ...[
                _emptyDropArea(),
              ] else ...[
                _imagePreviewArea(),
              ],

              const SizedBox(height: 16),

              // ── Source buttons (always visible until scan completes) ──
              if (_scanned == null) ...[
                Row(
                  children: [
                    Expanded(
                      child: _sourceButton(
                        icon: Icons.photo_library_rounded,
                        label: _imageBytes == null
                            ? 'Pick from Gallery'
                            : 'Pick another',
                        color: AppColors.primaryIndigo,
                        onTap: _pickFromGallery,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _sourceButton(
                        icon: Icons.camera_alt_rounded,
                        label: _imageBytes == null
                            ? 'Take Photo'
                            : 'Retake',
                        color: AppColors.primaryPurple,
                        onTap: _takePhoto,
                      ),
                    ),
                  ],
                ),
              ],

              // ── Scanned result ──
              if (_scanned != null && _scannedCategory != null) ...[
                const SizedBox(height: 8),
                _scannedResultCard(),
                const SizedBox(height: 16),
                MorphingLoadingButton(
                  label: 'Add as Expense',
                  icon: Icons.check_circle_rounded,
                  onPressed: _addAsExpense,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _reset,
                  child: const Text('Scan another receipt'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Empty drop area — shown when no image has been picked yet.
  // Big dashed-looking card inviting the user to pick an image.
  // ─────────────────────────────────────────────────────────────────
  Widget _emptyDropArea() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: AppColorsOf.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryIndigo.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryIndigo.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.document_scanner_rounded,
              size: 32,
              color: AppColors.primaryIndigo,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No image selected',
            style: TextStyles.body(context, weight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap a button below to pick a receipt',
            style: TextStyles.caption(context)
                .copyWith(color: AppColorsOf.tertiaryText(context)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Image preview — shows the picked image, with a shimmer overlay
  // during the simulated scan.
  // ─────────────────────────────────────────────────────────────────
  Widget _imagePreviewArea() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          // Actual picked image — uses Image.memory so it works on
          // web (blob bytes) and mobile (file bytes) alike.
          Container(
            height: 280,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColorsOf.card(context),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColorsOf.border(context)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.memory(
              _imageBytes!,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
          // Scanning shimmer overlay
          if (_scanning)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.55),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const PremiumLoadingIndicator(
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Scanning receipt…',
                      style: TextStyles.body(
                        context,
                        weight: FontWeight.w700,
                      ).copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Extracting merchant, amount, and date',
                      style: TextStyles.caption(context)
                          .copyWith(color: Colors.white.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Source button — gallery / camera
  // ─────────────────────────────────────────────────────────────────
  Widget _sourceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            border: Border.all(color: color.withOpacity(0.35), width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyles.caption(context, weight: FontWeight.w700)
                      .copyWith(color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Scanned result card — shows the extracted merchant, amount,
  // category, and date in a clean summary before "Add as Expense".
  // ─────────────────────────────────────────────────────────────────
  Widget _scannedResultCard() {
    final e = _scanned!;
    final c = _scannedCategory!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsOf.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.mint.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mint.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.mint.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.mint,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan complete',
                      style: TextStyles.caption(context, weight: FontWeight.w700)
                          .copyWith(color: AppColors.mint),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Review the details below',
                      style: TextStyles.caption(context)
                          .copyWith(color: AppColorsOf.tertiaryText(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Merchant row
          _resultRow(
            label: 'Merchant',
            value: e.title,
            trailing: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c.color.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(c.icon, color: c.color, size: 18),
            ),
          ),
          const SizedBox(height: 10),
          // Category row
          _resultRow(
            label: 'Category',
            value: c.name,
            valueColor: c.color,
          ),
          const SizedBox(height: 10),
          // Amount row — visually emphasized
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppGradients.primaryButton,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount',
                  style: TextStyles.caption(context, weight: FontWeight.w700)
                      .copyWith(color: Colors.white),
                ),
                Text(
                  Formatters.money(e.amount),
                  style: TextStyles.money(context, size: 18, color: Colors.white)
                      .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Date row
          _resultRow(
            label: 'Date',
            value: Formatters.dateTime(e.date),
          ),
        ],
      ),
    );
  }

  Widget _resultRow({
    required String label,
    required String value,
    Widget? trailing,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyles.caption(context)
              .copyWith(color: AppColorsOf.tertiaryText(context)),
        ),
        const Spacer(),
        if (trailing != null) ...[trailing, const SizedBox(width: 8)],
        Text(
          value,
          style: TextStyles.body(context, weight: FontWeight.w700)
              .copyWith(color: valueColor ?? AppColorsOf.mainText(context)),
        ),
      ],
    );
  }
}
