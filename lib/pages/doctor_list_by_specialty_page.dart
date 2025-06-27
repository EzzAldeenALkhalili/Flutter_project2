import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorListBySpecialtyPage extends StatefulWidget {
  final String specialty;
  final String governorate;
  final String insuranceCompany;

  const DoctorListBySpecialtyPage({
    Key? key,
    required this.specialty,
    required this.governorate,
    required this.insuranceCompany,
  }) : super(key: key);

  @override
  State<DoctorListBySpecialtyPage> createState() =>
      _DoctorListBySpecialtyPageState();
}

class _DoctorListBySpecialtyPageState extends State<DoctorListBySpecialtyPage> {
  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    try {
      Query<Map<String, dynamic>> q = FirebaseFirestore.instance
          .collection('doctors')
          .where('specialty', isEqualTo: widget.specialty);

      if (widget.governorate.isNotEmpty) {
        q = q.where('governorate', isEqualTo: widget.governorate);
      }

      if (widget.insuranceCompany.isNotEmpty) {
        q = q.where('insuranceCompany', isEqualTo: widget.insuranceCompany);
      }

      final querySnapshot = await q.get();

      setState(() {
        doctors =
            querySnapshot.docs.map((doc) {
              final data = doc.data();
              data['uid'] = doc.id;
              return data;
            }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('فشل تحميل الأطباء')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الأطباء - ${widget.specialty}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : doctors.isEmpty
              ? const Center(child: Text('لا يوجد أطباء متاحين'))
              : ListView.builder(
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doc = doctors[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Text(doc['fullName'][0]),
                      ),
                      title: Text(doc['fullName']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doc['clinicName'] ?? ''),
                          Text(doc['location'] ?? ''),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, color: Colors.orange, size: 18),
                          Text('${doc['rating'] ?? 0.0}'),
                        ],
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/doctorProfile',
                          arguments: {
                            'doctor': doc,
                            'doctorUid': doc['uid'],
                          },
                        );
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/mainDashboard',
            (route) => false,
          );
        },
        label: const Text('Sign Up'),
        icon: const Icon(Icons.home),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}
