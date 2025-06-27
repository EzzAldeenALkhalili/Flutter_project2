import 'package:flutter/material.dart';

class ConfirmationPage extends StatelessWidget {
  final String doctorName;
  final String clinicName;
  final String location;
  final String time;

  const ConfirmationPage({
    Key? key,
    required this.doctorName,
    required this.clinicName,
    required this.location,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تأكيد الموعد'),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.check_circle, color: Colors.blue, size: 100),
              SizedBox(height: 30),
              Text(
                'تم حجز الموعد بنجاح!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 30),
              buildInfoRow('الطبيب:', doctorName),
              buildInfoRow('العيادة:', clinicName),
              buildInfoRow('الموقع:', location),
              buildInfoRow('الوقت:', time),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/myBookings',
                    (_) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: Text('عرض حجوزاتي'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(value, style: TextStyle(fontSize: 16)),
          SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
