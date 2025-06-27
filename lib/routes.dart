import 'package:flutter/material.dart';

import 'splash_screen.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';
import 'pages/role_selection_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/patient_insurance_selection_page.dart';
import 'pages/insurance_details_page.dart';
import 'pages/booking_page.dart';
import 'pages/confirmation_page.dart';
import 'pages/doctor_appointments_page.dart';
import 'pages/patient_medical_details_page.dart';
import 'pages/pharmacist_insurance_input_page.dart';
import 'pages/add_patient_page.dart';
import 'pages/doctor_selection_page.dart';
import 'pages/niqaba_number_page.dart';
import 'pages/doctor_list_by_specialty_page.dart';
import 'pages/prescription_entry_page.dart' show PrescriptionEntryPage;
import 'pages/prescription_review_page.dart' show PrescriptionReviewPage;
import 'pages/home_page.dart';
import 'pages/post_login_home_page.dart';
import 'pages/appointment_request_page.dart';
import 'pages/patient_profile_page.dart';
import 'pages/doctor_profile_page.dart';
import 'pages/edit_patient_profile_page.dart';
import 'pages/signup_role_gender_page.dart';
import 'pages/doctor_search_page.dart';
import 'pages/home_visit_booking_page.dart';
import 'pages/doctor_home_page.dart';
import 'pages/doctor_post_login_home_page.dart';
import 'pages/doctor_patients_page.dart';
import 'pages/doctor_modern_home_page.dart';
import 'pages/doctor_profile_settings_page.dart';
import 'pages/medicine_delivery_page.dart';
import 'pages/pharmacist_home_page.dart';
import 'pages/pharmacist_profile_page.dart';
// import 'pages/my_bookings_page.dart'; // removed, MyBookingsPage defined in patient_profile_page.dart

Map<String, WidgetBuilder> getAppRoutes() {
  return {
    '/': (context) => SplashScreen(),
    '/login': (context) => LoginPage(),
    '/signup': (context) => SignupPage(),
    '/forgot': (context) => ForgotPasswordPage(),
    '/roleSelect': (context) => RoleSelectionPage(),

    '/patientInsurance': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return PatientInsuranceSelectionPage(role: args['role']);
    },

    '/insuranceDetails': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return InsuranceDetailsPage(
        insuranceCompany: args['company'],
        role: args['role'],
      );
    },

    '/doctorAppointments': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return DoctorAppointmentsPage(
        selectedInsurance: args['selectedInsurance'],
      );
    },

    '/pharmacistInsuranceInput': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return PharmacistInsuranceInputPage(selectedCompany: args['company']);
    },

    '/patientMedicalDetails': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return PatientMedicalDetailsPage(
        patientName: args['patientName'],
        insuranceTier: args['insuranceTier'],
      );
    },

    '/prescriptionEntry': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return PrescriptionEntryPage(
        patientName: args['patientName'],
        insuranceTier: args['insuranceTier'],
        patientId: args['patientId'],
      );
    },

    '/prescriptionReview': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return PrescriptionReviewPage(
        patientName: args['patientName'],
        insuranceTier: args['insuranceTier'],
        diagnosis: args['diagnosis'],
        medications: List<Map<String, dynamic>>.from(args['medications']),
        doctorInfo: Map<String, String>.from(args['doctorInfo']),
      );
    },

    '/dashboard': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, String>;
      return DashboardPage(
        fullName: args['fullName'] ?? 'مجهول',
        role: args['role'] ?? 'غير معروف',
        insuranceTier: args['insuranceTier'] ?? 'غير محددة',
      );
    },

    '/booking': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return BookingPage(
        doctorName: args['doctorName'],
        clinicName: args['clinicName'],
        location: args['location'],
        doctorUid: args['doctorUid'],
      );
    },

    '/confirmation': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return ConfirmationPage(
        doctorName: args['doctorName'],
        clinicName: args['clinicName'],
        location: args['location'],
        time: args['time'],
      );
    },

    '/addPatient': (context) => AddPatientPage(),

    '/doctorSelection': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return DoctorSelectionPage(insuranceCompany: args['insuranceCompany']);
    },

    '/niqabaNumber': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return NiqabaNumberPage(role: args['role']);
    },

    '/doctorListBySpecialty': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return DoctorListBySpecialtyPage(
        specialty: args['specialty'],
        governorate: args['governorate'],
        insuranceCompany: args['insuranceCompany'],
      );
    },

    '/doctorProfile': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return DoctorProfilePage(
        doctor: args['doctor'],
        doctorUid: args['doctorUid'],
      );
    },

    '/home': (context) => const HomePage(),

    '/mainDashboard': (context) => const PostLoginHomePage(),

    '/appointmentRequest': (context) => const AppointmentRequestPage(),

    '/patientProfile': (context) => const PatientProfilePage(),

    '/editPatientProfile': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return EditPatientProfilePage(initialData: args);
    },

    '/signupRoleGender': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return SignupRoleGenderPage(
        firstName: args['firstName'],
        lastName: args['lastName'],
        email: args['email'],
        password: args['password'],
      );
    },

    '/doctorSearch': (context) => const DoctorSearchPage(),

    '/myBookings': (context) => MyBookingsPage(),

    '/homeVisitBooking': (context) => const HomeVisitBookingPage(),

    '/doctorDashboard': (context) => const DoctorHomePage(),

    '/doctorMainDashboard': (context) => const DoctorModernHomePage(),

    '/doctorPatients': (context) => const DoctorPatientsPage(),

    '/doctorProfileSettings': (context) => const DoctorProfileSettingsPage(),

    '/medicineDelivery': (context) => const MedicineDeliveryPage(),

    '/pharmacistDashboard': (context) => const PharmacistHomePage(),

    '/pharmacistProfile': (context) => const PharmacistProfilePage(),
  };
}
