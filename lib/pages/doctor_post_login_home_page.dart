import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorPostLoginHomePage extends StatefulWidget {
  const DoctorPostLoginHomePage({Key? key}) : super(key: key);

  @override
  State<DoctorPostLoginHomePage> createState() =>
      _DoctorPostLoginHomePageState();
}

class _DoctorPostLoginHomePageState extends State<DoctorPostLoginHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 2;
  String? _doctorName;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchName();
  }

  Future<void> _fetchName() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = snap.data() as Map<String, dynamic>?;
    setState(() {
      _doctorName =
          data == null ? 'دكتور' : '${data['firstName']} ${data['lastName']}';
      _loading = false;
    });
  }

  void _onTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F9FC),
      body: SafeArea(
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    _TopBar(),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _GreetingHeader(name: _doctorName!),
                          const SizedBox(height: 16),
                          _ImageBanner(),
                          const SizedBox(height: 24),
                          _DoctorLookingSection(),
                        ],
                      ),
                    ),
                  ],
                ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.arrow_back), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'القائمة'),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('Doctor Dashboard', style: TextStyle(color: Colors.white)),
          Icon(Icons.light_mode, color: Colors.white),
        ],
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final String name;
  const _GreetingHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.person, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(child: Text('مرحباً دكتور $name')),
        ],
      ),
    );
  }
}

class _ImageBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset('assets/logo2.png', height: 160, fit: BoxFit.cover),
    );
  }
}

class _DoctorLookingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اختصارات',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _card(
              context,
              label: 'مرضاي',
              icon: Icons.list_alt,
              onTap: () => Navigator.pushNamed(context, '/doctorPatients'),
            ),
            const SizedBox(width: 16),
            _card(
              context,
              label: 'بحث طبيب',
              icon: Icons.search,
              onTap: () => Navigator.pushNamed(context, '/doctorSearch'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _card(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
          ),
          child: Column(
            children: [
              Icon(icon, size: 48, color: Colors.blue),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
