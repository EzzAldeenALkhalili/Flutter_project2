import 'package:flutter/material.dart';

class PrescriptionReviewPage extends StatefulWidget {
  final String patientName;
  final String insuranceTier;
  final String diagnosis;
  final List<Map<String, dynamic>> medications;
  final Map<String, String> doctorInfo;

  const PrescriptionReviewPage({
    required this.patientName,
    required this.insuranceTier,
    required this.diagnosis,
    required this.medications,
    required this.doctorInfo,
    Key? key,
  }) : super(key: key);

  @override
  State<PrescriptionReviewPage> createState() => _PrescriptionReviewPageState();
}

class _PrescriptionReviewPageState extends State<PrescriptionReviewPage> {
  late List<bool> dispensed;

  @override
  void initState() {
    super.initState();
    dispensed = List<bool>.filled(widget.medications.length, false);
  }

  bool isCovered(String tier, String requiredTier) {
    final levels = ['الدرجة الأولى', 'الدرجة الثانية', 'الدرجة الثالثة'];
    return levels.indexOf(tier) <= levels.indexOf(requiredTier);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      appBar: AppBar(
        title: Text('وصفة المريض'),
        backgroundColor: Colors.indigo[900],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              buildCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'اسم المريض: ${widget.patientName}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'درجة التأمين: ${widget.insuranceTier}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              buildCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'معلومات الطبيب:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text('الاسم: ${widget.doctorInfo['name']}'),
                    Text('العيادة: ${widget.doctorInfo['clinicName']}'),
                    Text('الموقع: ${widget.doctorInfo['location']}'),
                    Text('رقم الهاتف: ${widget.doctorInfo['phone']}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              buildCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'التشخيص:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(widget.diagnosis),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'الأدوية:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              ...widget.medications.asMap().entries.map((entry) {
                int index = entry.key;
                final med = entry.value;
                bool covered = isCovered(
                  widget.insuranceTier,
                  med['coveredFor'],
                );

                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CheckboxListTile(
                    value: dispensed[index],
                    onChanged: (val) {
                      setState(() => dispensed[index] = val ?? false);
                    },
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${med['name']}',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Icon(
                          covered ? Icons.check_circle : Icons.cancel,
                          color: covered ? Colors.blue : Colors.red,
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'الجرعة: ${med['dosage']}',
                      textAlign: TextAlign.right,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                );
              }).toList(),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم تأكيد صرف الأدوية ✅')),
                    );
                  },
                  icon: Icon(Icons.check, color: Colors.white),
                  label: Text(
                    'تأكيد صرف الأدوية',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(Widget child) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
