import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data_map.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDataService {
  static Future<void> init() async {
    await Firebase.initializeApp();
  }

  static Future<double> fetchPplLevel({double fallback = 67.77}) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('ppl_metrics')
          .doc('latest')
          .get();
      if (doc.exists) {
        final data = doc.data();
        final value = data?['current'];
        if (value is num) return value.toDouble();
      }
    } catch (_) {
      // ignore and return fallback
    }
    return fallback;
  }

  static Future<List<FlSpot>> fetchPplTrend() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('ppl_metrics')
          .doc('latest')
          .get();
      if (doc.exists) {
        final data = doc.data();
        final list = data?['trend'];
        if (list is List) {
          final spots = <FlSpot>[];
          for (var i = 0; i < list.length; i++) {
            final v = list[i];
            if (v is num) spots.add(FlSpot(i.toDouble(), v.toDouble()));
          }
          if (spots.isNotEmpty) return spots;
        }
      }
    } catch (_) {
      // ignore and fall back
    }

    // Default fallback trend (last 7 days)
    return const [
      FlSpot(0, 65.2),
      FlSpot(1, 66.5),
      FlSpot(2, 64.8),
      FlSpot(3, 68.1),
      FlSpot(4, 69.5),
      FlSpot(5, 67.2),
      FlSpot(6, 67.77),
    ];
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Water Quality App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const HomeScreen(username: 'Anushka'),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00796B), Color(0xFF4DB6AC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.network(
                    'https://www.svgrepo.com/show/383020/water-drop.svg',
                    height: 120,
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    'Welcome, $username!',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  _buildButton(context, Icons.analytics, 'Your Data',
                      const YourDataPage()),
                  const SizedBox(height: 20),
                  _buildButton(
                      context,
                      Icons.shopping_cart_outlined,
                      'Recommendations',
                      const RecommendationsPage(pplLevel: 67.77)),
                  const SizedBox(height: 20),
                  _buildButton(context, Icons.map_outlined, 'Data Map',
                      const DataMapPage()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, IconData icon, String label, Widget page) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        width: 260,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.teal, size: 28),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class YourDataPage extends StatelessWidget {
  const YourDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    const double pplLevel = 67.77;

    // Sample data: PPL levels over the past 7 days
    final List<FlSpot> pplTrendData = [
      const FlSpot(0, 65.2),
      const FlSpot(1, 66.5),
      const FlSpot(2, 64.8),
      const FlSpot(3, 68.1),
      const FlSpot(4, 69.5),
      const FlSpot(5, 67.2),
      const FlSpot(6, 67.77),
    ];

    return Scaffold(
      appBar: AppBar(
          title: const Text('Your Data'), backgroundColor: Colors.teal[700]),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F2F1), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Current PPL Level Card
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.network(
                          'https://www.svgrepo.com/show/527288/water.svg',
                          height: 100,
                          colorFilter: const ColorFilter.mode(
                              Colors.teal, BlendMode.srcIn),
                        ),
                        const SizedBox(height: 16),
                        const Text('67.77 PPL Detected',
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text('Safe for consumption but not ideal',
                            style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        const Text('High for your area',
                            style: TextStyle(
                                fontSize: 18, color: Colors.redAccent)),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RecommendationsPage(
                                    pplLevel: pplLevel),
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('View Recommended Filters'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // PPL Trend Chart Card
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16.0, top: 16.0),
                          child: Text(
                            'PPL Level Trend (Last 7 Days)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: true,
                                  horizontalInterval: 5,
                                  verticalInterval: 1,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey[300]!,
                                      strokeWidth: 1,
                                    );
                                  },
                                  getDrawingVerticalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey[300]!,
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: const AxisTitles(),
                                  topTitles: const AxisTitles(),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        const days = [
                                          'Mon',
                                          'Tue',
                                          'Wed',
                                          'Thu',
                                          'Fri',
                                          'Sat',
                                          'Sun'
                                        ];
                                        if (value.toInt() >= 0 &&
                                            value.toInt() < days.length) {
                                          return Text(days[value.toInt()]);
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 10,
                                      reservedSize: 40,
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: true),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: pplTrendData,
                                    isCurved: true,
                                    gradient: const LinearGradient(
                                      colors: [Colors.teal, Colors.tealAccent],
                                    ),
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter:
                                          (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 5,
                                          color: Colors.teal,
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        );
                                      },
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.teal.withValues(alpha: 0.3),
                                          Colors.teal.withValues(alpha: 0.1),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ],
                                minY: 60,
                                maxY: 75,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WaterFilterProduct {
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String buyUrl;
  final String filterType;
  final double effectiveness;

  WaterFilterProduct({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.buyUrl,
    required this.filterType,
    required this.effectiveness,
  });
}

class RecommendationsPage extends StatefulWidget {
  final double pplLevel;

  const RecommendationsPage({super.key, required this.pplLevel});

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  List<WaterFilterProduct> products = [];
  bool isLoading = true;
  String urgencyLevel = '';
  Color urgencyColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _determineUrgency();
    _loadProducts();
  }

  void _determineUrgency() {
    if (widget.pplLevel < 50) {
      urgencyLevel = 'Low Priority';
      urgencyColor = Colors.green;
    } else if (widget.pplLevel < 70) {
      urgencyLevel = 'Moderate - Consider Filtering';
      urgencyColor = Colors.orange;
    } else {
      urgencyLevel = 'High Priority - Filter Recommended';
      urgencyColor = Colors.red;
    }
  }

  Future<void> _loadProducts() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Create curated list of water filter products based on PPL level
    List<WaterFilterProduct> allProducts = [
      WaterFilterProduct(
        name: 'Brita Metro Water Filter Pitcher',
        description:
            'Removes chlorine, mercury, copper, and microplastics. Perfect for moderate PPL levels.',
        price: 24.99,
        imageUrl:
            'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8?w=400',
        buyUrl: 'https://www.amazon.com/s?k=brita+water+filter+pitcher',
        filterType: 'Pitcher Filter',
        effectiveness: 65.0,
      ),
      WaterFilterProduct(
        name: 'ZeroWater 10-Cup Pitcher',
        description:
            'Advanced 5-stage filtration removes 99.6% of dissolved solids including microplastics.',
        price: 39.99,
        imageUrl:
            'https://images.unsplash.com/photo-1582719366274-fe1cb6a74c9e?w=400',
        buyUrl: 'https://www.amazon.com/s?k=zerowater+pitcher',
        filterType: '5-Stage Filter',
        effectiveness: 95.0,
      ),
      WaterFilterProduct(
        name: 'PUR Faucet Water Filtration System',
        description:
            'Attaches directly to faucet. Reduces 70+ contaminants including microplastics.',
        price: 34.99,
        imageUrl:
            'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=400',
        buyUrl: 'https://www.amazon.com/s?k=pur+faucet+filter',
        filterType: 'Faucet Mount',
        effectiveness: 80.0,
      ),
      WaterFilterProduct(
        name: 'Aquasana Under Sink Filter',
        description:
            'Professional-grade filtration removes 99% of microplastics, PFAS, and heavy metals.',
        price: 149.99,
        imageUrl:
            'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400',
        buyUrl: 'https://www.amazon.com/s?k=aquasana+under+sink+filter',
        filterType: 'Under-Sink System',
        effectiveness: 99.0,
      ),
      WaterFilterProduct(
        name: 'APEC Reverse Osmosis System',
        description:
            'Ultimate protection: 5-stage RO system removes virtually all contaminants including microplastics.',
        price: 229.99,
        imageUrl:
            'https://images.unsplash.com/photo-1604754742629-3e5728249d73?w=400',
        buyUrl: 'https://www.amazon.com/s?k=apec+reverse+osmosis',
        filterType: 'Reverse Osmosis',
        effectiveness: 99.9,
      ),
      WaterFilterProduct(
        name: 'LifeStraw Home Water Pitcher',
        description:
            'Removes bacteria, parasites, microplastics, and improves taste. Great for everyday use.',
        price: 44.95,
        imageUrl:
            'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=400',
        buyUrl: 'https://www.amazon.com/s?k=lifestraw+pitcher',
        filterType: 'Advanced Pitcher',
        effectiveness: 75.0,
      ),
    ];

    // Filter products based on PPL level
    List<WaterFilterProduct> recommended = [];

    if (widget.pplLevel < 50) {
      // Low PPL: basic filters sufficient
      recommended = allProducts.where((p) => p.effectiveness < 80).toList();
    } else if (widget.pplLevel < 70) {
      // Moderate PPL: mid-range filters
      recommended = allProducts
          .where((p) => p.effectiveness >= 65 && p.effectiveness < 95)
          .toList();
    } else {
      // High PPL: advanced filters only
      recommended = allProducts.where((p) => p.effectiveness >= 80).toList();
    }

    // Sort by effectiveness (highest first)
    recommended.sort((a, b) => b.effectiveness.compareTo(a.effectiveness));

    setState(() {
      products = recommended.take(5).toList();
      isLoading = false;
    });
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open product link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended Filters'),
        backgroundColor: Colors.teal[700],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE0F2F1), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  // PPL Level Info Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: urgencyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: urgencyColor, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Your PPL Level: ${widget.pplLevel.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          urgencyLevel,
                          style: TextStyle(
                            fontSize: 16,
                            color: urgencyColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'These filters are recommended based on your water quality',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  // Products List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                child: Image.network(
                                  product.imageUrl,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    height: 180,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.filter_alt,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product Name
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Filter Type Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        product.filterType,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.teal,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Description
                                    Text(
                                      product.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Effectiveness Bar
                                    Row(
                                      children: [
                                        const Text(
                                          'Effectiveness: ',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Expanded(
                                          child: LinearProgressIndicator(
                                            value: product.effectiveness / 100,
                                            backgroundColor: Colors.grey[300],
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              product.effectiveness > 90
                                                  ? Colors.green
                                                  : product.effectiveness > 70
                                                      ? Colors.orange
                                                      : Colors.blue,
                                            ),
                                            minHeight: 8,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${product.effectiveness.toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Price and Buy Button
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '\$${product.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal,
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              _launchUrl(product.buyUrl),
                                          icon: const Icon(Icons.shopping_cart),
                                          label: const Text('Buy Now'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class DataMapPage extends StatefulWidget {
  const DataMapPage({super.key});

  @override
  State<DataMapPage> createState() => _DataMapPageState();
}

class _DataMapPageState extends State<DataMapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Map'),
        backgroundColor: Colors.teal[700],
      ),
      body: SafeArea(child: DataMapWidget()),
    );
  }
}
