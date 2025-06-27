import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientMedicalDetailsPage extends StatefulWidget {
  final String patientName;
  final String insuranceTier;

  const PatientMedicalDetailsPage({
    Key? key,
    required this.patientName,
    required this.insuranceTier,
  }) : super(key: key);

  @override
  _PatientMedicalDetailsPageState createState() => _PatientMedicalDetailsPageState();
}

class _PatientMedicalDetailsPageState extends State<PatientMedicalDetailsPage> {
  Map<String, dynamic>? patientData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPatientData();
  }

  Future<void> fetchPatientData() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('patients')
          .where('name', isEqualTo: widget.patientName)
          .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          patientData = query.docs.first.data();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لم يتم العثور على بيانات المريض')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء جلب البيانات')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الملف الطبي'),
        backgroundColor: Colors.indigo[800],
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : patientData == null
          ? Center(child: Text('لا توجد بيانات للمريض'))
          : Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            buildInfo('الاسم:', widget.patientName),
            buildInfo('الدرجة التأمينية:', widget.insuranceTier),
            buildInfo('العمر:', '${patientData!['age']} سنة'),
            buildInfo('فصيلة الدم:', patientData!['bloodType']),
            buildInfo('الحالة الصحية:', patientData!['chronicDiseases']),
            buildInfo('الأدوية:', patientData!['medications']),
            buildInfo('آخر زيارة:', patientData!['lastVisit'] ?? 'غير محدد'),
          ],
        ),
      ),
    );
  }

  Widget buildInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
