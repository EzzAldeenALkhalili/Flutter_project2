import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NiqabaNumberPage extends StatefulWidget {
  final String role;

  const NiqabaNumberPage({Key? key, required this.role}) : super(key: key);

  @override
  _NiqabaNumberPageState createState() => _NiqabaNumberPageState();
}

class _NiqabaNumberPageState extends State<NiqabaNumberPage> {
  final TextEditingController _niqabaController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _clinicNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final List<String> specialtiesList = [
    'باطنية',
    'أطفال',
    'عيون',
    'أسنان',
    'عظام',
    'قلب',
    'جلدية',
    'أعصاب',
  ];

  final List<String> governoratesList = [
    'عمان',
    'العقبة',
    'إربد',
    'جرش',
    'الزرقاء',
    'مادبا',
    'الكرك',
  ];

  final List<String> insuranceCompanies = [
    'الضامن للتأمين',
    'الصفا للتأمين',
    'التأمين الإسلامية',
    'الشرق العربي للتأمين',
    'القدس للتأمين',
    'الشرق الأوسط للتأمين',
  ];

  String? selectedSpecialty;
  String? selectedGovernorate;
  String? selectedInsuranceCompany;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('رقم النقابة (${widget.role})'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              buildField(
                _niqabaController,
                'رقم النقابة',
                TextInputType.number,
              ),

              if (widget.role == 'doctor') ...[
                buildField(_fullNameController, 'الاسم الكامل'),

                DropdownButtonFormField<String>(
                  value: selectedSpecialty,
                  decoration: InputDecoration(
                    labelText: 'التخصص',
                    labelStyle: TextStyle(
                      color: Colors.blue[900],
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  items:
                      specialtiesList.map((spec) {
                        return DropdownMenuItem(value: spec, child: Text(spec));
                      }).toList(),
                  onChanged: (value) {
                    setState(() => selectedSpecialty = value);
                  },
                ),
                SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: selectedGovernorate,
                  decoration: InputDecoration(
                    labelText: 'المحافظة',
                    labelStyle: TextStyle(
                      color: Colors.blue[900],
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  items:
                      governoratesList.map((gov) {
                        return DropdownMenuItem(value: gov, child: Text(gov));
                      }).toList(),
                  onChanged: (value) {
                    setState(() => selectedGovernorate = value);
                  },
                ),
                SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: selectedInsuranceCompany,
                  decoration: InputDecoration(
                    labelText: 'شركة التأمين',
                    labelStyle: TextStyle(
                      color: Colors.blue[900],
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  items:
                      insuranceCompanies.map((company) {
                        return DropdownMenuItem(
                          value: company,
                          child: Text(company),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() => selectedInsuranceCompany = value);
                  },
                ),
                SizedBox(height: 15),

                buildField(_clinicNameController, 'اسم العيادة'),
                buildField(_locationController, 'الموقع'),
                buildField(_phoneController, 'رقم الهاتف', TextInputType.phone),
              ],

              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                ),
                child: Text(
                  'متابعة',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField(
    TextEditingController controller,
    String label, [
    TextInputType? type,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        keyboardType: type ?? TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.blue[900],
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }

  Future<void> _submitData() async {
    final niqabaNumber = _niqabaController.text.trim();
    if (niqabaNumber.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('يرجى إدخال رقم النقابة')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('المستخدم غير مسجل الدخول')));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'niqabaNumber': niqabaNumber,
        'role': widget.role,
      }, SetOptions(merge: true));

      if (widget.role == 'doctor') {
        final doctorData = {
          'uid': user.uid,
          'fullName': _fullNameController.text.trim(),
          'specialty': selectedSpecialty ?? '',
          'governorate': selectedGovernorate ?? '',
          'clinicName': _clinicNameController.text.trim(),
          'location': _locationController.text.trim(),
          'phone': _phoneController.text.trim(),
          'insuranceCompany': selectedInsuranceCompany ?? '',
        };

        await FirebaseFirestore.instance.collection('doctors').add(doctorData);
      }

      if (widget.role == 'doctor') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/doctorMainDashboard',
          (_) => false,
        );
      } else {
        Navigator.pushNamed(
          context,
          '/patientInsurance',
          arguments: {'role': widget.role},
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل في الحفظ: $e')));
    }
  }
}
