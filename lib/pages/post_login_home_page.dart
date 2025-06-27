import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/patient_scaffold.dart';

class PostLoginHomePage extends StatefulWidget {
  const PostLoginHomePage({Key? key}) : super(key: key);

  @override
  State<PostLoginHomePage> createState() => _PostLoginHomePageState();
}

class _PostLoginHomePageState extends State<PostLoginHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 2; // default to home icon

  String? _userFullName;
  bool _isLoadingName = true;
  String _role = 'patient';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final snap =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (snap.exists) {
          final data = snap.data() as Map<String, dynamic>;
          setState(() {
            _userFullName = '${data['firstName']} ${data['lastName']}';
            _role = data['role'] ?? 'patient';
            _isLoadingName = false;
          });
          // No automatic navigation here to prevent flicker; routing handled at login
          return;
        }
      }
    } catch (_) {}
    setState(() {
      _userFullName = 'مستخدم';
      _isLoadingName = false;
    });
  }

  void _onBottomNavTap(int index) {
    if (index == 2) {
      // menu
      _scaffoldKey.currentState?.openEndDrawer();
      return;
    }
    if (index == 0) {
      Navigator.pushNamed(context, '/patientProfile');
      return;
    }
    // home (index 1)
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PatientScaffold(
      currentIndex: 1,
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _GreetingHeader(userName: _userFullName ?? '...'),
                  const SizedBox(height: 16),
                  _ImageCarousel(),
                  const SizedBox(height: 24),
                  _LookingForSection(role: _role),
                  const SizedBox(height: 24),
                  _SpecialtiesSection(),
                  const SizedBox(height: 24),
                  _SectionCard(
                    title: 'الأدوية الفعالة',
                    subtitle: 'عرض الأدوية',
                    icon: Icons.medication_outlined,
                    bodyText: 'ليس لديك أدوية فعالة حالياً',
                    linkText: 'لعرض جميع تفاصيل الأدوية الفعالة انقر هنا',
                  ),
                  SizedBox(height: 16),
                  _SectionCard(
                    title: 'المواعيد',
                    subtitle: 'عرض المواعيد الطبية',
                    icon: Icons.event_note_outlined,
                    bodyText: 'لم يتم العثور على بيانات',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      endDrawer: _SideMenu(role: _role),
    );
  }
}

class _SideMenu extends StatelessWidget {
  final String role;
  const _SideMenu({required this.role});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        color: const Color(0xFF075E9F),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            children: [
              _drawerItem(
                title: 'الصفحة الرئيسية',
                icon: Icons.home,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              // _drawerItem(
              //   title: 'طبيب',
              //   icon: Icons.medical_services,
              //   onTap: () {
              //     Navigator.pushNamed(
              //       context,
              //       '/niqabaNumber',
              //       arguments: {'role': 'doctor'},
              //     );
              //   },
              // ),
              // _drawerItem(
              //   title: 'مريض',
              //   icon: Icons.person,
              //   onTap: () {
              //     Navigator.pushNamed(
              //       context,
              //       '/patientInsurance',
              //       arguments: {'role': 'patient'},
              //     );
              //   },
              // ),
              // _drawerItem(
              //   title: 'صيدلي',
              //   icon: Icons.local_pharmacy,
              //   onTap: () {
              //     Navigator.pushNamed(
              //       context,
              //       '/patientInsurance',
              //       arguments: {'role': 'صيدلاني'},
              //     );
              //   },
              // ),
              _drawerItem(
                title: 'ملفي',
                icon: Icons.account_circle_outlined,
                onTap: () {
                  Navigator.pushNamed(context, '/patientProfile');
                },
              ),
              // _drawerItem(title: 'الأدوية', icon: Icons.medication_outlined),
              // _drawerItem(title: 'المختبر', icon: Icons.science_outlined),
              // _drawerItem(
              //   title: 'الأشعة',
              //   icon: Icons.wifi_tethering_error_outlined,
              // ),
              const Divider(color: Colors.white30),
              _drawerItem(
                title: "الوصفات الطبية",
                icon: Icons.local_shipping_outlined,
                onTap: () {
                  Navigator.pushNamed(context, '/medicineDelivery');
                },
              ),

              _drawerItem(
                title: 'حجوزاتي',

                icon: Icons.calendar_today_outlined,
                onTap: () {
                  Navigator.pushNamed(context, '/myBookings');
                },
              ),
              _drawerItem(
                title: 'سجل مواعيد المتابعة',
                icon: Icons.event_available_outlined,
              ),
              const Divider(color: Colors.white30),
              _drawerItem(
                title: 'تسجيل الخروج',

                icon: Icons.logout,
                onTap: () async {
                  Navigator.pop(context);
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem({
    required String title,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.lightBlueAccent),
      title: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: Colors.blue,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Tamini',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Image.asset('assets/logo4.png', height: 200, fit: BoxFit.contain),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  const _CircleIcon({required this.icon});
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.white,
      child: Icon(icon, color: Colors.blue, size: 22),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final String userName;
  const _GreetingHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.person, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Welcome, $userName',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  const _ImageCarousel();
  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final _controller = PageController();
  int _current = 0;
  final List<String> _images = ['assets/ban.png', 'assets/ban1.png'];
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), _next);
  }

  void _next() {
    if (!mounted) return;
    _current = (_current + 1) % _images.length;
    _controller.animateToPage(
      _current,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    Future.delayed(const Duration(seconds: 3), _next);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: PageView.builder(
          controller: _controller,
          itemCount: _images.length,
          itemBuilder:
              (context, index) =>
                  Image.asset(_images[index], fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _LookingForSection extends StatelessWidget {
  final String role;
  const _LookingForSection({required this.role});

  @override
  Widget build(BuildContext context) {
    // Create the list of cards to display.
    final List<Widget> cardWidgets = [
      _lookingCard(
        context,
        image: 'assets/dedo2.png',
        label: 'Booking doctor appointment',
        onTap: () => Navigator.pushNamed(context, '/doctorSearch'),
      ),
    ];

    // Only show the second card depending on role.
    cardWidgets.add(const SizedBox(width: 16));
    if (role == 'doctor') {
      cardWidgets.add(
        _lookingCard(
          context,
          image: 'assets/logo4.png',
          label: 'My Patients',
          onTap: () => Navigator.pushNamed(context, '/doctorPatients'),
        ),
      );
    } else {
      cardWidgets.add(
        _lookingCard(
          context,
          image: 'assets/logo4.png',
          label: 'Booking home visit',
          onTap: () {},
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What are you looking for?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(children: cardWidgets),
      ],
    );
  }

  Widget _lookingCard(
    BuildContext context, {
    required String image,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(image, height: 120, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecialtiesSection extends StatelessWidget {
  const _SpecialtiesSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'التخصصات',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                final titles = ['طبيب', 'صيدلي', 'مختبر', 'أشعة'];
                final icons = [
                  Icons.medical_services,
                  Icons.local_pharmacy,
                  Icons.science,
                  Icons.wifi_tethering_error_outlined,
                ];
                return _specialtyItem(title: titles[index], icon: icons[index]);
              },
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _specialtyItem({required String title, required IconData icon}) {
    return Container(
      width: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String bodyText;
  final String? linkText;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bodyText,
    this.linkText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                Text(bodyText, style: const TextStyle(fontSize: 14)),
                if (linkText != null) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    child: Text(
                      linkText!,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () {},
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue,
            child: Icon(icon, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
