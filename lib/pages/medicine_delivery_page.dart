import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicineDeliveryPage extends StatelessWidget {
  const MedicineDeliveryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final themeColor = Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الوصفات الطبية'),
        backgroundColor: themeColor,
      ),
      body:
          uid == null
              ? const Center(child: Text('غير مسجل الدخول'))
              : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream:
                    FirebaseFirestore.instance
                        .collection('prescriptions')
                        .where('patientId', isEqualTo: uid)
                        .where('status', isEqualTo: 'approved')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('لا توجد طلبات توصيل حالياً'),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children:
                        snapshot.data!.docs.map((doc) {
                          final data = doc.data();
                          final status = data['status'] ?? 'pending';
                          final diagnosis = data['diagnosis'] ?? '';
                          final insNum = data['insuranceNumber'] ?? '';
                          final medsList = List<Map<String, dynamic>>.from(
                            data['medications'] ?? [],
                          );
                          final medsSummary = medsList
                              .map((m) => '${m['name']} - ${m['dosage']}')
                              .join('\n');
                          return Card(
                            color: Colors.blue.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: themeColor,
                                child: const Icon(
                                  Icons.medication,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                diagnosis.isEmpty ? 'الوصفة الطبية' : diagnosis,
                              ),
                              subtitle: Text(
                                medsSummary.isNotEmpty
                                    ? 'رقم التأمين: $insNum\n$medsSummary\nالحالة: $status'
                                    : 'رقم التأمين: $insNum\nالحالة: $status',
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    status == 'delivered'
                                        ? Icons.check_circle
                                        : status == 'approved'
                                        ? Icons.local_shipping
                                        : Icons.hourglass_top,
                                    color: themeColor,
                                  ),
                                  if (status == 'pending')
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder:
                                              (ctx) => AlertDialog(
                                                title: const Text(
                                                  'تأكيد الإلغاء',
                                                ),
                                                content: const Text(
                                                  'هل تريد إلغاء طلب توصيل الأدوية؟',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          ctx,
                                                          false,
                                                        ),
                                                    child: const Text('لا'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          ctx,
                                                          true,
                                                        ),
                                                    child: const Text('نعم'),
                                                  ),
                                                ],
                                              ),
                                        );
                                        if (confirm == true) {
                                          await FirebaseFirestore.instance
                                              .collection('prescriptions')
                                              .doc(doc.id)
                                              .delete();
                                        }
                                      },
                                    ),
                                ],
                              ),
                              onTap: () {
                                // Show medicines list
                                final meds = medsList;
                                showModalBottomSheet(
                                  context: context,
                                  builder:
                                      (_) => Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: ListView(
                                          children: [
                                            Text(
                                              diagnosis.isEmpty
                                                  ? 'التشخيص'
                                                  : diagnosis,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 12),
                                            const Divider(),
                                            if (insNum.isNotEmpty)
                                              Text(
                                                'رقم التأمين: $insNum',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            const Divider(),
                                            const Text(
                                              'الأدوية',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            ...meds.map(
                                              (m) => ListTile(
                                                title: Text(m['name']),
                                                subtitle: Text(m['dosage']),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                  );
                },
              ),
    );
  }
}
