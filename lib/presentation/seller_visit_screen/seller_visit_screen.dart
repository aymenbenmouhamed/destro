import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import './widgets/seller_visit_header_widget.dart';
import './widgets/seller_visit_invoice_sheet_widget.dart';
import './widgets/seller_visit_product_list_widget.dart';
import './widgets/seller_visit_summary_widget.dart';

class SellerVisitScreen extends StatefulWidget {
  const SellerVisitScreen({super.key});

  @override
  State<SellerVisitScreen> createState() => _SellerVisitScreenState();
}

class _SellerVisitScreenState extends State<SellerVisitScreen> {
  // TODO: Replace with Riverpod for production
  final List<Map<String, dynamic>> _productsMaps = [
    {
      'id': 'p1',
      'name': 'Huile Végétale 5L',
      'category': 'Alimentaire',
      'lastGiven': 24,
      'currentVisible': 0,
      'pricePerUnit': 18.5,
      'unit': 'bidon',
    },
    {
      'id': 'p2',
      'name': 'Savon Palmolive 200g',
      'category': 'Hygiène',
      'lastGiven': 48,
      'currentVisible': 0,
      'pricePerUnit': 2.8,
      'unit': 'pièce',
    },
    {
      'id': 'p3',
      'name': 'Lait Vache Noire 1L',
      'category': 'Laitier',
      'lastGiven': 36,
      'currentVisible': 0,
      'pricePerUnit': 1.95,
      'unit': 'bouteille',
    },
    {
      'id': 'p4',
      'name': 'Sucre Cristal 1kg',
      'category': 'Épicerie',
      'lastGiven': 20,
      'currentVisible': 0,
      'pricePerUnit': 3.2,
      'unit': 'kg',
    },
    {
      'id': 'p5',
      'name': 'Semoule Fine 1kg',
      'category': 'Épicerie',
      'lastGiven': 30,
      'currentVisible': 0,
      'pricePerUnit': 2.1,
      'unit': 'kg',
    },
  ];

  late List<VisitProduct> _products;
  final Map<String, int> _newStockToGive = {};
  bool _visitCompleted = false;

  @override
  void initState() {
    super.initState();
    // TODO: Replace with real data from backend for production
    _products = _productsMaps.map(VisitProduct.fromMap).toList();
    for (final p in _products) {
      _newStockToGive[p.id] = 0;
    }
  }

  void _onVisibleStockChanged(String productId, int value) {
    setState(() {
      final idx = _products.indexWhere((p) => p.id == productId);
      if (idx != -1) {
        _products[idx] = _products[idx].copyWith(currentVisible: value);
      }
    });
  }

  void _onNewStockChanged(String productId, int value) {
    setState(() {
      _newStockToGive[productId] = value;
    });
  }

  double get _totalOwed {
    return _products.fold(0.0, (sum, p) {
      final sold = (p.lastGiven - p.currentVisible).clamp(0, p.lastGiven);
      return sum + (sold * p.pricePerUnit);
    });
  }

  double get _previousDebt => 920.0; // TODO: Fetch from backend for production

  double get _grandTotal => _totalOwed;

  void _showInvoice() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SellerVisitInvoiceSheetWidget(
        sellerName: 'Kamel Trabelsi',
        sellerContact: '+216 71 234 567',
        sellerLocation: 'Tunis Centre',
        products: _products,
        newStockToGive: _newStockToGive,
        totalOwed: _totalOwed,
        previousDebt: _previousDebt,
        grandTotal: _grandTotal,
        visitDate: DateTime.now(),
      ),
    );
  }

  void _completeVisit() {
    setState(() => _visitCompleted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              'Visite enregistrée avec succès',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: isTablet
            ? _buildTabletLayout(context)
            : _buildPhoneLayout(context),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'invoice_fab',
            onPressed: _showInvoice,
            backgroundColor: AppTheme.surface,
            foregroundColor: AppTheme.primary,
            icon: const Icon(Icons.receipt_long_rounded),
            label: Text(
              'Générer facture',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            elevation: 3,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'complete_fab',
            onPressed: _visitCompleted ? null : _completeVisit,
            backgroundColor: _visitCompleted
                ? AppTheme.success
                : AppTheme.primary,
            foregroundColor: Colors.white,
            icon: Icon(
              _visitCompleted
                  ? Icons.check_circle_rounded
                  : Icons.done_all_rounded,
            ),
            label: Text(
              _visitCompleted ? 'Visite terminée' : 'Terminer la visite',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            elevation: 4,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: AppTheme.outline.withAlpha(77),
      leading: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: AppTheme.primary,
          ),
        ),
        onPressed: () => Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.adminDashboardScreen,
          (r) => false,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visite vendeur',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          Text(
            '30 Avril 2026 • 04:35',
            style: GoogleFonts.ibmPlexSans(fontSize: 12, color: AppTheme.muted),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.sync_rounded, size: 14, color: AppTheme.primary),
              const SizedBox(width: 4),
              Text(
                'Hors ligne',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneLayout(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: SellerVisitHeaderWidget(
              sellerName: 'Kamel Trabelsi',
              location: 'Tunis Centre',
              contact: '+216 71 234 567',
              previousDebt: _previousDebt,
              lastVisitDate: '28 Avril 2026',
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: SellerVisitProductListWidget(
              products: _products,
              onVisibleStockChanged: _onVisibleStockChanged,
              onNewStockChanged: _onNewStockChanged,
              newStockToGive: _newStockToGive,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 160),
            child: SellerVisitSummaryWidget(
              products: _products,
              previousDebt: _previousDebt,
              totalOwed: _totalOwed,
              grandTotal: _grandTotal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 12, 0),
                  child: SellerVisitHeaderWidget(
                    sellerName: 'Kamel Trabelsi',
                    location: 'Tunis Centre',
                    contact: '+216 71 234 567',
                    previousDebt: _previousDebt,
                    lastVisitDate: '28 Avril 2026',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 12, 100),
                  child: SellerVisitProductListWidget(
                    products: _products,
                    onVisibleStockChanged: _onVisibleStockChanged,
                    onNewStockChanged: _onNewStockChanged,
                    newStockToGive: _newStockToGive,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 20, 24, 100),
            child: SellerVisitSummaryWidget(
              products: _products,
              previousDebt: _previousDebt,
              totalOwed: _totalOwed,
              grandTotal: _grandTotal,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Data Model ─────────────────────────────────────────────
class VisitProduct {
  final String id;
  final String name;
  final String category;
  final int lastGiven;
  final int currentVisible;
  final double pricePerUnit;
  final String unit;

  const VisitProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.lastGiven,
    required this.currentVisible,
    required this.pricePerUnit,
    required this.unit,
  });

  factory VisitProduct.fromMap(Map<String, dynamic> map) {
    return VisitProduct(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      lastGiven: map['lastGiven'] as int,
      currentVisible: map['currentVisible'] as int,
      pricePerUnit: (map['pricePerUnit'] as num).toDouble(),
      unit: map['unit'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'lastGiven': lastGiven,
    'currentVisible': currentVisible,
    'pricePerUnit': pricePerUnit,
    'unit': unit,
  };

  VisitProduct copyWith({
    String? id,
    String? name,
    String? category,
    int? lastGiven,
    int? currentVisible,
    double? pricePerUnit,
    String? unit,
  }) {
    return VisitProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      lastGiven: lastGiven ?? this.lastGiven,
      currentVisible: currentVisible ?? this.currentVisible,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      unit: unit ?? this.unit,
    );
  }

  int get soldQuantity => (lastGiven - currentVisible).clamp(0, lastGiven);

  double get lineTotal => soldQuantity * pricePerUnit;
}
