import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({Key? key}) : super(key: key);

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  String? doctorName;
  String? doctorUid;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctorInfo();
  }

  Future<void> _fetchDoctorInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final data = doc.data() ?? {};

    setState(() {
      doctorUid = user.uid;
      doctorName = '${data['firstName']} ${data['lastName']}';
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الصفحة الرئيسية للطبيب')),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('appointments')
                        .where('doctorUid', isEqualTo: doctorUid)
                        .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.data!.docs.isEmpty) {
                    return const Center(child: Text('لا توجد مواعيد حالياً'));
                  }
                  return ListView(
                    padding: const EdgeInsets.all(24),
                    children:
                        snap.data!.docs.map((d) {
                          final data = d.data() as Map<String, dynamic>;
                          return Card(
                            color: Colors.blue.shade50,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(
                                Icons.person,
                                color: Colors.blue,
                              ),
                              title: Text(data['patientName'] ?? ''),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['time'] ?? ''),
                                  Text(
                                    'الدرجة: ${data['insuranceTier'] ?? '-'}',
                                  ),
                                  Text(
                                    'رقم التأمين: ${data['insuranceNumber'] ?? '-'}',
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  );
                },
              ),
    );
  }
}
