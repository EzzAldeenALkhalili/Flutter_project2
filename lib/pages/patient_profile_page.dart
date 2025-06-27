import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({Key? key}) : super(key: key);

  @override
  _PatientProfilePageState createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  String? selectedGovernorate;
  String? selectedSpecialty;
  String patientName = '';
  String insuranceCompany = '';
  String insuranceTier = '';
  String insuranceNumber = '';
  bool isLoading = true;

  final List<String> governorates = ['عمان', 'الزرقاء', 'إربد', 'العقبة'];
  final List<String> specialties = ['عام', 'قلب', 'عيون', 'أطفال', 'عظام'];

  List<Map<String, dynamic>> filteredDoctors = [];

  String? _gender;
  DateTime? _birthDate;
  String? _idNumber;
  String? _phone;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();

      final data = userDoc.data();
      if (data != null) {
        setState(() {
          patientName = '${data['firstName']} ${data['lastName']}';
          insuranceCompany = data['insuranceCompany'] ?? 'غير معروف';
          insuranceTier = data['insuranceTier'] ?? 'غير محددة';
          insuranceNumber = data['insuranceNumber'] ?? '';
          _gender = data['gender'];
          _birthDate = (data['birthDate'] as Timestamp?)?.toDate();
          _idNumber = data['nationalId'];
          _phone = data['phone'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل تحميل بيانات المستخدم')));
    }
  }

  Future<void> fetchDoctors() async {
    if (selectedGovernorate == null || selectedSpecialty == null) return;

    setState(() => isLoading = true);

    try {
      final query =
          await FirebaseFirestore.instance
              .collection('doctors')
              .where('insuranceCompany', isEqualTo: insuranceCompany)
              .where('specialty', isEqualTo: selectedSpecialty)
              .where('governorate', isEqualTo: selectedGovernorate)
              .get();

      setState(() {
        filteredDoctors =
            query.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل تحميل قائمة الأطباء')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF075E9F),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "  My Profile    ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushReplacementNamed(context, '/mainDashboard');
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Image.asset('assets/logo4.png', height: 100),
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: GestureDetector(
                        onTap: () async {
                          final userDoc =
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .get();
                          final changed = await Navigator.pushNamed(
                            context,
                            '/editPatientProfile',
                            arguments: userDoc.data(),
                          );
                          if (changed == true) {
                            fetchUserData();
                          }
                        },
                        child: _buildProfileHeader(),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Color(0xFF075E9F),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const TabBar(
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        labelColor: Color(0xFF075E9F),
                        unselectedLabelColor: Colors.white,
                        tabs: [Tab(text: 'حجوزاتي'), Tab(text: 'بياناتي')],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        children: [
                          MyBookingsPage(),
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _personalInfoSection(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildProfileHeader() {
    return BlueCard(
      color: const Color(0xFF075E9F),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: const Icon(Icons.person, color: Colors.blue, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  patientName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'شركة التأمين: $insuranceCompany',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'الفئة: $insuranceTier',
                  style: const TextStyle(color: Colors.white70),
                ),
                if (insuranceNumber.isNotEmpty)
                  Text(
                    'رقم التأمين: $insuranceNumber',
                    style: const TextStyle(color: Colors.white70),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _personalInfoSection() {
    return BlueCard(
      color: const Color(0xFF075E9F),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _iconText(Icons.wc, _gender ?? 'غير محدد'),
          _iconText(
            Icons.cake,
            _birthDate == null
                ? 'غير محدد'
                : DateFormat('yyyy-MM-dd').format(_birthDate!),
          ),
          _iconText(Icons.badge, _idNumber ?? '—'),
          _iconText(Icons.phone, _phone ?? '—'),
          if (insuranceNumber.isNotEmpty)
            _iconText(Icons.confirmation_number, insuranceNumber),
        ],
      ),
    );
  }

  Widget _dot(bool active) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? Colors.blue : Colors.grey,
      ),
    );
  }

  Widget _iconText(IconData icon, String txt) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(child: Text(txt, textAlign: TextAlign.right)),
      ],
    ),
  );
}

class _AppointmentFormSheet extends StatefulWidget {
  const _AppointmentFormSheet();

  @override
  State<_AppointmentFormSheet> createState() => _AppointmentFormSheetState();
}

class _AppointmentFormSheetState extends State<_AppointmentFormSheet> {
  String? _selectedFacility;
  String? _selectedClinic;

  final List<String> facilities = [
    'مركز صحي المدينة',
    'مستشفى الملكة رانيا',
    'مستشفى الجامعة',
  ];

  final List<String> clinicSpecialties = ['عام', 'أطفال', 'عيون', 'قلب'];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      builder:
          (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'طلب موعد متابعة',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _dropdownField(
                  hint: 'اختر المنشأة الصحية',
                  value: _selectedFacility,
                  items: facilities,
                  onChanged: (val) => setState(() => _selectedFacility = val),
                ),
                const SizedBox(height: 16),
                _dropdownField(
                  hint: 'اختر تخصص العيادة',
                  value: _selectedClinic,
                  items: clinicSpecialties,
                  onChanged: (val) => setState(() => _selectedClinic = val),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedFacility == null || _selectedClinic == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يرجى اختيار المنشأة والعيادة'),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حفظ الطلب')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'حفظ ومتابعة',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _dropdownField({
    required String hint,
    String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        items:
            items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: onChanged,
        decoration: const InputDecoration(border: InputBorder.none),
        hint: Text(hint),
        icon: const Icon(Icons.keyboard_arrow_down),
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
                if (linkText != null)
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      linkText!,
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
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

class LogoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تأكيد تسجيل الخروج'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          },
          child: const Text('خروج'),
        ),
      ],
    );
  }
}

class BlueCard extends StatelessWidget {
  final Widget child;
  final Color color;
  const BlueCard({required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class MyBookingsPage extends StatelessWidget {
  // أوقات متاحة لتعديل الموعد
  static const List<String> _availableTimes = [
    '10:00 صباحاً',
    '12:00 ظهراً',
    '2:00 مساءً',
    '4:00 مساءً',
    '6:00 مساءً',
  ];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('حجوزاتي'),
        leading: const BackButton(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed:
                () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/mainDashboard',
                  (_) => false,
                ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('appointments')
                .where('patientId', isEqualTo: uid)
                .snapshots(),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.data!.docs.isEmpty) {
            return const Center(child: Text('لا توجد حجوزات'));
          }
          return ListView(
            children:
                snap.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.event_available,
                        color: Colors.blue,
                      ),
                      title: Text(
                        data['doctorName'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['time'] ?? '',
                            style: const TextStyle(color: Colors.black87),
                          ),
                          Text(
                            'الحالة: ${data['status'] ?? 'قيد الانتظار'}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            final newTime = await _showEditDialog(
                              context,
                              data['time'],
                            );
                            if (newTime != null && newTime != data['time']) {
                              FirebaseFirestore.instance
                                  .collection('appointments')
                                  .doc(doc.id)
                                  .update({'time': newTime});
                            }
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder:
                                  (ctx) => AlertDialog(
                                    title: const Text('تأكيد الحذف'),
                                    content: const Text(
                                      'هل أنت متأكد من حذف هذا الحجز؟',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(ctx, false),
                                        child: const Text('إلغاء'),
                                      ),
                                      ElevatedButton(
                                        onPressed:
                                            () => Navigator.pop(ctx, true),
                                        child: const Text('حذف'),
                                      ),
                                    ],
                                  ),
                            );
                            if (confirm == true) {
                              FirebaseFirestore.instance
                                  .collection('appointments')
                                  .doc(doc.id)
                                  .delete();
                            }
                          }
                        },
                        itemBuilder:
                            (_) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('تعديل'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('حذف'),
                              ),
                            ],
                        icon: const Icon(Icons.more_vert, color: Colors.blue),
                      ),
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }

  Future<String?> _showEditDialog(BuildContext context, String? currentTime) {
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        String? _selected = currentTime;
        return StatefulBuilder(
          builder:
              (ctx, setStateSB) => AlertDialog(
                title: const Text('تعديل الموعد'),
                content: DropdownButton<String>(
                  style: const TextStyle(color: Colors.black),
                  value: _selected,
                  isExpanded: true,
                  items:
                      _availableTimes
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(
                                t,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (val) => setStateSB(() => _selected = val),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, _selected),
                    child: const Text('حفظ'),
                  ),
                ],
              ),
        );
      },
    );
  }
}
