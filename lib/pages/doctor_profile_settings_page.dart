import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_patient_profile_page.dart';

class DoctorProfileSettingsPage extends StatefulWidget {
  const DoctorProfileSettingsPage({Key? key}) : super(key: key);

  @override
  State<DoctorProfileSettingsPage> createState() =>
      _DoctorProfileSettingsPageState();
}

class _DoctorProfileSettingsPageState extends State<DoctorProfileSettingsPage> {
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      _userData = snap.data();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: themeColor,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: themeColor,
                          child: const Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${_userData?['firstName']} ${_userData?['lastName']}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_userData?['email']}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final changed = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => EditPatientProfilePage(
                                      initialData: _userData ?? {},
                                    ),
                              ),
                            );
                            if (changed == true) _loadData();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                          ),
                          child: const Text('Edit Profile'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _listItem(Icons.favorite_border, 'Favourites'),
                  _listItem(Icons.download_outlined, 'Downloads'),
                  _divider(),
                  _listItem(Icons.language, 'Languages'),
                  _listItem(Icons.location_on_outlined, 'Location'),
                  _listItem(Icons.subscriptions_outlined, 'Subscription'),
                  _listItem(Icons.tv_outlined, 'Display'),
                  _divider(),
                  _listItem(Icons.delete_outline, 'Clear Cache'),
                  _listItem(Icons.history, 'Clear History'),
                  _listItem(
                    Icons.logout,
                    'Log Out',
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (_) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'App Version 2.3',
                      style: TextStyle(color: Colors.black45),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _listItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _divider() => const Divider(thickness: 1, height: 24);
}
