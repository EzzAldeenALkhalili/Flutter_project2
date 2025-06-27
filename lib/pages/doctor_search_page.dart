import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorSearchPage extends StatefulWidget {
  const DoctorSearchPage({Key? key}) : super(key: key);

  @override
  State<DoctorSearchPage> createState() => _DoctorSearchPageState();
}

class _DoctorSearchPageState extends State<DoctorSearchPage> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Search For Doctors'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search for speciality or doctors.',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon:
                    _searchCtrl.text.isEmpty
                        ? null
                        : IconButton(
                          icon: const Icon(Icons.close, color: Colors.blue),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {});
                          },
                        ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('doctors').snapshots(),
              builder: (context, snap) {
                if (!snap.hasData)
                  return const Center(child: CircularProgressIndicator());
                final q = _searchCtrl.text.trim().toLowerCase();
                final docs =
                    snap.data!.docs.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      final name =
                          (data['fullName'] ?? '').toString().toLowerCase();
                      final spec =
                          (data['specialty'] ?? '').toString().toLowerCase();
                      return name.contains(q) || spec.contains(q);
                    }).toList();
                if (docs.isEmpty) {
                  return const Center(child: Text('No doctors found'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final dataMap = docs[index].data() as Map<String, dynamic>;
                    final data = dataMap;
                    return _DoctorCard(data: data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DoctorCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final rating = (data['rating'] ?? 0.0) * 1.0;
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/doctorProfile',
          arguments: {'doctor': data, 'doctorUid': data['uid'] ?? ''},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child:
                    data['photoUrl'] != null
                        ? Image.network(data['photoUrl'], fit: BoxFit.cover)
                        : Image.asset('assets/dedo2.png', fit: BoxFit.cover),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              color: Colors.blue,
              child: Text(
                data['specialty'] ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['fullName'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          Icons.star,
                          size: 14,
                          color: i < rating ? Colors.amber : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
