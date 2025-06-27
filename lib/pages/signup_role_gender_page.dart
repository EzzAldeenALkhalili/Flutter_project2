import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupRoleGenderPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const SignupRoleGenderPage({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  State<SignupRoleGenderPage> createState() => _SignupRoleGenderPageState();
}

class _SignupRoleGenderPageState extends State<SignupRoleGenderPage> {
  String _gender = 'Male';
  String _role = 'patient';
  bool _isLoading = false;
  String _error = '';

  Future<void> _finishSignup() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: widget.email,
            password: widget.password,
          );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
            'firstName': widget.firstName,
            'lastName': widget.lastName,
            'email': widget.email,
            'gender': _gender,
            'role': _role,
            'createdAt': Timestamp.now(),
          });

      if (_role == 'doctor' || _role == 'pharmacist') {
        Navigator.pushReplacementNamed(
          context,
          '/niqabaNumber',
          arguments: {'role': _role},
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          '/patientInsurance',
          arguments: {'role': _role},
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        // Provide Arabic messages for common signup errors
        switch (e.code) {
          case 'email-already-in-use':
            _error =
                'هذا البريد الإلكتروني مسجّل بالفعل، يرجى استخدام بريد آخر أو تسجيل الدخول.';
            break;
          case 'invalid-email':
            _error = 'البريد الإلكتروني غير صالح.';
            break;
          case 'weak-password':
            _error = 'كلمة المرور ضعيفة، يرجى اختيار كلمة مرور أقوى.';
            break;
          default:
            _error = 'حدث خطأ أثناء إنشاء الحساب، حاول مرة أخرى.';
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Unexpected error';
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Role & Gender'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'اختر الدور:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('مريض', textAlign: TextAlign.end),
              leading: Radio<String>(
                value: 'patient',
                groupValue: _role,
                onChanged: (v) => setState(() => _role = v!),
              ),
            ),
            ListTile(
              title: const Text('طبيب', textAlign: TextAlign.end),
              leading: Radio<String>(
                value: 'doctor',
                groupValue: _role,
                onChanged: (v) => setState(() => _role = v!),
              ),
            ),
            ListTile(
              title: const Text('صيدلي', textAlign: TextAlign.end),
              leading: Radio<String>(
                value: 'pharmacist',
                groupValue: _role,
                onChanged: (v) => setState(() => _role = v!),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Gender:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'Male',
                  groupValue: _gender,
                  onChanged: (v) => setState(() => _gender = v!),
                ),
                const Text('Male'),
                Radio<String>(
                  value: 'Female',
                  groupValue: _gender,
                  onChanged: (v) => setState(() => _gender = v!),
                ),
                const Text('Female'),
              ],
            ),
            const SizedBox(height: 24),
            if (_error.isNotEmpty)
              Text(
                _error,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            const Spacer(),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed: _finishSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
