import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BusinessManagerApp());
}

class BusinessManagerApp extends StatefulWidget {
  const BusinessManagerApp({super.key});

  @override
  State<BusinessManagerApp> createState() => _BusinessManagerAppState();
}

class _BusinessManagerAppState extends State<BusinessManagerApp> {
  bool _isDarkMode = false;
  bool _isThemeLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
      _isThemeLoaded = true;
    });
  }

  void _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = value;
    });
    await prefs.setBool('is_dark_mode', value);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isThemeLoaded) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'StockWise',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // Light Theme
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF059669),
          brightness: Brightness.light,
          primary: const Color(0xFF059669),
          secondary: const Color(0xFF10B981),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 1,
        ),
      ),

      // Dark Theme
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF059669),
          brightness: Brightness.dark,
          primary: const Color(0xFF059669),
          secondary: const Color(0xFF10B981),
          surface: const Color(0xFF1E293B),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
          elevation: 1,
        ),
      ),
      home: MainNavigationScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: _toggleDarkMode,
      ),
    );
  }
}

// ==================== ENUMS ====================
enum DateFilterPeriod { allTime, today, thisMonth }
enum LaborFormulaMode { perHour, perMinute, flatRate }

// ==================== DATA MODELS ====================
class Product {
  final String id;
  String name;
  String category;
  double price;
  int stock;
  int minStockAlert;
  String photoPath;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.minStockAlert = 5,
    this.photoPath = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        'stock': stock,
        'minStockAlert': minStockAlert,
        'photoPath': photoPath,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'] ?? '',
        category: json['category'] ?? 'General',
        price: (json['price'] as num).toDouble(),
        stock: (json['stock'] as num).toInt(),
        minStockAlert: (json['minStockAlert'] as num?)?.toInt() ?? 5,
        photoPath: json['photoPath'] ?? '',
      );
}

class MaterialItem {
  final String id;
  String name;
  double price;
  int stock;
  int minStockAlert;
  String unit;

  MaterialItem({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.minStockAlert = 10,
    required this.unit,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'stock': stock,
        'minStockAlert': minStockAlert,
        'unit': unit,
      };

  factory MaterialItem.fromJson(Map<String, dynamic> json) => MaterialItem(
        id: json['id'],
        name: json['name'] ?? '',
        price: (json['price'] as num).toDouble(),
        stock: (json['stock'] as num).toInt(),
        minStockAlert: (json['minStockAlert'] as num?)?.toInt() ?? 10,
        unit: json['unit'] ?? 'pcs',
      );
}

class SaleRecord {
  final String id;
  final String productId;
  final String productName;
  final String category;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime saleDate;

  SaleRecord({
    required this.id,
    required this.productId,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.saleDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'category': category,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
        'saleDate': saleDate.toIso8601String(),
      };

  factory SaleRecord.fromJson(Map<String, dynamic> json) => SaleRecord(
        id: json['id'],
        productId: json['productId'] ?? '',
        productName: json['productName'] ?? 'Product',
        category: json['category'] ?? 'General',
        quantity: (json['quantity'] as num).toInt(),
        unitPrice: (json['unitPrice'] as num).toDouble(),
        totalPrice: (json['totalPrice'] as num).toDouble(),
        saleDate: DateTime.parse(json['saleDate']),
      );
}

class ExpenseRecord {
  final String id;
  String itemOrMaterialName;
  double price;
  DateTime dateAcquired;
  String purpose;

  ExpenseRecord({
    required this.id,
    required this.itemOrMaterialName,
    required this.price,
    required this.dateAcquired,
    required this.purpose,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemOrMaterialName': itemOrMaterialName,
        'price': price,
        'dateAcquired': dateAcquired.toIso8601String(),
        'purpose': purpose,
      };

  factory ExpenseRecord.fromJson(Map<String, dynamic> json) => ExpenseRecord(
        id: json['id'],
        itemOrMaterialName: json['itemOrMaterialName'] ?? '',
        price: (json['price'] as num).toDouble(),
        dateAcquired: DateTime.parse(json['dateAcquired']),
        purpose: json['purpose'] ?? 'General',
      );
}

class SelectedCostingMaterial {
  final MaterialItem material;
  int quantity;

  SelectedCostingMaterial({required this.material, this.quantity = 1});

  double get totalCost => material.price * quantity;
}

// ==================== MAIN NAVIGATION SCREEN ====================
class MainNavigationScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const MainNavigationScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  DateFilterPeriod _activeFilter = DateFilterPeriod.allTime;

  List<Product> _products = [];
  List<MaterialItem> _materials = [];
  List<SaleRecord> _sales = [];
  List<ExpenseRecord> _expenses = [];

  // Search & Filter State for Products and Materials
  String _productSearchQuery = '';
  String _selectedProductCategory = 'All';
  String _materialSearchQuery = '';

  final List<String> _tabTitles = [
    'Dashboard',
    'Products',
    'Materials',
    'Costing Calculator',
    'Sales',
    'Expenses'
  ];

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? productsJson = prefs.getString('saved_products');
      final String? materialsJson = prefs.getString('saved_materials');
      final String? salesJson = prefs.getString('saved_sales');
      final String? expensesJson = prefs.getString('saved_expenses');

      setState(() {
        if (productsJson != null && productsJson.isNotEmpty) {
          _products = (jsonDecode(productsJson) as List).map((i) => Product.fromJson(i)).toList();
        }
        if (materialsJson != null && materialsJson.isNotEmpty) {
          _materials = (jsonDecode(materialsJson) as List).map((i) => MaterialItem.fromJson(i)).toList();
        }
        if (salesJson != null && salesJson.isNotEmpty) {
          _sales = (jsonDecode(salesJson) as List).map((i) => SaleRecord.fromJson(i)).toList();
        }
        if (expensesJson != null && expensesJson.isNotEmpty) {
          _expenses = (jsonDecode(expensesJson) as List).map((i) => ExpenseRecord.fromJson(i)).toList();
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading local data: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_products', jsonEncode(_products.map((p) => p.toJson()).toList()));
      await prefs.setString('saved_materials', jsonEncode(_materials.map((m) => m.toJson()).toList()));
      await prefs.setString('saved_sales', jsonEncode(_sales.map((s) => s.toJson()).toList()));
      await prefs.setString('saved_expenses', jsonEncode(_expenses.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint("Error saving local data: $e");
    }
  }

  Future<bool> _confirmDelete(String itemTitle) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text('Are you sure you want to delete "$itemTitle"? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _formatCurrency(double amount) {
    if (amount == 0) return '0.00';
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    return '$integerPart.${parts[1]}';
  }

  bool _isDateInFilter(DateTime date) {
    final now = DateTime.now();
    switch (_activeFilter) {
      case DateFilterPeriod.today:
        return date.year == now.year && date.month == now.month && date.day == now.day;
      case DateFilterPeriod.thisMonth:
        return date.year == now.year && date.month == now.month;
      case DateFilterPeriod.allTime:
      default:
        return true;
    }
  }

  List<SaleRecord> get _filteredSales => _sales.where((s) => _isDateInFilter(s.saleDate)).toList();
  List<ExpenseRecord> get _filteredExpenses => _expenses.where((e) => _isDateInFilter(e.dateAcquired)).toList();

  Future<void> _exportAndShareSalesCSV() async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('Sale ID,Product Name,Category,Quantity,Unit Price (PHP),Total Price (PHP),Sale Date');
      for (var sale in _sales) {
        buffer.writeln('${sale.id},"${sale.productName}","${sale.category}",${sale.quantity},${sale.unitPrice},${sale.totalPrice},${sale.saleDate.toIso8601String()}');
      }

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/sales_report_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(buffer.toString());

      await Share.shareXFiles([XFile(file.path)], text: 'Here is your StockWise Sales Export Report.');
    } catch (e) {
      debugPrint("Error exporting file: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to export CSV file: $e')));
      }
    }
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('App Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(height: 24),
              SwitchListTile(
                title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Enable dark color theme across the app'),
                value: widget.isDarkMode,
                onChanged: (val) {
                  widget.onThemeChanged(val);
                  setModalState(() {});
                },
                secondary: Icon(
                  widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: const Color(0xFF059669),
                ),
              ),
              const SizedBox(height: 10),
              const ListTile(
                leading: Icon(Icons.storage, color: Color(0xFF059669)),
                title: Text('Storage Mode'),
                subtitle: Text('100% Offline Local Device Storage'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecordSaleModal([Product? preselectedProduct]) {
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please register products first before recording a sale.')));
      return;
    }

    Product selectedProduct = preselectedProduct ?? _products.first;
    final quantityCtrl = TextEditingController(text: '1');
    DateTime selectedSaleDate = DateTime.now();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Record Product Sale', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                DropdownButtonFormField<Product>(
                  value: _products.contains(selectedProduct) ? selectedProduct : _products.first,
                  decoration: const InputDecoration(labelText: 'Select Product', border: OutlineInputBorder()),
                  items: _products.map((p) => DropdownMenuItem(value: p, child: Text('${p.name} (Stock: ${p.stock})'))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedProduct = val);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: quantityCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity Sold', border: OutlineInputBorder()),
                  validator: (val) {
                    final qty = int.tryParse(val ?? '');
                    if (qty == null || qty <= 0) return 'Enter a valid quantity';
                    if (qty > selectedProduct.stock) return 'Exceeds stock (${selectedProduct.stock})';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedSaleDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setModalState(() {
                        selectedSaleDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          DateTime.now().hour,
                          DateTime.now().minute,
                        );
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Sale Date', border: OutlineInputBorder()),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(selectedSaleDate.toIso8601String().split('T').first, style: const TextStyle(fontWeight: FontWeight.w500)),
                        const Icon(Icons.calendar_today, size: 18, color: Color(0xFF059669)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                    label: const Text('Confirm Sale & Deduct Stock', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      final qty = int.parse(quantityCtrl.text);

                      setState(() {
                        selectedProduct.stock -= qty;
                        _sales.insert(
                          0,
                          SaleRecord(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            productId: selectedProduct.id,
                            productName: selectedProduct.name,
                            category: selectedProduct.category,
                            quantity: qty,
                            unitPrice: selectedProduct.price,
                            totalPrice: selectedProduct.price * qty,
                            saleDate: selectedSaleDate,
                          ),
                        );
                      });

                      _saveLocalData();
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sale logged for ${selectedSaleDate.toIso8601String().split('T').first}!')));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddOrEditProductModal([Product? existingProduct]) {
    final isEdit = existingProduct != null;
    final nameCtrl = TextEditingController(text: isEdit ? existingProduct.name : '');
    final categoryCtrl = TextEditingController(text: isEdit ? existingProduct.category : '');
    final priceCtrl = TextEditingController(text: isEdit ? existingProduct.price.toString() : '');
    final stockCtrl = TextEditingController(text: isEdit ? existingProduct.stock.toString() : '');
    final minStockCtrl = TextEditingController(text: isEdit ? existingProduct.minStockAlert.toString() : '5');
    String photoPath = isEdit ? existingProduct.photoPath : '';

    final formKey = GlobalKey<FormState>();

    Future<void> pickImage(ImageSource source, StateSetter setModalState) async {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source, imageQuality: 80);
      if (image != null) {
        setModalState(() {
          photoPath = image.path;
        });
      }
    }

    void showImageSourceOptions(StateSetter setModalState) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo (Camera)'),
                onTap: () {
                  Navigator.pop(ctx);
                  pickImage(ImageSource.camera, setModalState);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery / Album'),
                onTap: () {
                  Navigator.pop(ctx);
                  pickImage(ImageSource.gallery, setModalState);
                },
              ),
            ],
          ),
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isEdit ? 'Edit Product' : 'Add New Product', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () => showImageSourceOptions(setModalState),
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF059669), width: 1.5),
                        ),
                        child: photoPath.isNotEmpty && File(photoPath).existsSync()
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(File(photoPath), fit: BoxFit.cover),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, color: Color(0xFF059669), size: 32),
                                  SizedBox(height: 4),
                                  Text('Attach Photo', style: TextStyle(fontSize: 10, color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Product name is required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: categoryCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: priceCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Price (₱)', border: OutlineInputBorder()),
                          validator: (v) => (double.tryParse(v ?? '') ?? -1) < 0 ? 'Invalid price' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: stockCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Stock Qty', border: OutlineInputBorder()),
                          validator: (v) => (int.tryParse(v ?? '') ?? -1) < 0 ? 'Invalid stock' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: minStockCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Low Stock Alert Threshold', border: OutlineInputBorder()),
                    validator: (v) => (int.tryParse(v ?? '') ?? -1) < 0 ? 'Invalid threshold' : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: Text(isEdit ? 'Update Product' : 'Save Product', style: const TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        setState(() {
                          if (isEdit) {
                            existingProduct.name = nameCtrl.text.trim();
                            existingProduct.category = categoryCtrl.text.isEmpty ? 'General' : categoryCtrl.text.trim();
                            existingProduct.price = double.parse(priceCtrl.text);
                            existingProduct.stock = int.parse(stockCtrl.text);
                            existingProduct.minStockAlert = int.parse(minStockCtrl.text);
                            existingProduct.photoPath = photoPath;
                          } else {
                            _products.add(Product(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              name: nameCtrl.text.trim(),
                              category: categoryCtrl.text.isEmpty ? 'General' : categoryCtrl.text.trim(),
                              price: double.parse(priceCtrl.text),
                              stock: int.parse(stockCtrl.text),
                              minStockAlert: int.parse(minStockCtrl.text),
                              photoPath: photoPath,
                            ));
                          }
                        });
                        _saveLocalData();
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _deleteProductWithConfirm(Product product) async {
    final confirmed = await _confirmDelete(product.name);
    if (confirmed) {
      setState(() => _products.removeWhere((p) => p.id == product.id));
      _saveLocalData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted.')));
    }
  }

  void _showAddOrEditMaterialModal([MaterialItem? existingMaterial]) {
    final isEdit = existingMaterial != null;
    final nameCtrl = TextEditingController(text: isEdit ? existingMaterial.name : '');
    final priceCtrl = TextEditingController(text: isEdit ? existingMaterial.price.toString() : '');
    final stockCtrl = TextEditingController(text: isEdit ? existingMaterial.stock.toString() : '');
    final minStockCtrl = TextEditingController(text: isEdit ? existingMaterial.minStockAlert.toString() : '10');
    final unitCtrl = TextEditingController(text: isEdit ? existingMaterial.unit : '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isEdit ? 'Edit Material Item' : 'Add Raw Material', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Material Name', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Material name is required' : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Unit Price (₱)', border: OutlineInputBorder()),
                        validator: (v) => (double.tryParse(v ?? '') ?? -1) < 0 ? 'Invalid price' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Stock Qty', border: OutlineInputBorder()),
                        validator: (v) => (int.tryParse(v ?? '') ?? -1) < 0 ? 'Invalid stock' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: minStockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Low Stock Threshold', border: OutlineInputBorder()),
                  validator: (v) => (int.tryParse(v ?? '') ?? -1) < 0 ? 'Invalid threshold' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Unit (e.g. pcs, sheets, kg)', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: Text(isEdit ? 'Update Material' : 'Save Material', style: const TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      setState(() {
                        if (isEdit) {
                          existingMaterial.name = nameCtrl.text.trim();
                          existingMaterial.price = double.parse(priceCtrl.text);
                          existingMaterial.stock = int.parse(stockCtrl.text);
                          existingMaterial.minStockAlert = int.parse(minStockCtrl.text);
                          existingMaterial.unit = unitCtrl.text.isEmpty ? 'pcs' : unitCtrl.text.trim();
                        } else {
                          _materials.add(MaterialItem(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: nameCtrl.text.trim(),
                            price: double.parse(priceCtrl.text),
                            stock: int.parse(stockCtrl.text),
                            minStockAlert: int.parse(minStockCtrl.text),
                            unit: unitCtrl.text.isEmpty ? 'pcs' : unitCtrl.text.trim(),
                          ));
                        }
                      });
                      _saveLocalData();
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteMaterialWithConfirm(MaterialItem material) async {
    final confirmed = await _confirmDelete(material.name);
    if (confirmed) {
      setState(() => _materials.removeWhere((m) => m.id == material.id));
      _saveLocalData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Material deleted.')));
    }
  }

  void _showAddOrEditExpenseModal([ExpenseRecord? existingExpense]) {
    final isEdit = existingExpense != null;
    final nameCtrl = TextEditingController(text: isEdit ? existingExpense.itemOrMaterialName : '');
    final priceCtrl = TextEditingController(text: isEdit ? existingExpense.price.toString() : '');
    final purposeCtrl = TextEditingController(text: isEdit ? existingExpense.purpose : '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isEdit ? 'Edit Expense Record' : 'Log New Expense', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Item / Service Name', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount Spent (₱)', border: OutlineInputBorder()),
                  validator: (v) => (double.tryParse(v ?? '') ?? -1) < 0 ? 'Invalid amount' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(controller: purposeCtrl, decoration: const InputDecoration(labelText: 'Purpose / Description', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: Text(isEdit ? 'Update Expense' : 'Record Expense', style: const TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      setState(() {
                        if (isEdit) {
                          existingExpense.itemOrMaterialName = nameCtrl.text.trim();
                          existingExpense.price = double.parse(priceCtrl.text);
                          existingExpense.purpose = purposeCtrl.text.isEmpty ? 'General Operational Expense' : purposeCtrl.text.trim();
                        } else {
                          _expenses.insert(
                            0,
                            ExpenseRecord(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              itemOrMaterialName: nameCtrl.text.trim(),
                              price: double.parse(priceCtrl.text),
                              dateAcquired: DateTime.now(),
                              purpose: purposeCtrl.text.isEmpty ? 'General Operational Expense' : purposeCtrl.text.trim(),
                            ),
                          );
                        }
                      });
                      _saveLocalData();
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteExpenseWithConfirm(ExpenseRecord expense) async {
    final confirmed = await _confirmDelete(expense.itemOrMaterialName);
    if (confirmed) {
      setState(() => _expenses.removeWhere((e) => e.id == expense.id));
      _saveLocalData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense deleted.')));
    }
  }

  Widget _buildNavigationDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            color: const Color(0xFF059669),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.store, color: Color(0xFF059669), size: 30),
                ),
                SizedBox(height: 12),
                Text('StockWise', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text('Offline Business Operations', style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _buildDrawerTile(0, 'Dashboard', Icons.dashboard_outlined, Icons.dashboard),
                _buildDrawerTile(1, 'Products', Icons.shopping_bag_outlined, Icons.shopping_bag),
                _buildDrawerTile(2, 'Materials', Icons.layers_outlined, Icons.layers),
                _buildDrawerTile(3, 'Costing Calculator', Icons.calculate_outlined, Icons.calculate),
                _buildDrawerTile(4, 'Sales', Icons.trending_up_outlined, Icons.trending_up),
                _buildDrawerTile(5, 'Expenses', Icons.receipt_long_outlined, Icons.receipt_long),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: Color(0xFF64748B)),
                  title: const Text('Settings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    _showSettingsModal();
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('StockWise v2.3', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          )
        ],
      ),
    );
  }

  Widget _buildDrawerTile(int index, String title, IconData icon, IconData selectedIcon) {
    final isSelected = _currentIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF059669).withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? const Color(0xFF059669) : const Color(0xFF64748B),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF059669) : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        onTap: () {
          setState(() => _currentIndex = index);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF059669))));
    }

    final List<Widget> pages = [
      _buildDashboardHome(),
      _buildProductsScreen(),
      _buildMaterialsScreen(),
      CostingCalculatorScreen(materialsInventory: _materials, formatCurrency: _formatCurrency),
      _buildSalesScreen(),
      _buildExpensesScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_tabTitles[_currentIndex], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart, color: Color(0xFF059669)),
            tooltip: 'Record Sale',
            onPressed: () => _showRecordSaleModal(),
          )
        ],
      ),
      drawer: _buildNavigationDrawer(),
      body: IndexedStack(index: _currentIndex, children: pages),
    );
  }

  // ==================== DASHBOARD HOME (Shortcuts removed) ====================
  Widget _buildDashboardHome() {
    final totalSalesRevenue = _filteredSales.fold(0.0, (sum, s) => sum + s.totalPrice);
    final totalExpenses = _filteredExpenses.fold(0.0, (sum, e) => sum + e.price);
    
    final lowStockProducts = _products.where((p) => p.stock <= p.minStockAlert).toList();
    
    final Map<String, int> productSalesCount = {};
    for (var sale in _filteredSales) {
      productSalesCount[sale.productName] = (productSalesCount[sale.productName] ?? 0) + sale.quantity;
    }
    final sortedTopProducts = productSalesCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 2),
                      Text("Here's what's happening with your business.", style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<DateFilterPeriod>(
                        isDense: true,
                        value: _activeFilter,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                        items: const [
                          DropdownMenuItem(value: DateFilterPeriod.allTime, child: Text('All Time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                          DropdownMenuItem(value: DateFilterPeriod.thisMonth, child: Text('This Month', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                          DropdownMenuItem(value: DateFilterPeriod.today, child: Text('Today', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _activeFilter = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              const Text('Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 750;
                  return GridView.count(
                    crossAxisCount: isWide ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: isWide ? 1.4 : 1.5,
                    children: [
                      _buildOverviewMetricCard('Total Products', '${_products.length}', Icons.shopping_bag_outlined, const Color(0xFF7C3AED), 'Active products'),
                      _buildOverviewMetricCard('Total Materials', '${_materials.length}', Icons.layers_outlined, const Color(0xFF059669), 'In inventory'),
                      _buildOverviewMetricCard('Total Sales', '₱ ${_formatCurrency(totalSalesRevenue)}', Icons.trending_up, const Color(0xFF2563EB), _activeFilter == DateFilterPeriod.today ? 'Today' : (_activeFilter == DateFilterPeriod.thisMonth ? 'This month' : 'All time')),
                      _buildOverviewMetricCard('Total Expenses', '₱ ${_formatCurrency(totalExpenses)}', Icons.trending_down, const Color(0xFFDC2626), _activeFilter == DateFilterPeriod.today ? 'Today' : (_activeFilter == DateFilterPeriod.thisMonth ? 'This month' : 'All time')),
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),

              // Visual Sales Overview Card using fl_chart
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sales Trend Analytics', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text('Visual Chart', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('₱ ${_formatCurrency(totalSalesRevenue)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 140,
                        child: _filteredSales.isEmpty
                            ? const Center(child: Text('Not enough sales data to plot chart.', style: TextStyle(fontSize: 12, color: Colors.grey)))
                            : LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: false),
                                  titlesData: const FlTitlesData(show: false),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: _filteredSales.asMap().entries.map((e) {
                                        return FlSpot(e.key.toDouble(), e.value.totalPrice);
                                      }).toList(),
                                      isCurved: true,
                                      color: const Color(0xFF059669),
                                      barWidth: 3,
                                      dotData: const FlDotData(show: true),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: const Color(0xFF059669).withOpacity(0.15),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildTopSellingCard(sortedTopProducts)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildLowStockCard(lowStockProducts)),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildTopSellingCard(sortedTopProducts),
                        const SizedBox(height: 16),
                        _buildLowStockCard(lowStockProducts),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewMetricCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Text(subtitle, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTopSellingCard(List<MapEntry<String, int>> sortedTopProducts) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top Selling Products', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            sortedTopProducts.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: Text('No product sales recorded yet.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12))),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedTopProducts.length > 3 ? 3 : sortedTopProducts.length,
                    itemBuilder: (ctx, i) {
                      final entry = sortedTopProducts[i];
                      final matchingProduct = _products.firstWhere(
                        (p) => p.name == entry.key,
                        orElse: () => Product(id: '', name: entry.key, category: '', price: 0, stock: 0),
                      );
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: matchingProduct.photoPath.isNotEmpty && File(matchingProduct.photoPath).existsSync()
                                  ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(matchingProduct.photoPath), fit: BoxFit.cover))
                                  : const Icon(Icons.inventory_2, size: 18, color: Colors.grey),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('${entry.value} units sold', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            Text('₱ ${_formatCurrency(matchingProduct.price * entry.value)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669), fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockCard(List<Product> lowStockProducts) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Low Stock Alerts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
            const SizedBox(height: 12),
            lowStockProducts.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: Text('All product inventory levels are healthy.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12))),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lowStockProducts.length > 3 ? 3 : lowStockProducts.length,
                    itemBuilder: (ctx, i) {
                      final item = lowStockProducts[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: item.photoPath.isNotEmpty && File(item.photoPath).existsSync()
                                  ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(item.photoPath), fit: BoxFit.cover))
                                  : const Icon(Icons.warning_amber_rounded, size: 18, color: Colors.red),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('Threshold: ${item.minStockAlert}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            Text('${item.stock} left', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626), fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  // ==================== 2. PRODUCTS TAB (With Search Bar & Category Chips) ====================
  Widget _buildProductsScreen() {
    final categories = ['All', ..._products.map((p) => p.category).where((c) => c.isNotEmpty).toSet()];

    final filteredProducts = _products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_productSearchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_productSearchQuery.toLowerCase());
      final matchesCategory = _selectedProductCategory == 'All' || p.category == _selectedProductCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products by name...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF059669)),
                suffixIcon: _productSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _productSearchQuery = ''),
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
              onChanged: (val) => setState(() => _productSearchQuery = val),
            ),
          ),
          if (categories.length > 1)
            SizedBox(
              height: 45,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: categories.map((cat) {
                  final isSelected = _selectedProductCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(cat, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : null)),
                      selected: isSelected,
                      selectedColor: const Color(0xFF059669),
                      onSelected: (_) => setState(() => _selectedProductCategory = cat),
                    ),
                  );
                }).toList(),
              ),
            ),
          const Divider(height: 10),

          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_bag_outlined, size: 64, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 16),
                        Text(_products.isEmpty ? 'No products registered yet.' : 'No matching products found.', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 6),
                        if (_products.isEmpty) ...[
                          const Text('Add your first product to track inventory.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Product'),
                            onPressed: () => _showAddOrEditProductModal(),
                          ),
                        ]
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredProducts.length,
                    itemBuilder: (ctx, idx) {
                      final product = filteredProducts[idx];
                      final isLowStock = product.stock <= product.minStockAlert;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: product.photoPath.isNotEmpty && File(product.photoPath).existsSync()
                                    ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(product.photoPath), fit: BoxFit.cover))
                                    : const Icon(Icons.image_not_supported, color: Colors.grey, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    Text('₱ ${_formatCurrency(product.price)} • Stock: ${product.stock}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isLowStock ? Colors.red : const Color(0xFF059669),
                                          fontSize: 12,
                                        )),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Color(0xFF0284C7), size: 20),
                                    onPressed: () => _showAddOrEditProductModal(product),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Color(0xFFDC2626), size: 20),
                                    onPressed: () => _deleteProductWithConfirm(product),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrEditProductModal(),
        backgroundColor: const Color(0xFF059669),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ==================== 3. MATERIALS TAB (With Search Bar) ====================
  Widget _buildMaterialsScreen() {
    final filteredMaterials = _materials.where((m) {
      return m.name.toLowerCase().contains(_materialSearchQuery.toLowerCase()) ||
          m.unit.toLowerCase().contains(_materialSearchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search raw materials by name or unit...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF059669)),
                suffixIcon: _materialSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _materialSearchQuery = ''),
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
              onChanged: (val) => setState(() => _materialSearchQuery = val),
            ),
          ),
          Expanded(
            child: filteredMaterials.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.layers_outlined, size: 64, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 16),
                        Text(_materials.isEmpty ? 'No raw materials found.' : 'No matching materials found.', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        if (_materials.isEmpty) ...[
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Material'),
                            onPressed: () => _showAddOrEditMaterialModal(),
                          ),
                        ]
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filteredMaterials.length,
                    itemBuilder: (ctx, idx) {
                      final material = filteredMaterials[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(material.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    Text('₱ ${_formatCurrency(material.price)} per ${material.unit} | Stock: ${material.stock}', style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Color(0xFF0284C7), size: 20),
                                    onPressed: () => _showAddOrEditMaterialModal(material),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Color(0xFFDC2626), size: 20),
                                    onPressed: () => _deleteMaterialWithConfirm(material),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrEditMaterialModal(),
        backgroundColor: const Color(0xFF059669),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Material', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ==================== 5. SALES LOG TAB ====================
  Widget _buildSalesScreen() {
    final filteredSales = _filteredSales;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Sales Records: ${filteredSales.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('Share CSV'),
                  onPressed: _exportAndShareSalesCSV,
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredSales.isEmpty
                ? const Center(child: Text('No sales records found for this period.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filteredSales.length,
                    itemBuilder: (ctx, idx) {
                      final sale = filteredSales[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text('${sale.productName} (x${sale.quantity})', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Date: ${sale.saleDate.toIso8601String().split('T').first}'),
                          trailing: Text('₱ ${_formatCurrency(sale.totalPrice)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRecordSaleModal(),
        backgroundColor: const Color(0xFF059669),
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text('Record Sale', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ==================== 6. EXPENSES TAB ====================
  Widget _buildExpensesScreen() {
    final filteredExpenses = _filteredExpenses;
    return Scaffold(
      body: filteredExpenses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 64, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 16),
                  const Text('No expense entries logged.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
                    icon: const Icon(Icons.add),
                    label: const Text('Log Expense'),
                    onPressed: () => _showAddOrEditExpenseModal(),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredExpenses.length,
              itemBuilder: (ctx, idx) {
                final expense = filteredExpenses[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(expense.itemOrMaterialName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text('Purpose: ${expense.purpose}', style: const TextStyle(fontSize: 11)),
                              Text('₱ ${_formatCurrency(expense.price)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626), fontSize: 14)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF0284C7), size: 20),
                              onPressed: () => _showAddOrEditExpenseModal(expense),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Color(0xFFDC2626), size: 20),
                              onPressed: () => _deleteExpenseWithConfirm(expense),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrEditExpenseModal(),
        backgroundColor: const Color(0xFFDC2626),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ==================== COSTING CALCULATOR ====================
class CostingCalculatorScreen extends StatefulWidget {
  final List<MaterialItem> materialsInventory;
  final String Function(double) formatCurrency;

  const CostingCalculatorScreen({
    super.key,
    required this.materialsInventory,
    required this.formatCurrency,
  });

  @override
  State<CostingCalculatorScreen> createState() => _CostingCalculatorScreenState();
}

class _CostingCalculatorScreenState extends State<CostingCalculatorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _matBulkCostCtrl = TextEditingController();
  final _matYieldPiecesCtrl = TextEditingController();
  double _computedCostPerPiece = 0.0;

  final List<SelectedCostingMaterial> _selectedMaterials = [];
  final _laborRateCtrl = TextEditingController();
  final _laborTimeCtrl = TextEditingController();
  final _overheadCtrl = TextEditingController();

  LaborFormulaMode _laborFormulaMode = LaborFormulaMode.perHour;
  double _computedTotalProductCost = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _matBulkCostCtrl.dispose();
    _matYieldPiecesCtrl.dispose();
    _laborRateCtrl.dispose();
    _laborTimeCtrl.dispose();
    _overheadCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _calculateUnitMaterialCost() {
    final bulkCost = double.tryParse(_matBulkCostCtrl.text) ?? 0.0;
    final yieldPcs = double.tryParse(_matYieldPiecesCtrl.text) ?? 1.0;
    setState(() {
      _computedCostPerPiece = yieldPcs > 0 ? bulkCost / yieldPcs : 0.0;
    });
  }

  void _recalculateProductCost() {
    final matTotal = _selectedMaterials.fold(0.0, (sum, m) => sum + m.totalCost);
    final laborRate = double.tryParse(_laborRateCtrl.text) ?? 0.0;
    final laborTime = double.tryParse(_laborTimeCtrl.text) ?? 0.0;
    final overhead = double.tryParse(_overheadCtrl.text) ?? 0.0;

    double laborCost = 0.0;
    switch (_laborFormulaMode) {
      case LaborFormulaMode.perHour:
        laborCost = (laborRate / 60) * laborTime;
        break;
      case LaborFormulaMode.perMinute:
        laborCost = laborRate * laborTime;
        break;
      case LaborFormulaMode.flatRate:
        laborCost = laborRate;
        break;
    }

    setState(() {
      _computedTotalProductCost = matTotal + laborCost + overhead;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF059669),
          indicatorColor: const Color(0xFF059669),
          tabs: const [
            Tab(text: 'Material Yield Cost'),
            Tab(text: 'Product Costing'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Unit Material Cost Calculator', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _matBulkCostCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Bulk Pack Cost (₱)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _matYieldPiecesCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Yield Quantity (Total Units)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
                        onPressed: _calculateUnitMaterialCost,
                        child: const Text('Calculate Cost per Piece', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Unit Cost per Piece:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            Text('₱ ${widget.formatCurrency(_computedCostPerPiece)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1. Materials Cost', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    widget.materialsInventory.isEmpty
                        ? const Text('No inventory materials available.', style: TextStyle(fontSize: 12, color: Colors.grey))
                        : Wrap(
                            spacing: 8,
                            children: widget.materialsInventory.map((mat) {
                              return ActionChip(
                                avatar: const Icon(Icons.add, size: 14, color: Color(0xFF059669)),
                                label: Text('${mat.name} (₱${widget.formatCurrency(mat.price)})'),
                                onPressed: () {
                                  setState(() => _selectedMaterials.add(SelectedCostingMaterial(material: mat)));
                                  _recalculateProductCost();
                                },
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 12),
                    if (_selectedMaterials.isNotEmpty) ...[
                      ..._selectedMaterials.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        return Row(
                          children: [
                            Expanded(child: Text(item.material.name, style: const TextStyle(fontSize: 12))),
                            Text('₱${widget.formatCurrency(item.material.price)} x ', style: const TextStyle(fontSize: 12)),
                            SizedBox(
                              width: 40,
                              height: 30,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                controller: TextEditingController(text: '${item.quantity}'),
                                onChanged: (val) {
                                  item.quantity = int.tryParse(val) ?? 1;
                                  _recalculateProductCost();
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16, color: Colors.red),
                              onPressed: () {
                                setState(() => _selectedMaterials.removeAt(idx));
                                _recalculateProductCost();
                              },
                            ),
                          ],
                        );
                      }),
                    ],
                    const Divider(height: 24),
                    const Text('2. Labor & Overhead Costing', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<LaborFormulaMode>(
                      value: _laborFormulaMode,
                      decoration: const InputDecoration(labelText: 'Labor Basis', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: LaborFormulaMode.perHour, child: Text('Rate Per Hour')),
                        DropdownMenuItem(value: LaborFormulaMode.perMinute, child: Text('Rate Per Minute')),
                        DropdownMenuItem(value: LaborFormulaMode.flatRate, child: Text('Flat Labor Fee')),
                      ],
                      onChanged: (mode) {
                        if (mode != null) {
                          setState(() => _laborFormulaMode = mode);
                          _recalculateProductCost();
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _laborRateCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => _recalculateProductCost(),
                            decoration: const InputDecoration(labelText: 'Rate Amount (₱)', border: OutlineInputBorder()),
                          ),
                        ),
                        if (_laborFormulaMode != LaborFormulaMode.flatRate) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _laborTimeCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (_) => _recalculateProductCost(),
                              decoration: const InputDecoration(labelText: 'Time (Mins)', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _overheadCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => _recalculateProductCost(),
                      decoration: const InputDecoration(labelText: 'Overhead Cost (₱)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Estimated Product Cost:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            Text('₱ ${widget.formatCurrency(_computedTotalProductCost)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
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
      ],
    );
  }
}