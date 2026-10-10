import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

// ========== نموذج التذكرة ==========
class Ticket {
  final String from, to, price, seatNumber, passengerName, bookingRef;
  Ticket({
    required this.from,
    required this.to,
    required this.price,
    required this.seatNumber,
    required this.passengerName,
    required this.bookingRef,
  });

  factory Ticket.fromFirestore(Map<String, dynamic> data) => Ticket(
        from: data['from'] ?? '',
        to: data['to'] ?? '',
        price: data['price'] ?? '',
        seatNumber: data['seatNumber']?.toString() ?? '',
        passengerName: data['passengerName'] ?? '',
        bookingRef: data['bookingRef'] ?? '',
      );
}

// ========== التطبيق الرئيسي ==========
class SafrniApp extends StatelessWidget {
  const SafrniApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حدباي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00897B),
          primary: const Color(0xFF00897B),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF00897B), width: 2),
          ),
        ),
      ),
      home: AuthScreen(),
    );
  }
}

// ========== شاشة البداية ==========
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
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MainScreen()));
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
            builder: (_, v, c) =>
                Transform.translate(offset: Offset(v, 0), child: c),
            child: Image.asset('assets/bus.png',
                width: 150,
                height: 150,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.directions_bus,
                    size: 120,
                    color: Colors.white)),
          ),
          const SizedBox(height: 20),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (_, v, c) => Opacity(opacity: v, child: c),
            child: const Text('حدباي',
                style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2)),
          ),
          const SizedBox(height: 10),
          const Text('HADBAY BUS',
              style: TextStyle(
                  fontSize: 16, color: Colors.white70, letterSpacing: 4)),
        ]),
      ),
    );
  }
}

// ========== شاشة التنقل الرئيسية ==========
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const MyTicketsScreen(),
      const Center(child: Text('حسابي - قريباً')),
    
    ];
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.confirmation_number), label: 'تذكرتي'),
          NavigationDestination(icon: Icon(Icons.person), label: 'حسابي'),
         
        ],
      ),
    );
  }
}

// ========== شاشة البحث ==========
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _firebaseRoutes = [];
  bool _isLoadingRoutes = false;
  String? _selectedFrom, _selectedTo;
  DateTime? _selectedDate;
  bool _hasSearched = false;

  void _searchRoutes() async {
    setState(() {
      _hasSearched = true;
      _isLoadingRoutes = true;
    });

    try {
      Query query = FirebaseFirestore.instance.collection('routes');

      if (_selectedFrom != null) {
        query = query.where('from', isEqualTo: _selectedFrom);
      }
      if (_selectedTo != null) {
        query = query.where('to', isEqualTo: _selectedTo);
      }

      final snapshot = await query.get();

      if (!mounted) return;
      setState(() {
        _firebaseRoutes = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'from': data['from'] ?? '',
            'to': data['to'] ?? '',
            'price': data['price'] ?? '',
            'time': data['time'] ?? '',
            'company': data['company'] ?? 'حدباي',
            'rating': data['rating'] ?? '4.8',
            'departure': data['departure'] ?? '',
          };
        }).toList();
        _isLoadingRoutes = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingRoutes = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في جلب الرحلات: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cities = ['سواكن','الميناءالبري الخرطوم', 'بورتسودان','كسلا', 'شندي', 'الخرطوم بحري', 'عطبرة', 'أمدرمان'];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Image.asset('assets/logo.png', width: 50, height: 50,
                        errorBuilder: (_, __, ___) => const Icon(Icons.directions_bus, color: Color(0xFF00897B), size: 50)),
                    const SizedBox(width: 10),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                      Text('أهلاً بك 👋', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text('إلى أين تريد السفر؟', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00897B))),
                    ]),
                  ]),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
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
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) setState(() => _selectedDate = picked);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'تاريخ السفر', prefixIcon: Icon(Icons.calendar_today)),
                          child: Text(_selectedDate == null ? 'اختر التاريخ' : '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _searchRoutes,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00897B),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('بحث عن الرحلات', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ]),
                  ),
                  if (_hasSearched) ...[
                    const SizedBox(height: 20),
                    const Text('الرحلات المتاحة',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00897B))),
                    const SizedBox(height: 10),
                    if (_isLoadingRoutes)
                      const Center(child: CircularProgressIndicator())
                    else if (_firebaseRoutes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                            child: Text('عذراً، لا توجد رحلات',
                                style: TextStyle(color: Colors.red))),
                      )
                    else
                      ..._firebaseRoutes.map((r) => _buildRouteCard(r)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // تم إصلاح النوع ليكون Map<String, dynamic>
  Widget _buildRouteCard(Map<String, dynamic> route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            const Icon(Icons.directions_bus, color: Color(0xFF00897B)),
            const SizedBox(width: 8),
            Text(route['company'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
          ]),
          Row(children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            Text(route['rating'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))
          ]),
        ]),
        const Divider(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${route['from']} ➔ ${route['to']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF00897B))),
            Text(route['time'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(route['departure'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            Text(route['price'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ]),
        ]),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(from: route['from'] ?? '', to: route['to'] ?? '', price: route['price'] ?? ''))),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00897B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('احجز الآن', style: TextStyle(color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}

// ========== شاشة اختيار المقاعد (51 مقعد) ==========
class BookingScreen extends StatefulWidget {
  final String from, to, price;
  const BookingScreen({super.key, required this.from, required this.to, required this.price});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int? _selectedSeat;
  List<int> _bookedSeats = [];
  bool _isLoadingSeats = true;

  final List<List<int?>> seatsLayout = _generateSeatsLayout();

  static List<List<int?>> _generateSeatsLayout() {
    List<List<int?>> layout = [];
    int seatNum = 1;
    for (int i = 0; i < 12; i++) {
      layout.add([seatNum, seatNum + 1, null, seatNum + 3, seatNum + 2]);
      seatNum += 4;
    }
    layout.add([seatNum, seatNum + 1, null, seatNum + 2, null]);
    return layout;
  }

  @override
  void initState() {
    super.initState();
    _loadBookedSeats();
  }

  void _loadBookedSeats() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tickets')
          .where('from', isEqualTo: widget.from)
          .where('to', isEqualTo: widget.to)
          .get();

      final booked = snapshot.docs.map((doc) => int.tryParse(doc.data()['seatNumber'].toString()) ?? 0).toList();

      if (!mounted) return;
      setState(() {
        _bookedSeats = booked;
        _isLoadingSeats = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingSeats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('حجز ${widget.from} ➔ ${widget.to}'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Padding(padding: EdgeInsets.only(right: 20), child: Icon(Icons.sports_motorsports, size: 35, color: Colors.grey)),
                  Text('مقدمة الباص', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  Padding(padding: EdgeInsets.only(left: 20), child: Icon(Icons.door_front_door, size: 35, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _isLoadingSeats
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Center(
                        child: SizedBox(
                          width: 320,
                          child: Column(
                            children: seatsLayout.map((row) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildSeatWidget(row[0]),
                                    const SizedBox(width: 5),
                                    _buildSeatWidget(row[1]),
                                    const SizedBox(width: 20),
                                    row[3] != null ? _buildSeatWidget(row[3]) : const SizedBox(width: 45, height: 55),
                                    const SizedBox(width: 5),
                                    row[4] != null ? _buildSeatWidget(row[4]) : const SizedBox(width: 45, height: 55),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedSeat == null
                    ? null
                    : () => Navigator.push(context, MaterialPageRoute(builder: (_) => PassengerDetailsScreen(from: widget.from, to: widget.to, price: widget.price, seatNumber: _selectedSeat!))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedSeat == null ? Colors.grey : const Color(0xFF00897B),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _selectedSeat == null ? 'الرجاء اختيار مقعد' : 'تأكيد حجز المقعد $_selectedSeat',
                  style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatWidget(int? seatNumber) {
    if (seatNumber == null) return const SizedBox(width: 45, height: 55);

    final isBooked = _bookedSeats.contains(seatNumber);
    final isSelected = _selectedSeat == seatNumber;

    return GestureDetector(
      onTap: isBooked ? null : () => setState(() => _selectedSeat = seatNumber),
      child: Container(
        width: 45,
        height: 55,
        decoration: BoxDecoration(
          color: isBooked ? Colors.grey[300] : (isSelected ? const Color(0xFF00897B) : Colors.white),
          border: Border.all(color: isBooked ? Colors.grey[400]! : (isSelected ? const Color(0xFF00897B) : Colors.grey[400]!), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_seat, size: 18, color: isBooked ? Colors.grey[600] : (isSelected ? Colors.white : const Color(0xFF00897B))),
              const SizedBox(height: 2),
              Text('$seatNumber', style: TextStyle(color: isBooked ? Colors.grey[600] : (isSelected ? Colors.white : Colors.black), fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== شاشة بيانات الركاب ==========
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
        'passengerPhone': _phone.text,
        'bookingRef': ref, 'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => TicketScreen(ticket: Ticket(
              from: widget.from, to: widget.to, price: widget.price,
              seatNumber: widget.seatNumber.toString(), passengerName: _name.text, bookingRef: ref))));
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('بيانات الركاب'), backgroundColor: const Color(0xFF00897B), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'الاسم بالكامل', prefixIcon: Icon(Icons.person)),
              validator: (v) => v!.isEmpty ? 'أدخل الاسم' : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'رقم الهاتف', prefixIcon: Icon(Icons.phone)),
              validator: (v) {
                if (v == null || v.isEmpty) return 'أدخل رقم الهاتف';
                if (v.length < 10) return 'رقم الهاتف يجب أن يكون 10 أرقام على الأقل';
                return null;
              },
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _book,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00897B), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('تأكيد الحجز', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ========== شاشة التذكرة ==========
class TicketScreen extends StatelessWidget {
  final Ticket ticket;
  const TicketScreen({super.key, required this.ticket});
  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF00897B);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 10),
                const Text('تم تأكيد الحجز!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))]),
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainScreen()), (_) => false),
                    style: ElevatedButton.styleFrom(backgroundColor: teal, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('العودة للرئيسية', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ========== شاشة تذاكري (محمية برقم الهاتف) ==========
class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});
  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  final _phoneController = TextEditingController();
  String? _searchedPhone;

  void _searchMyTickets() {
    // إخفاء لوحة المفاتيح
    FocusScope.of(context).unfocus();

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم الهاتف')),
      );
      return;
    }
    
    setState(() {
      _searchedPhone = _phoneController.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تذكرتي'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
      ),
      body: _searchedPhone == null
          ? _buildPhoneInput()
          : _buildTicketsList(),
    );
  }

  // واجهة إدخال رقم الهاتف
  Widget _buildPhoneInput() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.confirmation_number, size: 80, color: Color(0xFF00897B)),
          const SizedBox(height: 20),
          const Text(
            'لعرض تذاكرك، أدخل رقم الهاتف الذي حجزت به',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 25),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف',
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _searchMyTickets,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('عرض تذكرتي',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  // واجهة عرض التذاكر
  Widget _buildTicketsList() {
    return Column(
      children: [
        // شريط علوي لعرض رقم الهاتف وإمكانية تغييره
        Container(
          padding: const EdgeInsets.all(12),
          color: const Color(0xFF00897B).withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('رقم الهاتف: $_searchedPhone',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _searchedPhone = null;
                    _phoneController.clear();
                  });
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('تغيير'),
              ),
            ],
          ),
        ),
        // قائمة التذاكر
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tickets')
                .where('passengerPhone', isEqualTo: _searchedPhone)
                .snapshots(),
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'لا توجد تذاكر مسجلة برقم الهاتف هذا',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                );
              }
              
              final tickets = snap.data!.docs.toList();
              tickets.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                final aTime = aData['createdAt'] as Timestamp?;
                final bTime = bData['createdAt'] as Timestamp?;
                if (aTime == null || bTime == null) return 0;
                return bTime.compareTo(aTime);
              });

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tickets.length,
                itemBuilder: (_, i) {
                  final t = Ticket.fromFirestore(
                      tickets[i].data() as Map<String, dynamic>);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const Icon(Icons.confirmation_number,
                          color: Color(0xFF00897B), size: 35),
                      title: Text('${t.from} ➔ ${t.to}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          'الراكب: ${t.passengerName}\nالمقعد: ${t.seatNumber} | السعر: ${t.price}'),
                      trailing: const Icon(Icons.qr_code),
                      isThreeLine: true,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => TicketScreen(ticket: t))),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
// ========== لوحة التحكم - شاشة الدخول ==========
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _passController = TextEditingController();
  String _error = '';

  void _login() {
    if (_passController.text == 'admin123') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
    } else {
      setState(() {
        _error = 'كلمة المرور غير صحيحة';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل دخول الإدارة'), backgroundColor: const Color(0xFF00897B), foregroundColor: Colors.white),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings, size: 80, color: Color(0xFF00897B)),
              const SizedBox(height: 20),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'كلمة المرور', prefixIcon: const Icon(Icons.lock), errorText: _error.isEmpty ? null : _error),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00897B), padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: const Text('دخول', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== لوحة التحكم - الشاشة الرئيسية ==========
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة التحكم'),
          backgroundColor: const Color(0xFF00897B),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.confirmation_number), text: 'الحجوزات'),
              Tab(icon: Icon(Icons.add_road), text: 'إضافة رحلة'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminBookingsTab(),
            AdminAddRouteTab(),
          ],
        ),
      ),
    );
  }
}

// تبويب عرض الحجوزات
class AdminBookingsTab extends StatelessWidget {
  const AdminBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tickets').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('لا توجد حجوزات حالياً'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text('${data['from']} ➔ ${data['to']}'),
                subtitle: Text('الراكب: ${data['passengerName']} | مقعد: ${data['seatNumber']} | هاتف: ${data['passengerPhone'] ?? 'غير مسجل'}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('إلغاء الحجز'),
                        content: const Text('هل أنت متأكد من حذف هذا الحجز؟'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await FirebaseFirestore.instance.collection('tickets').doc(doc.id).delete();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف الحجز بنجاح')));
                      }
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// تبويب إضافة رحلة جديدة
class AdminAddRouteTab extends StatefulWidget {
  const AdminAddRouteTab({super.key});

  @override
  State<AdminAddRouteTab> createState() => _AdminAddRouteTabState();
}

class _AdminAddRouteTabState extends State<AdminAddRouteTab> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _priceController = TextEditingController();
  final _timeController = TextEditingController();
  final _departureController = TextEditingController();
  bool _isLoading = false;

  void _addRoute() async {
    if (_fromController.text.isEmpty || _toController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('routes').add({
        'from': _fromController.text,
        'to': _toController.text,
        'price': _priceController.text,
        'time': _timeController.text,
        'departure': _departureController.text,
        'company': 'حدباي',
        'rating': '4.8',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة الرحلة بنجاح!')));
        _fromController.clear();
        _toController.clear();
        _priceController.clear();
        _timeController.clear();
        _departureController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(controller: _fromController, decoration: const InputDecoration(labelText: 'من مدينة', prefixIcon: Icon(Icons.location_on))),
          const SizedBox(height: 15),
          TextField(controller: _toController, decoration: const InputDecoration(labelText: 'إلى مدينة', prefixIcon: Icon(Icons.location_on_outlined))),
          const SizedBox(height: 15),
          TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر', prefixIcon: Icon(Icons.attach_money))),
          const SizedBox(height: 15),
          TextField(controller: _timeController, decoration: const InputDecoration(labelText: 'مدة الرحلة (مثال: 5 ساعات)', prefixIcon: Icon(Icons.timer))),
          const SizedBox(height: 15),
          TextField(controller: _departureController, decoration: const InputDecoration(labelText: 'وقت المغادرة (مثال: 08:00 ص)', prefixIcon: Icon(Icons.access_time))),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _addRoute,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00897B), padding: const EdgeInsets.symmetric(vertical: 15)),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('إضافة الرحلة', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
// ========== شاشة تسجيل الدخول/التسجيل للعملاء ==========
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  void _submit() async {
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_bus, size: 80, color: Color(0xFF00897B)),
              const SizedBox(height: 20),
              Text(_isLogin ? 'تسجيل الدخول' : 'حساب جديد', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email))),
              const SizedBox(height: 15),
              TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور', prefixIcon: Icon(Icons.lock))),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00897B), padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(_isLogin ? 'دخول' : 'تسجيل', style: const TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin ? 'ليس لديك حساب؟ سجل الآن' : 'لديك حساب؟ سجل دخول'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
