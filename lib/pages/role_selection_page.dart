import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({Key? key}) : super(key: key);

  Future<void> _handleRoleSelection(BuildContext context, String role) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // تخزين الدور في Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'role': role,
        }, SetOptions(merge: true));

        // التنقل حسب الدور
        if (role == 'طبيب' || role == 'صيدلاني') {
          Navigator.pushNamed(
            context,
            '/niqabaNumber',
            arguments: {'role': role},
          );
        } else {
          Navigator.pushNamed(
            context,
            '/patientInsurance',
            arguments: {'role': role},
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل حفظ الدور، حاول مرة أخرى')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لم يتم العثور على المستخدم')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('اختر نوع الحساب', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Image.asset('assets/logo.png', width: 35),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.blue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
          child: Column(
            children: [
              buildRoleCard(context, icon: Icons.person, label: 'مريض', role: 'مريض'),
              SizedBox(height: 30),
              buildRoleCard(context, icon: Icons.medical_services, label: 'طبيب', role: 'طبيب'),
              SizedBox(height: 30),
              buildRoleCard(context, icon: Icons.local_pharmacy, label: 'صيدلاني', role: 'صيدلاني'),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRoleCard(BuildContext context, {
    required IconData icon,
    required String label,
    required String role,
  }) {
    return GestureDetector(
      onTap: () => _handleRoleSelection(context, role),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 25, horizontal: 25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.9), Colors.blue.shade100.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 8),
            ),
          ],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.shade800, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue[900], size: 34),
            SizedBox(width: 25),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                  shadows: [
                    Shadow(color: Colors.blue.shade100, blurRadius: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
