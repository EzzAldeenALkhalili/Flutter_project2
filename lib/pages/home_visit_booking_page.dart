import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeVisitBookingPage extends StatelessWidget {
  const HomeVisitBookingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('الزيارة المنزلية')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data!.data() as Map<String, dynamic>;
          final tier = data['insuranceTier'] ?? 'غير محددة';
          final List<dynamic> meds = data['medications'] ?? [];
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'درجة التأمين: $tier',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'الوصفة الطبية:',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                if (meds.isEmpty)
                  const Text('لا توجد أدوية متاحة لهذا التأمين')
                else
                  ...meds.map(
                    (m) => ListTile(
                      leading: const Icon(Icons.medication, color: Colors.blue),
                      title: Text(m.toString()),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
