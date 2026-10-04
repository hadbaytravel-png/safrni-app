import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
  final String from;
  final String to;
  final String price;
  final String seatNumber;
  final String passengerName;
  final String bookingRef;

  Ticket({
    required this.from,
    required this.to,
    required this.price,
    required this.seatNumber,
    required this.passengerName,
    required this.bookingRef,
  });

  factory Ticket.fromFirestore(Map<String, dynamic> data) {
    return Ticket(
      from: data['from'] ?? '',
      to: data['to'] ?? '',
      price: data['price'] ?? '',
      seatNumber: data['seatNumber']?.toString() ?? '',
      passengerName: data['passengerName'] ?? '',
      bookingRef: data['bookingRef'] ?? '',
    );
  }
}

class SafrniApp extends StatelessWidget {
  const SafrniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safrni Premium',
      debugShowCheckedModeBanner: false,
    theme: ThemeData(
  useMaterial3: true,
  -- هذا هو السطر السحري للخط
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF00897B),
    primary: const Color(0xFF00897B),
  ),
),
     home: const Splashscreen(),
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
    final List<Widget> screens = [
      const HomeScreen(),
      const MyTicketsScreen(),
      const Center(child: Text('شاشة حسابي - قادمة قريباً')),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number),
            label: 'تذاكري',
          ),
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
    {
      'from': 'الخرطوم',
      'to': 'القاهرة',
      'price': '150 ج.س',
      'time': '3 ساعات',
      'company': 'حدباي',
      'rating': '4.8',
      'departure': '08:00 ص',
    },
    {
      'from': 'الخرطوم',
      'to': 'أسوان',
      'price': '350 ج.س',
      'time': '12 ساعة',
      'company': 'حدباي',
      'rating': '4.5',
      'departure': '10:00 م',
    },
    {
      'from': 'بورتسودان',
      'to': 'الخرطوم',
      'price': '250 ج.س',
      'time': '6 ساعات',
      'company': 'حدباي',
      'rating': '4.9',
      'departure': '11:30 م',
    },
    {
      'from': 'القاهرة',
      'to': 'الإسكندرية',
      'price': '200 ج.س',
      'time': '4 ساعات',
      'company': 'حدباي',
      'rating': '4.7',
      'departure': '07:00 ص',
    },
    {
      'from': 'الخرطوم',
      'to': 'شندي',
      'price': '300 ج.س',
      'time': '8 ساعات',
      'company': 'حدباي',
      'rating': '4.6',
      'departure': '09:00 م',
    },
  ];

  List<Map<String, String>> _filteredRoutes = [];
  String? _selectedFrom;
  String? _selectedTo;
  DateTime? _selectedDate;
  bool _hasSearched = false;

  void _searchRoutes() {
    setState(() {
      _hasSearched = true;
      _filteredRoutes = _allRoutes.where((route) {
        bool matchesFrom =
            _selectedFrom == null || route['from'] == _selectedFrom;
        bool matchesTo = _selectedTo == null || route['to'] == _selectedTo;
        return matchesFrom && matchesTo;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> cities = [
      'الخرطوم',
      'بورتسودان',
      'شندي',
      'القاهرة',
      'الإسكندرية',
      'أسوان',
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'أهلاً بك 👋',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'إلى أين تريد السفر؟',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00897B),
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFF00897B),
                          child: const Icon(
                            Icons.notifications,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedFrom,
                          decoration: const InputDecoration(
                            labelText: 'من مدينة',
                            prefixIcon: Icon(Icons.location_on),
                            border: OutlineInputBorder(),
                          ),
                          items: cities
                              .map(
                                (city) => DropdownMenuItem(
                                  value: city,
                                  child: Text(city),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedFrom = val),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedTo,
                          decoration: const InputDecoration(
                            labelText: 'إلى مدينة',
                            prefixIcon: Icon(Icons.location_on_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: cities
                              .map(
                                (city) => DropdownMenuItem(
                                  value: city,
                                  child: Text(city),
                                ),
                              )
                              .toList(),
                          onChanged: (val) => setState(() => _selectedTo = val),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (picked != null)
                              setState(() => _selectedDate = picked);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'تاريخ السفر',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _selectedDate == null
                                  ? 'اختر التاريخ'
                                  : '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}',
                            ),
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'بحث عن الرحلات',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_hasSearched) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'الرحلات المتاحة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00897B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_filteredRoutes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            'عذراً، لا توجد رحلات مطابقة لبحثك',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredRoutes.length,
                        itemBuilder: (context, index) {
                          return _buildRouteCard(_filteredRoutes[index]);
                        },
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteCard(Map<String, String> route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_bus, color: Color(0xFF00897B)),
                  const SizedBox(width: 8),
                  Text(
                    route['company']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  Text(
                    route['rating']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${route['from']} ➔ ${route['to']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF00897B),
                    ),
                  ),
                  Text(
                    route['time']!,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    route['departure']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    route['price']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingScreen(
                      from: route['from']!,
                      to: route['to']!,
                      price: route['price']!,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'احجز الآن',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookingScreen extends StatefulWidget {
  final String from;
  final String to;
  final String price;

  const BookingScreen({
    super.key,
    required this.from,
    required this.to,
    required this.price,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int? _selectedSeat;
  final List<int> _bookedSeats = [1, 5, 9, 12, 15, 20];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('حجز رحلة من ${widget.from} إلى ${widget.to}'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF00897B),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(
                    'السعر: ${widget.price}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'الرحلة: ${widget.from} ➔ ${widget.to}',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'اختر مقعدك:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 350,
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: 24,
                    itemBuilder: (context, index) {
                      final seatNumber = index + 1;
                      final isBooked = _bookedSeats.contains(seatNumber);
                      final isSelected = _selectedSeat == seatNumber;

                      return GestureDetector(
                        onTap: isBooked
                            ? null
                            : () {
                                setState(() {
                                  _selectedSeat = seatNumber;
                                });
                              },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isBooked
                                ? Colors.grey[300]
                                : (isSelected
                                      ? const Color(0xFF00897B)
                                      : Colors.white),
                            border: Border.all(
                              color: isBooked
                                  ? Colors.grey[400]!
                                  : const Color(0xFF00897B),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_seat,
                                  size: 18,
                                  color: isBooked
                                      ? Colors.grey[600]
                                      : (isSelected
                                            ? Colors.white
                                            : const Color(0xFF00897B)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$seatNumber',
                                  style: TextStyle(
                                    color: isBooked
                                        ? Colors.grey[600]
                                        : (isSelected
                                              ? Colors.white
                                              : Colors.black),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedSeat == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PassengerDetailsScreen(
                              from: widget.from,
                              to: widget.to,
                              price: widget.price,
                              seatNumber: _selectedSeat!,
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedSeat == null
                      ? Colors.grey
                      : const Color(0xFF00897B),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _selectedSeat == null
                      ? 'الرجاء اختيار مقعد'
                      : 'تأكيد حجز المقعد $_selectedSeat',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PassengerDetailsScreen extends StatefulWidget {
  final String from;
  final String to;
  final String price;
  final int seatNumber;

  const PassengerDetailsScreen({
    super.key,
    required this.from,
    required this.to,
    required this.price,
    required this.seatNumber,
  });

  @override
  State<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  void _confirmBooking() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final String bookingRef =
          'BS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      try {
        await FirebaseFirestore.instance.collection('tickets').add({
          'from': widget.from,
          'to': widget.to,
          'price': widget.price,
          'seatNumber': widget.seatNumber,
          'passengerName': _nameController.text,
          'bookingRef': bookingRef,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        Ticket newTicket = Ticket(
          from: widget.from,
          to: widget.to,
          price: widget.price,
          seatNumber: widget.seatNumber.toString(),
          passengerName: _nameController.text,
          bookingRef: bookingRef,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TicketScreen(ticket: newTicket),
          ),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('حدث خطأ أثناء الحجز: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بيانات الركاب'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF00897B),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Text(
                      'الرحلة: ${widget.from} ➔ ${widget.to}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'المقعد رقم: ${widget.seatNumber} | السعر: ${widget.price}',
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'الاسم بالكامل',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'أدخل اسمك الثلاثي',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'الرجاء إدخال الاسم'
                    : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'رقم الهاتف',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'أدخل رقم هاتفك',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'الرجاء إدخال رقم الهاتف';
                  if (value.length < 11)
                    return 'رقم الهاتف يجب أن يكون 11 رقماً على الأقل';
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00897B),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'تأكيد الحجز النهائي',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TicketScreen extends StatelessWidget {
  final Ticket ticket;

  const TicketScreen({super.key, required this.ticket});

  Widget _buildDetailBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String ticketData =
        'Hadbay|${ticket.from}-${ticket.to}|Seat:${ticket.seatNumber}|${ticket.price}|${ticket.passengerName}';
    const tealColor = Color(0xFF00897B);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 60),
                  const SizedBox(height: 10),
                  const Text(
                    'تم تأكيد الحجز بنجاح!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: tealColor,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'تذكرة سفر',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: const [
                                      Text(
                                        'حدباي',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        'HADBAY BUS',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.directions_bus,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'رقم الحجز',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    ticket.bookingRef,
                                    style: const TextStyle(
                                      color: tealColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: tealColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'مؤكد',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'من',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    ticket.from,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_forward, color: tealColor),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'إلى',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    ticket.to,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildDetailBox('التاريخ', 'اليوم'),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildDetailBox('الوقت', '08:00 ص'),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildDetailBox(
                                  'اسم المسافر',
                                  ticket.passengerName,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildDetailBox(
                                  'رقم المقعد',
                                  ticket.seatNumber,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          child: Row(
                            children: List.generate(
                              30,
                              (index) => Expanded(
                                child: Container(
                                  color: index % 2 == 0
                                      ? Colors.grey[300]
                                      : Colors.transparent,
                                  height: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'الإجمالي',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    ticket.price,
                                    style: const TextStyle(
                                      color: tealColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: QrImageView(
                                  data: ticketData,
                                  version: QrVersions.auto,
                                  size: 90.0,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(top: 15),
                          decoration: BoxDecoration(
                            color: tealColor.withOpacity(0.05),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'شكراً لاستخدامك حدباي • يرجى الحضور قبل موعد الانطلاق بـ 15 دقيقة',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tealColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'العودة للرئيسية',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
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

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تذاكري'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'لا توجد تذاكر محفوظة حالياً',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    'قم بحجز رحلة لتظهر تذكرتك هنا',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          final tickets = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = Ticket.fromFirestore(
                tickets[index].data() as Map<String, dynamic>,
              );
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF00897B),
                    child: const Icon(
                      Icons.directions_bus,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    '${ticket.from} ➔ ${ticket.to}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text('الاسم: ${ticket.passengerName}'),
                      Text(
                        'المقعد: ${ticket.seatNumber} | السعر: ${ticket.price}',
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.qr_code,
                    color: Color(0xFF00897B),
                    size: 30,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TicketScreen(ticket: ticket),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
// ==========================================
// شاشة البداية المتحركة (Splash Screen) - النسخة الآمنة
// ==========================================
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
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00897B),
      body: Center(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOut, // منحنى آمن (بدون ارتداد)
          builder: (context, double value, child) {
            return Opacity(
              opacity: value.clamp(0.0, 1.0), // حماية من الخروج عن النطاق
              child: child,
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.directions_bus, size: 120, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                'حدباي',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: GoogleFonts.cairo().fontFamily,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'HADBAY BUS',
                style: TextStyle(fontSize: 16, color: Colors.white70, letterSpacing: 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}