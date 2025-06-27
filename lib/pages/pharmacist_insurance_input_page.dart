import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PharmacistInsuranceInputPage extends StatefulWidget {
  final String selectedCompany;

  const PharmacistInsuranceInputPage({Key? key, required this.selectedCompany})
    : super(key: key);

  @override
  _PharmacistInsuranceInputPageState createState() =>
      _PharmacistInsuranceInputPageState();
}

class _PharmacistInsuranceInputPageState
    extends State<PharmacistInsuranceInputPage> {
  final TextEditingController insuranceNumberController =
      TextEditingController();

  String? patientName;
  String? insuranceTier;
  bool isLoading = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> pendingRequests = [];

  Future<void> fetchPatientData() async {
    final insuranceNumber = insuranceNumberController.text.trim();

    if (insuranceNumber.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('يرجى إدخال رقم التأمين')));
      return;
    }

    setState(() => isLoading = true);

    try {
      var userQuery = FirebaseFirestore.instance
          .collection('users')
          .where('insuranceNumber', isEqualTo: insuranceNumber);
      if (widget.selectedCompany.isNotEmpty &&
          widget.selectedCompany != 'default') {
        userQuery = userQuery.where(
          'insuranceCompany',
          isEqualTo: widget.selectedCompany,
        );
      }

      final query = await userQuery.limit(1).get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        setState(() {
          patientName = "${data['firstName']} ${data['lastName']}";
          insuranceTier = data['insuranceTier'] ?? 'غير محددة';
        });

        // Fetch pending delivery requests (prescriptions) for this insurance
        final presSnap =
            await FirebaseFirestore.instance
                .collection('prescriptions')
                .where('insuranceNumber', isEqualTo: insuranceNumber)
                .where('status', isEqualTo: 'pending')
                .get();

        setState(() {
          pendingRequests = presSnap.docs;
        });
      } else {
        setState(() {
          patientName = null;
          insuranceTier = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لم يتم العثور على بيانات لهذا الرقم')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء تحميل البيانات')));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('التحقق من التأمين'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'رقم التأمين:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: insuranceNumberController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'أدخل رقم التأمين',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                fillColor: Colors.grey.shade100,
                filled: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: fetchPatientData,
              icon: Icon(Icons.search),
              label: Text('بحث'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (patientName != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(top: 16),
                    child: ListTile(
                      leading: Icon(Icons.person, color: Colors.blue[800]),
                      title: Text(
                        'الاسم: $patientName',
                        textAlign: TextAlign.right,
                      ),
                      subtitle: Text(
                        'درجة التأمين: $insuranceTier',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'الوصفات المعلقة',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  if (pendingRequests.isEmpty)
                    const Text(
                      'لا توجد وصفات معلقة لهذا التأمين',
                      textAlign: TextAlign.right,
                    )
                  else
                    ...pendingRequests.map((req) {
                      final data = req.data();
                      final diagnosis = data['diagnosis'] ?? '';
                      final meds = List<Map<String, dynamic>>.from(
                        data['medications'] ?? [],
                      );
                      final medsSummary = meds
                          .map((m) => '${m['name']} - ${m['dosage']}')
                          .join('\n');
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.description),
                          title: Text(
                            diagnosis.isEmpty ? 'وصفة طبية' : diagnosis,
                            textAlign: TextAlign.right,
                          ),
                          subtitle: Text(
                            medsSummary,
                            textAlign: TextAlign.right,
                          ),
                          isThreeLine: true,
                          trailing: ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('prescriptions')
                                  .doc(req.id)
                                  .update({'status': 'approved'});
                              setState(() {
                                pendingRequests.remove(req);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تمت الموافقة على الوصفة'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              'قبول',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          onTap: () {
                            // show bottom sheet with details
                            showModalBottomSheet(
                              context: context,
                              builder:
                                  (_) => Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: ListView(
                                      children: [
                                        Text(
                                          diagnosis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'الأدوية',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
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
                ],
              ),
          ],
        ),
      ),
    );
  }
}
