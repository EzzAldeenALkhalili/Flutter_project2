import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientInsuranceSelectionPage extends StatefulWidget {
  final String role;

  const PatientInsuranceSelectionPage({required this.role});

  @override
  _PatientInsuranceSelectionPageState createState() =>
      _PatientInsuranceSelectionPageState();
}

class _PatientInsuranceSelectionPageState
    extends State<PatientInsuranceSelectionPage> {
  final List<String> insuranceCompanies = [
    'الضامن للتأمين',
    'الصفا للتأمين',
    'التأمين الإسلامية',
    'الشرق العربي للتأمين',
    'القدس للتأمين',
    'الشرق الأوسط للتأمين',
  ];

  String? selectedInsurance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('اختر شركة التأمين'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.indigo.shade900,
              const Color.fromARGB(255, 0, 140, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              widget.role.toLowerCase().contains('doctor') ||
                      widget.role == 'طبيب'
                  ? 'اختر شركة التأمين التي تتعامل معها:'
                  : 'اختر شركة التأمين الخاصة بك:',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: insuranceCompanies.length,
                itemBuilder: (context, index) {
                  final company = insuranceCompanies[index];
                  final isSelected = selectedInsurance == company;

                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedInsurance = company);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Colors.white.withOpacity(0.9)
                                : Colors.white.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? Colors.blue.shade900
                                  : Colors.white70,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                isSelected
                                    ? Colors.blue.withOpacity(0.3)
                                    : Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        company,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  selectedInsurance != null
                      ? () async {
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid != null) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .update({'insuranceCompany': selectedInsurance});
                        }

                        if (widget.role.toLowerCase().contains('doctor') ||
                            widget.role == 'طبيب') {
                          Navigator.pushNamed(
                            context,
                            '/doctorAppointments',
                            arguments: {'selectedInsurance': selectedInsurance},
                          );
                        } else if (widget.role == 'صيدلاني') {
                          Navigator.pushNamed(
                            context,
                            '/pharmacistInsuranceInput',
                            arguments: {'company': selectedInsurance},
                          );
                        } else {
                          Navigator.pushNamed(
                            context,
                            '/insuranceDetails',
                            arguments: {
                              'company': selectedInsurance,
                              'role': widget.role,
                            },
                          );
                        }
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue[900],
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
              ),
              child: Text(
                'متابعة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
