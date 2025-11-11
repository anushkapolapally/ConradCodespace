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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Data Map'), backgroundColor: Colors.teal[700]),
      body: const HtmlMapWidget(),
    );
  }
}

class HtmlMapWidget extends StatelessWidget {
  const HtmlMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height - 100,
        color: Colors.grey[200],
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.teal, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(Icons.map, size: 80, color: Colors.teal),
                      const SizedBox(height: 20),
                      Text(
                        'Interactive Map',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Water Quality Locations',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildLocationTile(
                              'Location 1',
                              '45.2 PPL',
                              'Good',
                              Colors.green,
                            ),
                            const SizedBox(height: 12),
                            _buildLocationTile(
                              'Location 2',
                              '67.8 PPL',
                              'Moderate',
                              Colors.yellow,
                            ),
                            const SizedBox(height: 12),
                            _buildLocationTile(
                              'Location 3',
                              '89.5 PPL',
                              'High',
                              Colors.red,
                            ),
                            const SizedBox(height: 12),
                            _buildLocationTile(
                              'Location 4',
                              '38.1 PPL',
                              'Good',
                              Colors.green,
                            ),
                            const SizedBox(height: 12),
                            _buildLocationTile(
                              'Location 5',
                              '72.3 PPL',
                              'Elevated',
                              Colors.orange,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Leaflet.js Map',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'CDN: https://unpkg.com/leaflet@1.9.4/dist/leaflet.js',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationTile(
    String title,
    String ppl,
    String status,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ppl,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: statusColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
