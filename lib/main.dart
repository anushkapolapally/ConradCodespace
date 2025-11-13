import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
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
                  _buildButton(context, Icons.shopping_cart_outlined,
                      'Recommendations', const RecommendationsPage(pplLevel: 67.77)),
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
        child: Center(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 6,
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.network(
                    'https://www.svgrepo.com/show/527288/water.svg',
                    height: 100,
                    colorFilter:
                        const ColorFilter.mode(Colors.teal, BlendMode.srcIn),
                  ),
                  const SizedBox(height: 16),
                  const Text('67.77 PPL Detected',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('Safe for consumption but not ideal',
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text('High for your area',
                      style: TextStyle(fontSize: 18, color: Colors.redAccent)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RecommendationsPage(pplLevel: pplLevel),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('View Recommended Filters'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
        description: 'Removes chlorine, mercury, copper, and microplastics. Perfect for moderate PPL levels.',
        price: 24.99,
        imageUrl: 'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8?w=400',
        buyUrl: 'https://www.amazon.com/s?k=brita+water+filter+pitcher',
        filterType: 'Pitcher Filter',
        effectiveness: 65.0,
      ),
      WaterFilterProduct(
        name: 'ZeroWater 10-Cup Pitcher',
        description: 'Advanced 5-stage filtration removes 99.6% of dissolved solids including microplastics.',
        price: 39.99,
        imageUrl: 'https://images.unsplash.com/photo-1582719366274-fe1cb6a74c9e?w=400',
        buyUrl: 'https://www.amazon.com/s?k=zerowater+pitcher',
        filterType: '5-Stage Filter',
        effectiveness: 95.0,
      ),
      WaterFilterProduct(
        name: 'PUR Faucet Water Filtration System',
        description: 'Attaches directly to faucet. Reduces 70+ contaminants including microplastics.',
        price: 34.99,
        imageUrl: 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=400',
        buyUrl: 'https://www.amazon.com/s?k=pur+faucet+filter',
        filterType: 'Faucet Mount',
        effectiveness: 80.0,
      ),
      WaterFilterProduct(
        name: 'Aquasana Under Sink Filter',
        description: 'Professional-grade filtration removes 99% of microplastics, PFAS, and heavy metals.',
        price: 149.99,
        imageUrl: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400',
        buyUrl: 'https://www.amazon.com/s?k=aquasana+under+sink+filter',
        filterType: 'Under-Sink System',
        effectiveness: 99.0,
      ),
      WaterFilterProduct(
        name: 'APEC Reverse Osmosis System',
        description: 'Ultimate protection: 5-stage RO system removes virtually all contaminants including microplastics.',
        price: 229.99,
        imageUrl: 'https://images.unsplash.com/photo-1604754742629-3e5728249d73?w=400',
        buyUrl: 'https://www.amazon.com/s?k=apec+reverse+osmosis',
        filterType: 'Reverse Osmosis',
        effectiveness: 99.9,
      ),
      WaterFilterProduct(
        name: 'LifeStraw Home Water Pitcher',
        description: 'Removes bacteria, parasites, microplastics, and improves taste. Great for everyday use.',
        price: 44.95,
        imageUrl: 'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=400',
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
      recommended = allProducts.where((p) => p.effectiveness >= 65 && p.effectiveness < 95).toList();
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
                                          onPressed: () => _launchUrl(product.buyUrl),
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
  double _offsetX = 0;
  double _offsetY = 0;
  double _scale = 1.0;
  int? _selectedMarker;
  
  // Sample water quality data points with markers
  final List<MapMarker> _markers = [
    MapMarker(
      id: 1,
      x: 200,
      y: 150,
      title: 'Location 1',
      ppl: 45.2,
      status: 'Good',
      color: Colors.green,
    ),
    MapMarker(
      id: 2,
      x: 350,
      y: 200,
      title: 'Location 2',
      ppl: 67.8,
      status: 'Moderate',
      color: Colors.yellow,
    ),
    MapMarker(
      id: 3,
      x: 150,
      y: 300,
      title: 'Location 3',
      ppl: 89.5,
      status: 'High',
      color: Colors.red,
    ),
    MapMarker(
      id: 4,
      x: 400,
      y: 350,
      title: 'Location 4',
      ppl: 38.1,
      status: 'Good',
      color: Colors.green,
    ),
    MapMarker(
      id: 5,
      x: 280,
      y: 450,
      title: 'Location 5',
      ppl: 72.3,
      status: 'Elevated',
      color: Colors.orange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Map'),
        backgroundColor: Colors.teal[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Legend'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.green),
                          SizedBox(width: 10),
                          Text('Good (< 50 PPL)'),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.yellow),
                          SizedBox(width: 10),
                          Text('Moderate (50-70 PPL)'),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.orange),
                          SizedBox(width: 10),
                          Text('Elevated (70-80 PPL)'),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red),
                          SizedBox(width: 10),
                          Text('High (> 80 PPL)'),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _offsetX += details.delta.dx;
                _offsetY += details.delta.dy;
              });
            },
            onScaleUpdate: (details) {
              setState(() {
                _scale = (_scale * details.scale).clamp(0.5, 3.0);
              });
            },
            child: Container(
              color: Colors.grey[200],
              child: CustomPaint(
                painter: MapPainter(
                  offsetX: _offsetX,
                  offsetY: _offsetY,
                  scale: _scale,
                  markers: _markers,
                  selectedMarker: _selectedMarker,
                ),
                child: Container(),
              ),
            ),
          ),
          // Marker tap detection
          ...(_markers.map((marker) {
            final screenX = marker.x * _scale + _offsetX;
            final screenY = marker.y * _scale + _offsetY;
            
            return Positioned(
              left: screenX - 20,
              top: screenY - 40,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMarker = marker.id;
                  });
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(marker.title),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PPL: ${marker.ppl}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Status: ${marker.status}', style: TextStyle(color: marker.color, fontSize: 16)),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _selectedMarker = null;
                            });
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  color: Colors.transparent,
                ),
              ),
            );
          }).toList()),
          // Zoom controls
          Positioned(
            right: 20,
            bottom: 100,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoom_in',
                  backgroundColor: Colors.teal,
                  onPressed: () {
                    setState(() {
                      _scale = (_scale * 1.2).clamp(0.5, 3.0);
                    });
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoom_out',
                  backgroundColor: Colors.teal,
                  onPressed: () {
                    setState(() {
                      _scale = (_scale / 1.2).clamp(0.5, 3.0);
                    });
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
          // Instructions
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Text(
                'Drag to pan • Pinch to zoom • Tap pins for info',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MapMarker {
  final int id;
  final double x;
  final double y;
  final String title;
  final double ppl;
  final String status;
  final Color color;

  MapMarker({
    required this.id,
    required this.x,
    required this.y,
    required this.title,
    required this.ppl,
    required this.status,
    required this.color,
  });
}

class MapPainter extends CustomPainter {
  final double offsetX;
  final double offsetY;
  final double scale;
  final List<MapMarker> markers;
  final int? selectedMarker;

  MapPainter({
    required this.offsetX,
    required this.offsetY,
    required this.scale,
    required this.markers,
    this.selectedMarker,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid background to simulate map
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    final gridSize = 50.0 * scale;
    
    // Vertical lines
    for (double x = (offsetX % gridSize); x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // Horizontal lines
    for (double y = (offsetY % gridSize); y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Draw some "roads" to make it look more map-like
    final roadPaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 4 * scale;

    // Horizontal road
    canvas.drawLine(
      Offset(0, 250 * scale + offsetY),
      Offset(size.width, 250 * scale + offsetY),
      roadPaint,
    );

    // Vertical road
    canvas.drawLine(
      Offset(300 * scale + offsetX, 0),
      Offset(300 * scale + offsetX, size.height),
      roadPaint,
    );

    // Draw some "buildings" (rectangles)
    final buildingPaint = Paint()..color = Colors.grey[350]!;
    
    final buildings = [
      Rect.fromLTWH(100, 100, 80, 60),
      Rect.fromLTWH(350, 150, 60, 70),
      Rect.fromLTWH(200, 350, 90, 80),
      Rect.fromLTWH(450, 250, 70, 90),
    ];

    for (final building in buildings) {
      final transformed = Rect.fromLTWH(
        building.left * scale + offsetX,
        building.top * scale + offsetY,
        building.width * scale,
        building.height * scale,
      );
      canvas.drawRect(transformed, buildingPaint);
    }

    // Draw markers
    for (final marker in markers) {
      final x = marker.x * scale + offsetX;
      final y = marker.y * scale + offsetY;

      // Only draw if visible on screen
      if (x > -50 && x < size.width + 50 && y > -50 && y < size.height + 50) {
        // Pin shadow
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        
        canvas.drawCircle(
          Offset(x, y + 2),
          12 * scale,
          shadowPaint,
        );

        // Pin circle
        final pinPaint = Paint()..color = marker.color;
        canvas.drawCircle(
          Offset(x, y),
          12 * scale,
          pinPaint,
        );

        // Pin border
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * scale;
        canvas.drawCircle(
          Offset(x, y),
          12 * scale,
          borderPaint,
        );

        // Pin pointer
        final path = Path();
        path.moveTo(x, y + 12 * scale);
        path.lineTo(x - 6 * scale, y + 20 * scale);
        path.lineTo(x + 6 * scale, y + 20 * scale);
        path.close();
        canvas.drawPath(path, pinPaint);

        // Highlight selected marker
        if (selectedMarker == marker.id) {
          final highlightPaint = Paint()
            ..color = Colors.blue.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3 * scale;
          canvas.drawCircle(
            Offset(x, y),
            18 * scale,
            highlightPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(MapPainter oldDelegate) {
    return oldDelegate.offsetX != offsetX ||
        oldDelegate.offsetY != offsetY ||
        oldDelegate.scale != scale ||
        oldDelegate.selectedMarker != selectedMarker;
  }
}