import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCCQxnJ1h8XGB4cS377x0QkSPLGRPCQz_4",
      authDomain: "safrni-70d71.firebaseapp.com",
      projectId: "safrni-70d71",
      storageBucket: "safrni-70d71.firebasestorage.app",
      messagingSenderId: "684047874573",
      appId: "1:684047874573:web:f343aa26020398c9cdf344",
    ),
  );
  runApp(const SafrniApp());
}

class Ticket {
  final String from, to, price, seatNumber, passengerName, bookingRef;
  Ticket({required this.from, required this.to, required this.price, required this.seatNumber, required this.passengerName, required this.bookingRef});
  factory Ticket.fromFirestore(Map<String, dynamic> data) => Ticket(
    from: data['from'] ?? '', to: data['to'] ?? '', price: data['price'] ?? '',
    seatNumber: data['seatNumber']?.toString() ?? '',
    passengerName: data['passengerName'] ?? '', bookingRef: data['bookingRef'] ?? '',
  );
}

class SafrniApp extends StatelessWidget {
  const SafrniApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safrni',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00897B), primary: const Color(0xFF00897B)),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00897B), width: 2)),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00897B),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: -150.0, end: 0.0),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOut,
            builder: (_, v, c) => Transform.translate(offset: Offset(v, 0), child: c),
            child: const Icon(Icons.directions_bus, size: 120, color: Colors.white),
          ),
          const SizedBox(height: 20),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (_, v, c) => Opacity(opacity: v, child: c),
            child: const Text('حدباي', style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
          ),
          const SizedBox(height: 10),
          const Text('HADBAY BUS', style: TextStyle(fontSize: 16, color: Colors.white70, letterSpacing: 4)),
        ]),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final screens = [const HomeScreen(), const MyTicketsScreen(), const Center(child: Text('حسابي - قريباً'))];
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.confirmation_number), label: 'تذاكري'),
          NavigationDestination(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> _allRoutes = [
    {'from': 'الخرطوم', 'to': 'القاهرة', 'price': '150 ج.س', 'time': '3 ساعات', 'company': 'حدباي', 'rating': '4.8', 'departure': '08:00 ص'},
    {'from': 'الخرطوم', 'to': 'أسوان', 'price': '350 ج.س', 'time': '12 ساعة', 'company': 'حدباي', 'rating': '4.5', 'departure': '10:00 م'},
    {'from': 'بورتسودان', 'to': 'الخرطوم', 'price': '250 ج.س', 'time': '6 ساعات', 'company': 'حدباي', 'rating': '4.9', 'departure': '11:30 م'},
  ];
  List<Map<String, String>> _filteredRoutes = [];
  String? _selectedFrom, _selectedTo;
  bool _hasSearched = false;

  void _searchRoutes() {
    setState(() {
      _hasSearched = true;
      _filteredRoutes = _allRoutes.where((r) {
        return (_selectedFrom == null || r['from'] == _selectedFrom) && (_selectedTo == null || r['to'] == _selectedTo);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cities = ['الخرطوم', 'بورتسودان', 'شندي', 'القاهرة', 'الإسكندرية', 'أسوان'];
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                    Text('أهلاً بك 👋', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    Text('إلى أين تريد السفر؟', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00897B))),
                  ]),
                  const CircleAvatar(radius: 22, backgroundColor: Color(0xFF00897B), child: Icon(Icons.notifications, color: Colors.white)),
                ]),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
                  child: Column(children: [
                    DropdownButtonFormField<String>(
                      value: _selectedFrom,
                      decoration: const InputDecoration(labelText: 'من مدينة', prefixIcon: Icon(Icons.location_on)),
                      items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _selectedFrom = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedTo,
                      decoration: const InputDecoration(labelText: 'إلى مدينة', prefixIcon: Icon(Icons.location_on_outlined)),
                      items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _selectedTo = v),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(width: double.infinity, child: ElevatedButton(
                      onPressed: _searchRoutes,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00897B), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('بحث عن الرحلات', style: TextStyle(fontSize: 18, color: Colors.white)),
                    )),
                  ]),
                ),
                if (_hasSearched) ...[
                  const SizedBox(height: 20),
                  const Text('الرحلات المتاحة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00897B))),
                  const SizedBox(height: 10),
                  ..._filteredRoutes.map((r) => _buildRouteCard(r)),
                ],
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteCard(Map<String, String> route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [const Icon(Icons.directions_bus, color: Color(0xFF00897B)), const SizedBox(width: 8), Text(route['company']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
          Row(children: [const Icon(Icons.star, color: Colors.amber, size: 18), Text(route['rating']!, style: const TextStyle(fontWeight: FontWeight.bold))]),
        ]),
        const Divider(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${route['from']} ➔ ${route['to']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF00897B))),
            Text(route['time']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(route['departure']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            Text(route['price']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ]),
        ]),
        const SizedBox(height: 15),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(from: route['from']!, to: route['to']!, price: route['price']!))),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00897B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text('احجز الآن', style: TextStyle(color: Colors.white)),
        )),
      ]),
    );
  }
}

class BookingScreen extends StatefulWidget {
  final String from, to, price;
  const BookingScreen({super.key, required this.from, required this.to, required this.price});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int? _selectedSeat;
  final _booked = [1, 5, 9, 12, 15, 20];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('حجز ${widget.from} ➔ ${widget.to}'), backgroundColor: const Color(0xFF00897B), foregroundColor: Colors.white),
      body: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFF00897B), borderRadius: BorderRadius.circular(15)), child: Column(children: [Text('السعر: ${widget.price}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)), Text('${widget.from} ➔ ${widget.to}', style: const TextStyle(color: Colors.white))])),
        const SizedBox(height: 20),
        const Text('اختر مقعدك:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Expanded(child: Center(child: SizedBox(width: 350, child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1),
          itemCount: 50,
          itemBuilder: (_, i) {
            final n = i + 1;
            final booked = _booked.contains(n);
            final sel = _selectedSeat == n;
            return GestureDetector(
              onTap: booked ? null : () => setState(() => _selectedSeat = n),
              child: Container(
                decoration: BoxDecoration(color: booked ? Colors.grey[300] : (sel ? const Color(0xFF00897B) : Colors.white), border: Border.all(color: const Color(0xFF00897B), width: 2), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text('$n', style: TextStyle(color: sel ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
              ),
            );
          },
        )))),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: _selectedSeat == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => PassengerDetailsScreen(from: widget.from, to: widget.to, price: widget.price, seatNumber: _selectedSeat!))),
          style: ElevatedButton.styleFrom(backgroundColor: _selectedSeat == null ? Colors.grey : const Color(0xFF00897B), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text(_selectedSeat == null ? 'الرجاء اختيار مقعد' : 'تأكيد حجز المقعد $_selectedSeat', style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
        )),
      ])),
    );
  }
}

class PassengerDetailsScreen extends StatefulWidget {
  final String from, to, price;
  final int seatNumber;
  const PassengerDetailsScreen({super.key, required this.from, required this.to, required this.price, required this.seatNumber});
  @override
  State<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  bool _loading = false;

  void _book() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final ref = 'BS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    try {
      await FirebaseFirestore.instance.collection('tickets').add({
        'from': widget.from, 'to': widget.to, 'price': widget.price,
        'seatNumber': widget.seatNumber, 'passengerName': _name.text,
        'bookingRef': ref, 'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TicketScreen(ticket: Ticket(
        from: widget.from, to: widget.to, price: widget.price,
        seatNumber: widget.seatNumber.toString(), passengerName: _name.text, bookingRef: ref,
      ))));
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('بيانات الركاب'), backgroundColor: const Color(0xFF00897B), foregroundColor: Colors.white),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'الاسم بالكامل', prefixIcon: Icon(Icons.person)), validator: (v) => v!.isEmpty ? 'أدخل الاسم' : null),
        const SizedBox(height: 15),
        TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الهاتف', prefixIcon: Icon(Icons.phone)), validator: (v) => v!.length < 11 ? 'رقم غير صحيح' : null),
        const SizedBox(height: 25),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: _loading ? null : _book,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00897B), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('تأكيد الحجز', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
        )),
      ]))),
    );
  }
}

class TicketScreen extends StatelessWidget {
  final Ticket ticket;
  const TicketScreen({super.key, required this.ticket});
  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF00897B);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 450), child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 60),
        const SizedBox(height: 10),
        const Text('تم تأكيد الحجز!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
        const SizedBox(height: 20),
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))]),
          child: Column(children: [
            Text(ticket.bookingRef, style: const TextStyle(color: teal, fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 1.5)),
            const Divider(height: 30),
            Text('${ticket.from} ➔ ${ticket.to}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text('الاسم: ${ticket.passengerName}'),
            Text('المقعد: ${ticket.seatNumber} | السعر: ${ticket.price}'),
          ]),
        ),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainScreen()), (_) => false),
          style: ElevatedButton.styleFrom(backgroundColor: teal, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text('العودة للرئيسية', style: TextStyle(fontSize: 16, color: Colors.white)),
        )),
      ]))))),
    );
  }
}

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تذاكري'), backgroundColor: const Color(0xFF00897B), foregroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tickets').orderBy('createdAt', descending: true).snapshots(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snap.hasData || snap.data!.docs.isEmpty) return const Center(child: Text('لا توجد تذاكر'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snap.data!.docs.length,
            itemBuilder: (_, i) {
              final t = Ticket.fromFirestore(snap.data!.docs[i].data() as Map<String, dynamic>);
              return Card(child: ListTile(
                title: Text('${t.from} ➔ ${t.to}'),
                subtitle: Text('${t.passengerName} | مقعد ${t.seatNumber}'),
                trailing: const Icon(Icons.qr_code),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TicketScreen(ticket: t))),
              ));
            },
          );
        },
      ),
    );
  }
}