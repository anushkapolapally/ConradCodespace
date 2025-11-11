import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

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
                      'Recommendations', const RecommendationsPage()),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    const url = 'https://fakestoreapi.com/products?limit=5';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Recommendations'),
          backgroundColor: Colors.teal[700]),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('No products available.'))
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE0F2F1), Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(14),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              product['image'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported,
                                      size: 40, color: Colors.grey),
                            ),
                          ),
                          title: Text(
                            product['title'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '\$${product['price']}',
                            style: const TextStyle(
                                color: Colors.teal, fontSize: 16),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Redirecting to buy ${product['title']}...'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Buy'),
                          ),
                        ),
                      );
                    },
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

  final List<MapMarker> _markers = [
    MapMarker(
        id: 1,
        x: 200,
        y: 150,
        title: 'Location 1',
        ppl: 45.2,
        status: 'Good',
        color: Colors.green),
    MapMarker(
        id: 2,
        x: 350,
        y: 200,
        title: 'Location 2',
        ppl: 67.8,
        status: 'Moderate',
        color: Colors.yellow),
    MapMarker(
        id: 3,
        x: 150,
        y: 300,
        title: 'Location 3',
        ppl: 89.5,
        status: 'High',
        color: Colors.red),
    MapMarker(
        id: 4,
        x: 400,
        y: 350,
        title: 'Location 4',
        ppl: 38.1,
        status: 'Good',
        color: Colors.green),
    MapMarker(
        id: 5,
        x: 280,
        y: 450,
        title: 'Location 5',
        ppl: 72.3,
        status: 'Elevated',
        color: Colors.orange),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Data Map'), backgroundColor: Colors.teal[700]),
      body: Stack(
        children: [
          GestureDetector(
            onScaleUpdate: (details) {
              setState(() {
                _scale = (_scale * details.scale).clamp(0.5, 3.0);
                _offsetX += details.focalPointDelta.dx;
                _offsetY += details.focalPointDelta.dy;
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
          ..._markers.map((marker) {
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
                          Text('PPL: ${marker.ppl}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Status: ${marker.status}',
                              style:
                                  TextStyle(color: marker.color, fontSize: 16)),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() => _selectedMarker = null);
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child:
                    Container(width: 40, height: 40, color: Colors.transparent),
              ),
            );
          }).toList(),
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
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;
    final gridSize = 50.0 * scale;

    for (double x = (offsetX % gridSize); x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = (offsetY % gridSize); y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (final marker in markers) {
      final x = marker.x * scale + offsetX;
      final y = marker.y * scale + offsetY;
      final pinPaint = Paint()..color = marker.color;
      canvas.drawCircle(Offset(x, y), 10 * scale, pinPaint);
    }
  }

  @override
  bool shouldRepaint(MapPainter oldDelegate) =>
      oldDelegate.offsetX != offsetX ||
      oldDelegate.offsetY != offsetY ||
      oldDelegate.scale != scale ||
      oldDelegate.selectedMarker != selectedMarker;
}
