import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorSelectionPage extends StatefulWidget {
  final String insuranceCompany;

  const DoctorSelectionPage({Key? key, required this.insuranceCompany})
      : super(key: key);

  @override
  State<DoctorSelectionPage> createState() => _DoctorSelectionPageState();
}

class _DoctorSelectionPageState extends State<DoctorSelectionPage> {
  List<String> specialties = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSpecialties();
  }

  Future<void> fetchSpecialties() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('doctors')
          .where('insuranceCompany', isEqualTo: widget.insuranceCompany)
          .get();

      final uniqueSpecialties = query.docs
          .map((e) => e['specialty'] as String)
          .toSet()
          .toList();

      setState(() {
        specialties = uniqueSpecialties;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل تحميل التخصصات')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'الأطباء',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Icon(Icons.chevron_left),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : specialties.isEmpty
          ? Center(child: Text('لا يوجد تخصصات متاحة لهذه الشركة'))
          : ListView.separated(
        itemCount: specialties.length,
        separatorBuilder: (_, __) => Divider(height: 1),
        itemBuilder: (context, index) {
          final specialty = specialties[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            trailing: const Icon(Icons.arrow_back_ios, size: 18),
            title: Align(
              alignment: Alignment.centerRight,
              child: Text(
                specialty,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/doctorListBySpecialty',
                arguments: {
                  'insuranceCompany': widget.insuranceCompany,
                  'specialty': specialty,
                  'governorate': '', // ممكن نضيفها لاحقًا
                },
              );
            },
          );
        },
      ),
    );
  }
}
