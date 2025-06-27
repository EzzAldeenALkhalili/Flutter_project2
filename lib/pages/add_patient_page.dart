import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPatientPage extends StatefulWidget {
  @override
  _AddPatientPageState createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController bloodTypeController = TextEditingController();
  final TextEditingController chronicDiseasesController =
      TextEditingController();
  final TextEditingController medicationsController = TextEditingController();

  void savePatientData() async {
    final name = nameController.text.trim();
    final age = ageController.text.trim();
    final bloodType = bloodTypeController.text.trim();
    final chronicDiseases = chronicDiseasesController.text.trim();
    final medications = medicationsController.text.trim();

    if (name.isEmpty || age.isEmpty || bloodType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى تعبئة جميع الحقول المطلوبة')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('patients').add({
        'name': name,
        'age': age,
        'bloodType': bloodType,
        'chronicDiseases': chronicDiseases,
        'medications': medications,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم حفظ بيانات المريض بنجاح ✅')));

      nameController.clear();
      ageController.clear();
      bloodTypeController.clear();
      chronicDiseasesController.clear();
      medicationsController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل حفظ البيانات: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة مريض جديد'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            buildField(label: 'اسم المريض', controller: nameController),
            buildField(
              label: 'العمر',
              controller: ageController,
              keyboardType: TextInputType.number,
            ),
            buildField(label: 'فصيلة الدم', controller: bloodTypeController),
            buildField(
              label: 'أمراض مزمنة',
              controller: chronicDiseasesController,
            ),
            buildField(label: 'أدوية حالية', controller: medicationsController),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: savePatientData,
              icon: Icon(Icons.save),
              label: Text('حفظ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[800],
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
}
