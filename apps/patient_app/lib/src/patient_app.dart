import 'package:flutter/material.dart';
import 'package:lokal_health_shared/lokal_health_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api/patient_backend_client.dart';

class PatientAppRoot extends StatelessWidget {
  const PatientAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lokal MedAssist Patient',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A6A58),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFEDE6D8),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Color(0xFFF6F0E5),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8F3EA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFC9C0B2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFC9C0B2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF0A6A58), width: 1.4),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      home: const PatientHomePage(),
    );
  }
}

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  static const _patientTokenKey = 'patient_auth_token';

  final DemoRepository _repository = DemoRepository();
  final PatientBackendClient _backendClient = PatientBackendClient();

  late PatientAppState _state;

  final TextEditingController _emailController =
      TextEditingController(text: 'suman.verma@lokal.demo');
  final TextEditingController _passwordController =
      TextEditingController(text: 'Pass@123');
  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _bookingConcernController = TextEditingController();
  final TextEditingController _profileNameController = TextEditingController();
  final TextEditingController _profileCityController = TextEditingController();
  final TextEditingController _profileHistoryController = TextEditingController();
  final TextEditingController _profileReportsController = TextEditingController();
  final TextEditingController _profileHeightController = TextEditingController();
  final TextEditingController _profileWeightController = TextEditingController();
  final TextEditingController _profileBloodController = TextEditingController();
  final TextEditingController _profileAllergiesController = TextEditingController();
  final TextEditingController _profileMedicationsController = TextEditingController();
  final TextEditingController _profileConditionsController = TextEditingController();
  final TextEditingController _profileEmergencyNameController =
      TextEditingController();
  final TextEditingController _profileEmergencyPhoneController =
      TextEditingController();

  int _currentIndex = 0;
  int _rating = 5;
  bool _chatLoading = false;
  bool _authLoading = false;
  bool _screenLoading = false;
  bool _bootLoading = true;
  bool _profileSaving = false;
  bool _languageSaving = false;
  String? _chatError;
  String? _authError;
  String? _token;
  String? _conversationId;
  PatientChatReply? _latestReply;
  List<ChatThread> _chatThreads = const [];
  List<AppointmentItem> _appointments = const [];
  List<PrescriptionItem> _prescriptions = const [];

  @override
  void initState() {
    super.initState();
    _state = _repository.initialPatientState();
    _syncProfileControllers(_state.patient);
    _restoreSession();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _chatController.dispose();
    _feedbackController.dispose();
    _bookingConcernController.dispose();
    _profileNameController.dispose();
    _profileCityController.dispose();
    _profileHistoryController.dispose();
    _profileReportsController.dispose();
    _profileHeightController.dispose();
    _profileWeightController.dispose();
    _profileBloodController.dispose();
    _profileAllergiesController.dispose();
    _profileMedicationsController.dispose();
    _profileConditionsController.dispose();
    _profileEmergencyNameController.dispose();
    _profileEmergencyPhoneController.dispose();
    super.dispose();
  }

  Language get _appLanguage => _state.patient.preferredLanguage;

  String _t(String key) {
    const translations = <Language, Map<String, String>>{
      Language.english: {
        'app_title': 'Lokal MedAssist',
        'menu_profile': 'User profile',
        'menu_personal': 'Personal data',
        'menu_history': 'Past consultations / visits',
        'menu_logout': 'Logout',
        'page_chat': 'AI Chat',
        'page_doctors': 'Doctors',
        'page_records': 'Records',
        'hello': 'Hello',
        'home_subtitle':
            'Use the menu for profile and history. Start from the quick actions below for chat, doctor help, records, and insurance.',
        'city': 'City',
        'language': 'Language',
        'consults': 'Consults',
        'quick_actions': 'Quick actions',
        'profile': 'Profile',
        'personal_data': 'Personal Data',
        'insurance': 'Insurance',
        'active_care': 'Active care',
        'doctor_assigned': 'Doctor assigned',
        'join_video': 'Join video call',
        'open_records': 'Open records',
        'health_snapshot': 'Health snapshot',
        'history': 'History',
        'no_history': 'No history saved',
        'current_meds': 'Current meds',
        'none_listed': 'None listed',
        'blood': 'Blood',
        'height': 'Height',
        'weight': 'Weight',
        'allergies': 'Allergies',
        'insurance_subtitle': 'Buy simple life insurance plans directly from the patient app.',
        'insurance_buy': 'Buy insurance',
        'personal_summary': 'Personal data summary',
        'reports': 'Reports',
        'no_reports': 'No reports uploaded',
        'chronic_conditions': 'Chronic conditions',
        'emergency_contact': 'Emergency contact',
        'not_saved': 'Not saved',
        'update_patient_details': 'Update patient details',
        'chat_title': 'AI medical assistant',
        'chat_subtitle':
            'Describe your symptoms simply. The assistant will guide you and suggest when to involve a doctor.',
        'generating': 'Generating triage response...',
        'triage_summary': 'Triage summary',
        'risk': 'Risk',
        'mode': 'Mode',
        'red_flag': 'Red flag',
        'no_red_flag': 'No red flag',
        'follow_up_questions': 'Suggested follow-up questions',
        'recent_conversations': 'Recent conversations',
        'chat_hint': 'Example: I have fever and cough since yesterday',
        'sending': 'Sending...',
        'ask': 'Ask',
        'doctor_consultations': 'Doctor consultations',
        'doctor_consultations_subtitle':
            'If AI guidance is not enough, choose a doctor, pay once, and join a 1:1 video consultation.',
        'current_consultation': 'Your current consultation',
        'what_consult': 'What would you like to consult for?',
        'online': 'Online',
        'offline': 'Offline',
        'fee': 'Fee',
        'queue': 'Queue',
        'rating': 'Rating',
        'pay_join_queue': 'Pay and join queue',
        'records_followup': 'Records and follow-up',
        'records_subtitle':
            'Your past consultations, prescriptions, appointments, and feedback stay linked to your profile.',
        'no_records': 'No records yet',
        'no_records_subtitle':
            'Bookings, appointments, prescriptions, and consultation summaries will appear here once created.',
        'doctor': 'Doctor',
        'follow_up': 'Follow-up',
        'prescription': 'Prescription',
        'pending_doctor_note': 'Pending doctor note',
        'clinic_visit': 'Clinic visit',
        'not_booked': 'Not booked',
        'open_video_room': 'Open video room',
        'book_follow_up': 'Book follow-up',
        'appointment': 'Appointment',
        'advice': 'Advice',
        'auth_title': 'Patient authentication',
        'auth_subtitle':
            'Sign in to use AI guidance, doctor booking, video consultation, records, and patient profile tools.',
        'email': 'Email',
        'password': 'Password',
        'signing_in': 'Signing in...',
        'sign_in': 'Sign in',
        'demo_credentials': 'Demo credentials',
        'signed_in': 'Signed in successfully.',
        'login_failed': 'Login failed. Check backend, email, and password.',
      },
      Language.hindi: {
        'app_title': 'लोकल मेडअसिस्ट',
        'menu_profile': 'उपयोगकर्ता प्रोफ़ाइल',
        'menu_personal': 'व्यक्तिगत डेटा',
        'menu_history': 'पिछली परामर्श / विज़िट',
        'menu_logout': 'लॉगआउट',
        'page_chat': 'एआई चैट',
        'page_doctors': 'डॉक्टर',
        'page_records': 'रिकॉर्ड्स',
        'hello': 'नमस्ते',
        'home_subtitle':
            'प्रोफ़ाइल और हिस्ट्री के लिए मेन्यू का उपयोग करें। नीचे दिए गए विकल्पों से चैट, डॉक्टर, रिकॉर्ड्स और इंश्योरेंस चुनें।',
        'city': 'शहर',
        'language': 'भाषा',
        'consults': 'परामर्श',
        'quick_actions': 'त्वरित विकल्प',
        'profile': 'प्रोफ़ाइल',
        'personal_data': 'व्यक्तिगत डेटा',
        'insurance': 'बीमा',
        'active_care': 'सक्रिय देखभाल',
        'doctor_assigned': 'डॉक्टर नियुक्त',
        'join_video': 'वीडियो कॉल जॉइन करें',
        'open_records': 'रिकॉर्ड्स खोलें',
        'health_snapshot': 'स्वास्थ्य सारांश',
        'history': 'इतिहास',
        'no_history': 'कोई इतिहास सुरक्षित नहीं',
        'current_meds': 'वर्तमान दवाइयाँ',
        'none_listed': 'कुछ सूचीबद्ध नहीं',
        'blood': 'ब्लड ग्रुप',
        'height': 'लंबाई',
        'weight': 'वज़न',
        'allergies': 'एलर्जी',
        'insurance_subtitle': 'मरीज ऐप से सीधे सरल जीवन बीमा योजनाएँ खरीदें।',
        'insurance_buy': 'बीमा खरीदें',
        'personal_summary': 'व्यक्तिगत डेटा सारांश',
        'reports': 'रिपोर्ट्स',
        'no_reports': 'कोई रिपोर्ट अपलोड नहीं',
        'chronic_conditions': 'दीर्घकालिक स्थितियाँ',
        'emergency_contact': 'आपातकालीन संपर्क',
        'not_saved': 'सहेजा नहीं गया',
        'update_patient_details': 'मरीज विवरण अपडेट करें',
        'chat_title': 'एआई मेडिकल सहायक',
        'chat_subtitle':
            'अपने लक्षण सरल भाषा में लिखें। सहायक मार्गदर्शन करेगा और बताएगा कि डॉक्टर की जरूरत है या नहीं।',
        'generating': 'ट्रायाज उत्तर तैयार हो रहा है...',
        'triage_summary': 'ट्रायाज सारांश',
        'risk': 'जोखिम',
        'mode': 'मोड',
        'red_flag': 'रेड फ्लैग',
        'no_red_flag': 'कोई रेड फ्लैग नहीं',
        'follow_up_questions': 'सुझाए गए फॉलो-अप प्रश्न',
        'recent_conversations': 'हाल की बातचीत',
        'chat_hint': 'उदाहरण: मुझे कल से बुखार और खांसी है',
        'sending': 'भेजा जा रहा है...',
        'ask': 'पूछें',
        'doctor_consultations': 'डॉक्टर परामर्श',
        'doctor_consultations_subtitle':
            'यदि एआई मार्गदर्शन पर्याप्त नहीं है, तो डॉक्टर चुनें, भुगतान करें और 1:1 वीडियो परामर्श से जुड़ें।',
        'current_consultation': 'आपका वर्तमान परामर्श',
        'what_consult': 'आप किस बारे में परामर्श चाहते हैं?',
        'online': 'ऑनलाइन',
        'offline': 'ऑफलाइन',
        'fee': 'फ़ीस',
        'queue': 'क्यू',
        'rating': 'रेटिंग',
        'pay_join_queue': 'भुगतान कर क्यू में जुड़ें',
        'records_followup': 'रिकॉर्ड्स और फॉलो-अप',
        'records_subtitle':
            'आपके पिछले परामर्श, प्रिस्क्रिप्शन, अपॉइंटमेंट और फीडबैक आपकी प्रोफ़ाइल से जुड़े रहते हैं।',
        'no_records': 'अभी कोई रिकॉर्ड नहीं',
        'no_records_subtitle':
            'बुकिंग, अपॉइंटमेंट, प्रिस्क्रिप्शन और परामर्श सारांश यहाँ दिखाई देंगे।',
        'doctor': 'डॉक्टर',
        'follow_up': 'फॉलो-अप',
        'prescription': 'प्रिस्क्रिप्शन',
        'pending_doctor_note': 'डॉक्टर की टिप्पणी लंबित है',
        'clinic_visit': 'क्लिनिक विज़िट',
        'not_booked': 'बुक नहीं किया गया',
        'open_video_room': 'वीडियो रूम खोलें',
        'book_follow_up': 'फॉलो-अप बुक करें',
        'appointment': 'अपॉइंटमेंट',
        'advice': 'सलाह',
        'auth_title': 'मरीज प्रमाणीकरण',
        'auth_subtitle':
            'एआई मार्गदर्शन, डॉक्टर बुकिंग, वीडियो परामर्श, रिकॉर्ड्स और प्रोफ़ाइल टूल्स के लिए साइन इन करें।',
        'email': 'ईमेल',
        'password': 'पासवर्ड',
        'signing_in': 'साइन इन हो रहा है...',
        'sign_in': 'साइन इन',
        'demo_credentials': 'डेमो क्रेडेंशियल्स',
        'signed_in': 'सफलतापूर्वक साइन इन हो गया।',
        'login_failed': 'लॉगिन विफल। बैकएंड, ईमेल और पासवर्ड जांचें।',
      },
      Language.marathi: {
        'app_title': 'लोकल मेडअसिस्ट',
        'menu_profile': 'वापरकर्ता प्रोफाइल',
        'menu_personal': 'वैयक्तिक माहिती',
        'menu_history': 'मागील सल्लामसलत / भेटी',
        'menu_logout': 'लॉगआउट',
        'page_chat': 'एआय चॅट',
        'page_doctors': 'डॉक्टर्स',
        'page_records': 'रेकॉर्ड्स',
        'hello': 'नमस्कार',
        'home_subtitle':
            'प्रोफाइल आणि इतिहासासाठी मेनू वापरा. खालील पर्यायांतून चॅट, डॉक्टर, रेकॉर्ड्स आणि इन्शुरन्स निवडा.',
        'city': 'शहर',
        'language': 'भाषा',
        'consults': 'सल्लामसलत',
        'quick_actions': 'त्वरित पर्याय',
        'profile': 'प्रोफाइल',
        'personal_data': 'वैयक्तिक माहिती',
        'insurance': 'विमा',
        'active_care': 'सक्रिय काळजी',
        'doctor_assigned': 'डॉक्टर नियुक्त',
        'join_video': 'व्हिडिओ कॉलमध्ये सामील व्हा',
        'open_records': 'रेकॉर्ड्स उघडा',
        'health_snapshot': 'आरोग्य सारांश',
        'history': 'इतिहास',
        'no_history': 'इतिहास जतन केलेला नाही',
        'current_meds': 'सध्याची औषधे',
        'none_listed': 'काही नोंदलेले नाही',
        'blood': 'ब्लड ग्रुप',
        'height': 'उंची',
        'weight': 'वजन',
        'allergies': 'अ‍ॅलर्जी',
        'insurance_subtitle': 'रुग्ण अॅपमधून सोपे जीवन विमा प्लॅन खरेदी करा.',
        'insurance_buy': 'विमा खरेदी करा',
        'personal_summary': 'वैयक्तिक माहिती सारांश',
        'reports': 'रिपोर्ट्स',
        'no_reports': 'कोणतेही रिपोर्ट्स अपलोड नाहीत',
        'chronic_conditions': 'दीर्घकालीन स्थिती',
        'emergency_contact': 'आपत्कालीन संपर्क',
        'not_saved': 'जतन केलेले नाही',
        'update_patient_details': 'रुग्ण तपशील अपडेट करा',
        'chat_title': 'एआय वैद्यकीय सहाय्यक',
        'chat_subtitle':
            'आपली लक्षणे सोप्या भाषेत लिहा. सहाय्यक मार्गदर्शन करेल आणि डॉक्टरची गरज असल्यास सुचवेल.',
        'generating': 'ट्रायाज प्रतिसाद तयार होत आहे...',
        'triage_summary': 'ट्रायाज सारांश',
        'risk': 'जोखीम',
        'mode': 'मोड',
        'red_flag': 'रेड फ्लॅग',
        'no_red_flag': 'रेड फ्लॅग नाही',
        'follow_up_questions': 'सुचवलेले फॉलो-अप प्रश्न',
        'recent_conversations': 'अलीकडील संभाषणे',
        'chat_hint': 'उदाहरण: मला कालपासून ताप आणि खोकला आहे',
        'sending': 'पाठवत आहे...',
        'ask': 'विचारा',
        'doctor_consultations': 'डॉक्टर सल्लामसलत',
        'doctor_consultations_subtitle':
            'एआय मार्गदर्शन पुरेसे नसल्यास डॉक्टर निवडा, पैसे भरा आणि 1:1 व्हिडिओ सल्लामसलतीत सामील व्हा.',
        'current_consultation': 'तुमची चालू सल्लामसलत',
        'what_consult': 'तुम्हाला कोणत्या बाबतीत सल्ला हवा आहे?',
        'online': 'ऑनलाइन',
        'offline': 'ऑफलाइन',
        'fee': 'फी',
        'queue': 'रांग',
        'rating': 'रेटिंग',
        'pay_join_queue': 'पैसे भरून रांगेत सामील व्हा',
        'records_followup': 'रेकॉर्ड्स आणि फॉलो-अप',
        'records_subtitle':
            'तुमच्या मागील सल्लामसलती, प्रिस्क्रिप्शन, अपॉइंटमेंट्स आणि फीडबॅक तुमच्या प्रोफाइलशी जोडलेले राहतात.',
        'no_records': 'अजून रेकॉर्ड्स नाहीत',
        'no_records_subtitle':
            'बुकिंग, अपॉइंटमेंट, प्रिस्क्रिप्शन आणि सल्लामसलत सारांश येथे दिसतील.',
        'doctor': 'डॉक्टर',
        'follow_up': 'फॉलो-अप',
        'prescription': 'प्रिस्क्रिप्शन',
        'pending_doctor_note': 'डॉक्टरची नोंद प्रलंबित आहे',
        'clinic_visit': 'क्लिनिक भेट',
        'not_booked': 'बुक केलेले नाही',
        'open_video_room': 'व्हिडिओ रूम उघडा',
        'book_follow_up': 'फॉलो-अप बुक करा',
        'appointment': 'अपॉइंटमेंट',
        'advice': 'सल्ला',
        'auth_title': 'रुग्ण प्रमाणीकरण',
        'auth_subtitle':
            'एआय मार्गदर्शन, डॉक्टर बुकिंग, व्हिडिओ सल्लामसलत, रेकॉर्ड्स आणि प्रोफाइल साधनांसाठी साइन इन करा.',
        'email': 'ईमेल',
        'password': 'पासवर्ड',
        'signing_in': 'साइन इन होत आहे...',
        'sign_in': 'साइन इन',
        'demo_credentials': 'डेमो क्रेडेन्शियल्स',
        'signed_in': 'यशस्वीरीत्या साइन इन झाले.',
        'login_failed': 'लॉगिन अयशस्वी. बॅकएंड, ईमेल आणि पासवर्ड तपासा.',
      },
    };
    return translations[_appLanguage]?[key] ?? translations[Language.english]![key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    if (_bootLoading) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_token == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Patient Login')),
        body: SafeArea(child: _buildAuthScreen()),
      );
    }

    final pages = [
      _buildOverview(),
      _buildChat(),
      _buildDoctors(),
      _buildRecords(),
    ];
    final pageTitles = [
      _t('app_title'),
      _t('page_chat'),
      _t('page_doctors'),
      _t('page_records'),
    ];

    return Scaffold(
      drawer: _buildAppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: _currentIndex == 0
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _currentIndex = 0),
              ),
        title: Text(pageTitles[_currentIndex]),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          _LanguageSelector(
            currentLanguage: _state.patient.preferredLanguage,
            disabled: _languageSaving,
            onSelected: _changePreferredLanguage,
          ),
          IconButton(
            onPressed: _screenLoading ? null : _refreshBackendData,
            icon: const Icon(Icons.refresh),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _state.patient.patientId,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF2EADF), Color(0xFFE1D3BF)],
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: pages[_currentIndex],
          ),
        ),
      ),
    );
  }

  Widget _buildOverview() {
    final patient = _state.patient;
    final metadata = patient.metadata;
    final activeConsultation = _activeConsultation();

    return ListView(
      key: const ValueKey('overview'),
      padding: const EdgeInsets.all(16),
      children: [
        _HeroCard(
          title: '${_t('hello')}, ${patient.name.split(' ').first}',
          subtitle: _t('home_subtitle'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MetricChip(label: _t('city'), value: patient.city),
                  _MetricChip(label: _t('language'), value: languageLabel(patient.preferredLanguage)),
                  _MetricChip(label: _t('consults'), value: '${patient.previousConsultations}'),
                  _MetricChip(label: 'BMI', value: '${patient.bmi}'),
                ],
              ),
            ],
          ),
        ),
        _SectionCard(
          title: _t('quick_actions'),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.92,
            children: [
              _HomeActionTile(
                icon: Icons.chat_bubble_outline,
                label: _t('page_chat'),
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _HomeActionTile(
                icon: Icons.local_hospital_outlined,
                label: _t('page_doctors'),
                onTap: () => setState(() => _currentIndex = 2),
              ),
              _HomeActionTile(
                icon: Icons.folder_open_outlined,
                label: _t('page_records'),
                onTap: () => setState(() => _currentIndex = 3),
              ),
              _HomeActionTile(
                icon: Icons.person_outline,
                label: _t('profile'),
                onTap: _showUserProfileSheet,
              ),
              _HomeActionTile(
                icon: Icons.badge_outlined,
                label: _t('personal_data'),
                onTap: _showProfileEditor,
              ),
              _HomeActionTile(
                icon: Icons.shield_outlined,
                label: _t('insurance'),
                onTap: _showInsuranceSheet,
              ),
            ],
          ),
        ),
        if (_screenLoading)
          const _NoticeBanner(
            tone: NoticeTone.info,
            text: 'Refreshing backend data...',
          ),
        if (activeConsultation != null)
          _SectionCard(
            title: _t('active_care'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activeConsultation.concern,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusPill(label: activeConsultation.status.name, highlighted: true),
                    _StatusPill(label: activeConsultation.doctorName ?? _t('doctor_assigned')),
                    if (activeConsultation.videoSession != null)
                      _StatusPill(
                        label: 'Video ${activeConsultation.videoSession!.status.toLowerCase()}',
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  activeConsultation.videoSession != null
                      ? (_appLanguage == Language.english
                          ? 'Your consultation room is ready. You can join directly from the app.'
                          : _appLanguage == Language.hindi
                              ? 'आपका परामर्श कक्ष तैयार है। आप ऐप से सीधे जुड़ सकते हैं।'
                              : 'तुमची सल्लामसलत रूम तयार आहे. तुम्ही अॅपमधून थेट जॉइन करू शकता.')
                      : (_appLanguage == Language.english
                          ? 'Your consultation is booked. The room will be prepared when the doctor is ready.'
                          : _appLanguage == Language.hindi
                              ? 'आपका परामर्श बुक हो गया है। डॉक्टर तैयार होने पर रूम तैयार किया जाएगा।'
                              : 'तुमची सल्लामसलत बुक झाली आहे. डॉक्टर तयार झाल्यावर रूम तयार होईल.'),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _joinConsultation(activeConsultation),
                      icon: const Icon(Icons.videocam_outlined),
                      label: Text(_t('join_video')),
                    ),
                    FilledButton.tonal(
                      onPressed: () => setState(() => _currentIndex = 3),
                      child: Text(_t('open_records')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        _SectionCard(
          title: _t('health_snapshot'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${patient.name}, ${patient.age} years, ${patient.sex}'),
              const SizedBox(height: 8),
              Text(
                '${_t('history')}: ${patient.medicalHistory.isEmpty ? _t('no_history') : patient.medicalHistory.join(', ')}',
              ),
              const SizedBox(height: 8),
              Text(
                '${_t('current_meds')}: ${metadata.currentMedications.isEmpty ? _t('none_listed') : metadata.currentMedications.join(', ')}',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (metadata.bloodGroup != null)
                    _StatusPill(label: '${_t('blood')} ${metadata.bloodGroup}'),
                  if (metadata.heightCm != null)
                    _StatusPill(
                      label: '${_t('height')} ${metadata.heightCm!.toStringAsFixed(0)} cm',
                    ),
                  if (metadata.weightKg != null)
                    _StatusPill(
                      label: '${_t('weight')} ${metadata.weightKg!.toStringAsFixed(0)} kg',
                    ),
                  if (metadata.allergies.isNotEmpty)
                    _StatusPill(label: '${_t('allergies')} ${metadata.allergies.length}'),
                ],
              ),
            ],
          ),
        ),
        _SectionCard(
          title: _t('insurance'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_t('insurance_subtitle')),
              const SizedBox(height: 14),
              _InsuranceTile(
                title: 'Life Secure Basic',
                subtitle: 'Affordable life cover for individuals',
                price: 'Starting Rs 299/month',
                onTap: () => _buyInsurance('Life Secure Basic'),
              ),
              const SizedBox(height: 10),
              _InsuranceTile(
                title: 'Family Shield Plus',
                subtitle: 'Life cover for spouse and dependents',
                price: 'Starting Rs 699/month',
                onTap: () => _buyInsurance('Family Shield Plus'),
              ),
            ],
          ),
        ),
        _SectionCard(
          title: _t('personal_summary'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                label: _t('reports'),
                value: patient.reports.isEmpty ? _t('no_reports') : patient.reports.join(', '),
              ),
              _InfoRow(
                label: _t('allergies'),
                value: metadata.allergies.isEmpty ? _t('none_listed') : metadata.allergies.join(', '),
              ),
              _InfoRow(
                label: _t('chronic_conditions'),
                value: metadata.chronicConditions.isEmpty
                    ? _t('none_listed')
                    : metadata.chronicConditions.join(', '),
              ),
              _InfoRow(
                label: _t('emergency_contact'),
                value: metadata.emergencyContactName == null
                    ? _t('not_saved')
                    : '${metadata.emergencyContactName} • ${metadata.emergencyContactPhone ?? ''}',
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: _showProfileEditor,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(_t('update_patient_details')),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Drawer _buildAppDrawer() {
    final patient = _state.patient;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              decoration: const BoxDecoration(color: Color(0xFFD7E7DF)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFF0D8C74),
                    child: Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    patient.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    patient.patientId,
                    style: const TextStyle(color: Color(0xFF5D574E)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerTile(
                    icon: Icons.person_outline,
                    label: _t('menu_profile'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showUserProfileSheet();
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.badge_outlined,
                    label: _t('menu_personal'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showProfileEditor();
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.history_outlined,
                    label: _t('menu_history'),
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() => _currentIndex = 3);
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.logout,
                    label: _t('menu_logout'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _logout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChat() {
    return Column(
      key: const ValueKey('chat'),
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshBackendData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionHeader(
                  title: _t('chat_title'),
                  subtitle: _t('chat_subtitle'),
                ),
                ..._state.chat.map((message) {
                  final isAssistant = message.sender == 'assistant';
                  return _ChatBubble(
                    isAssistant: isAssistant,
                    text: message.text,
                  );
                }),
                if (_chatLoading)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(label: Text(_t('generating'))),
                    ),
                  ),
                if (_chatError != null)
                  _NoticeBanner(
                    tone: NoticeTone.error,
                    text: _chatError!,
                  ),
                if (_latestReply != null)
                  _SectionCard(
                    title: _t('triage_summary'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _StatusPill(label: '${_t('risk')} ${_latestReply!.riskLevel}'),
                            _StatusPill(label: '${_t('mode')} ${_latestReply!.careMode}'),
                            _StatusPill(
                              label:
                                  _latestReply!.redFlagDetected ? _t('red_flag') : _t('no_red_flag'),
                              highlighted: _latestReply!.redFlagDetected,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(_latestReply!.doctorSummary),
                        if (_latestReply!.followUpQuestions.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            _t('follow_up_questions'),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          ..._latestReply!.followUpQuestions.map((item) => Text('• $item')),
                        ],
                      ],
                    ),
                  ),
                if (_chatThreads.isNotEmpty)
                  _SectionCard(
                    title: _t('recent_conversations'),
                    child: Column(
                      children: _chatThreads.take(4).map((thread) {
                        final selected = _conversationId == thread.conversationId;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFD7E9E1)
                                : const Color(0xFFEEE6D9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            title: Text(thread.title),
                            subtitle: Text('${thread.messages.length} messages'),
                            trailing: Text(
                              '${thread.updatedAt.hour.toString().padLeft(2, '0')}:${thread.updatedAt.minute.toString().padLeft(2, '0')}',
                            ),
                            onTap: () {
                              setState(() {
                                _conversationId = thread.conversationId;
                                _state = _state.copyWith(chat: thread.messages);
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: _t('chat_hint'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: _chatLoading ? null : _sendChat,
                child: Text(_chatLoading ? _t('sending') : _t('ask')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoctors() {
    final activeVideoConsultation = _activeConsultation();

    return ListView(
      key: const ValueKey('doctors'),
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(
          title: _t('doctor_consultations'),
          subtitle: _t('doctor_consultations_subtitle'),
        ),
        if (activeVideoConsultation != null)
          _SectionCard(
            title: _t('current_consultation'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${activeVideoConsultation.doctorName ?? activeVideoConsultation.doctorId} • ${activeVideoConsultation.concern}',
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusPill(label: activeVideoConsultation.status.name, highlighted: true),
                    if (activeVideoConsultation.videoSession != null)
                      _StatusPill(
                    label: 'Video ${activeVideoConsultation.videoSession!.status.toLowerCase()}',
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _joinConsultation(activeVideoConsultation),
                    icon: const Icon(Icons.videocam_outlined),
                    label: Text(_t('join_video')),
                  ),
                ),
              ],
            ),
          ),
        TextField(
          controller: _bookingConcernController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: _t('what_consult'),
          ),
        ),
        const SizedBox(height: 14),
        ..._state.doctors.map(
          (doctor) => Card(
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9E5EE),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.local_hospital_outlined),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text('${doctor.specialty} • ${doctor.experienceYears} yrs'),
                            const SizedBox(height: 6),
                            Text(
                              doctor.languages.map(languageLabel).join(' / '),
                              style: const TextStyle(color: Color(0xFF564F47)),
                            ),
                          ],
                        ),
                      ),
                      _StatusPill(
                        label: doctor.online ? _t('online') : _t('offline'),
                        highlighted: doctor.online,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniInfoCard(
                          label: _t('fee'),
                          value: 'Rs ${doctor.fee}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MiniInfoCard(
                          label: _t('queue'),
                          value: '${doctor.queueCount}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MiniInfoCard(
                          label: _t('rating'),
                          value: '${doctor.rating}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: doctor.online && _token != null ? () => _bookDoctor(doctor) : null,
                      child: Text(_t('pay_join_queue')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecords() {
    return ListView(
      key: const ValueKey('records'),
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(
          title: _t('records_followup'),
          subtitle: _t('records_subtitle'),
        ),
        if (_state.consultations.isEmpty)
          _SectionCard(
            title: _t('no_records'),
            child: Text(
              _t('no_records_subtitle'),
            ),
          )
        else
          ..._state.consultations.map((consultation) {
            return _SectionCard(
              title: consultation.concern,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_t('doctor')}: ${consultation.doctorName ?? consultation.doctorId}'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatusPill(label: consultation.status.name),
                      _StatusPill(label: consultation.recommendedMode),
                      if (consultation.followUpRequired)
                        _StatusPill(label: _t('follow_up')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_t('prescription')}: ${consultation.prescription ?? _t('pending_doctor_note')}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_t('clinic_visit')}: ${consultation.clinicVisitDate ?? _t('not_booked')} ${consultation.clinicVisitSlot ?? ''}',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.tonal(
                        onPressed: consultation.recommendedMode == 'VIDEO_CALL'
                            ? () => _joinConsultation(consultation)
                            : null,
                        child: Text(_t('open_video_room')),
                      ),
                      FilledButton.tonal(
                        onPressed: () => _scheduleFollowUp(consultation),
                        child: Text(_t('book_follow_up')),
                      ),
                    ],
                  ),
                  if (_prescriptions
                      .where((item) => item.consultationId == consultation.id)
                      .isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 4),
                    ..._prescriptions
                        .where((item) => item.consultationId == consultation.id)
                        .map(
                          (prescription) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_t('advice')}: ${prescription.advice}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                ...prescription.medicines.map(
                                  (medicine) => Text(
                                    '• ${medicine['name']} • ${medicine['dosage']} • ${medicine['frequency']}',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                  if (_appointments
                      .where((item) => item.consultationId == consultation.id)
                      .isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ..._appointments
                        .where((item) => item.consultationId == consultation.id)
                        .map(
                          (appointment) => Text(
                            '${_t('appointment')}: ${appointment.date} • ${appointment.slot} • ${appointment.clinicName}',
                          ),
                        ),
                  ],
                  const SizedBox(height: 14),
                  _FeedbackComposer(
                    rating: _rating,
                    controller: _feedbackController,
                    onRatingChanged: (value) => setState(() => _rating = value),
                    onSubmit: () => _submitFeedback(consultation),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildAuthScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeroCard(
          title: _t('auth_title'),
          subtitle: _t('auth_subtitle'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: _t('email')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: _t('password')),
              ),
              const SizedBox(height: 12),
              if (_authError != null) Text(_authError!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _authLoading ? null : _login,
                  child: Text(_authLoading ? _t('signing_in') : _t('sign_in')),
                ),
              ),
              const SizedBox(height: 8),
              Text('${_t('demo_credentials')}: suman.verma@lokal.demo / Pass@123'),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _login() async {
    setState(() {
      _authLoading = true;
      _authError = null;
    });

    try {
      final session = await _backendClient.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      _token = session.token;
      _state = _state.copyWith(patient: session.patient);
      _syncProfileControllers(session.patient);
      await _refreshBackendData();
      if (!mounted) return;
      setState(() {
        _authLoading = false;
      });
      await _persistToken(session.token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('signed_in'))),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _authLoading = false;
        _authError = _t('login_failed');
      });
    }
  }

  Future<void> _refreshBackendData() async {
    final token = _token;
    if (token == null) return;

    setState(() {
      _screenLoading = true;
    });

    try {
      final patient = await _backendClient.fetchMe(token);
      final doctors = await _backendClient.fetchDoctors();
      final chats = await _backendClient.fetchChats(token);
      final bookings = await _backendClient.fetchBookings(token);
      final appointments = await _backendClient.fetchAppointments(token);
      final prescriptions = await _backendClient.fetchPrescriptions(token);
      if (!mounted) return;
      setState(() {
        _state = _state.copyWith(
          patient: patient,
          doctors: doctors,
          chat: chats.isNotEmpty ? chats.first.messages : _state.chat,
          consultations: bookings,
        );
        _chatThreads = chats;
        _conversationId = chats.isNotEmpty ? chats.first.conversationId : _conversationId;
        _appointments = appointments;
        _prescriptions = prescriptions;
        _screenLoading = false;
      });
      _syncProfileControllers(patient);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _screenLoading = false;
      });
    }
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_patientTokenKey);

    if (savedToken == null) {
      if (!mounted) return;
      setState(() {
        _bootLoading = false;
      });
      return;
    }

    _token = savedToken;
    await _refreshBackendData();
    if (!mounted) return;
    setState(() {
      _bootLoading = false;
    });
  }

  Future<void> _persistToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_patientTokenKey, token);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_patientTokenKey);
    if (!mounted) return;
    setState(() {
      _token = null;
      _conversationId = null;
      _latestReply = null;
      _chatThreads = const [];
      _appointments = const [];
      _prescriptions = const [];
      _state = _repository.initialPatientState();
      _currentIndex = 0;
    });
    _syncProfileControllers(_state.patient);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signed out.')),
    );
  }

  Future<void> _sendChat() async {
    final text = _chatController.text.trim();
    final token = _token;
    if (text.isEmpty || token == null) {
      return;
    }

    setState(() {
      _state = _repository.addChat(_state, _repository.patientMessage(text));
      _chatLoading = true;
      _chatError = null;
      _chatController.clear();
    });

    try {
      final reply = await _backendClient.sendChat(
        token: token,
        message: text,
        patient: _state.patient,
        conversationId: _conversationId,
      );

      if (!mounted) return;

      setState(() {
        _state = _repository.addChat(
          _state,
          ChatMessage(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            sender: 'assistant',
            text: reply.assistantMessage,
            createdAt: DateTime.now(),
          ),
        );
        _latestReply = reply;
        _conversationId = reply.conversationId;
        _chatLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _chatLoading = false;
        _chatError =
            'Could not reach the patient backend. Start it on your Mac and keep the emulator pointed at http://10.0.2.2:8080.';
      });
    }
  }

  void _bookDoctor(DoctorProfile doctor) {
    final token = _token;
    if (token == null) return;

    final concern = _bookingConcernController.text.trim().isEmpty
        ? (_latestReply?.doctorSummary.isNotEmpty == true
            ? _latestReply!.doctorSummary
            : 'General consultation requested')
        : _bookingConcernController.text.trim();

    _backendClient
        .createBooking(
          token: token,
          doctorId: doctor.doctorId,
          concern: concern,
        )
        .then((consultation) {
          setState(() {
            _state = _state.copyWith(
              consultations: [consultation, ..._state.consultations],
            );
          });
          return _refreshBackendData();
        })
        .then((_) {
          if (!mounted) return;
          setState(() {
            _currentIndex = 3;
            _bookingConcernController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booked ${doctor.name}. Payment captured before consultation.')),
          );
        })
        .catchError((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking failed. Check backend status.')),
          );
        });
  }

  Future<void> _joinConsultation(ConsultationRecord consultation) async {
    final token = _token;
    if (token == null) return;

    try {
      var nextConsultation = consultation;
      if (consultation.videoSession == null || consultation.videoSession!.joinUrl.isEmpty) {
        nextConsultation = await _backendClient.prepareVideoSession(
          token: token,
          consultationId: consultation.id,
        );
      }

      if (!mounted) return;
      setState(() {
        _state = _state.copyWith(
          consultations: _state.consultations
              .map((item) => item.id == nextConsultation.id ? nextConsultation : item)
              .toList(),
        );
      });

      final joinUrl = nextConsultation.videoSession?.joinUrl;
      if (joinUrl == null || joinUrl.isEmpty) {
        throw Exception('missing_join_url');
      }

      final launched = await launchUrl(
        Uri.parse(joinUrl),
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open video session on this device.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not prepare the video consultation.')),
      );
    }
  }

  void _scheduleFollowUp(ConsultationRecord consultation) {
    final token = _token;
    if (token == null) return;

    _backendClient
        .createAppointment(
          token: token,
          consultationId: consultation.id,
          doctorId: consultation.doctorId,
          date: '2026-04-05',
          slot: '12:15 PM',
          clinicName: 'Lokal Health Clinic - Kanpur Central',
        )
        .then((_) => _refreshBackendData())
        .then((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Physical follow-up booked.')),
          );
        })
        .catchError((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Follow-up booking failed.')),
          );
        });
  }

  void _submitFeedback(ConsultationRecord consultation) {
    final token = _token;
    final note = _feedbackController.text.trim();
    if (note.isEmpty || token == null) {
      return;
    }

    _backendClient
        .submitFeedback(
          token: token,
          consultationId: consultation.id,
          doctorId: consultation.doctorId,
          rating: _rating,
          note: note,
        )
        .then((_) => _refreshBackendData())
        .then((_) {
          if (!mounted) return;
          setState(() {
            _feedbackController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feedback submitted.')),
          );
        })
        .catchError((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feedback submission failed.')),
          );
        });
  }

  Future<void> _showProfileEditor() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.88,
            decoration: const BoxDecoration(
              color: Color(0xFFF0E7DA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 52,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBAAF9E),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Update patient details',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Keep your medical profile current so triage and consultations are more useful.',
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _profileNameController,
                              decoration: const InputDecoration(labelText: 'Patient name'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _profileCityController,
                              decoration: const InputDecoration(labelText: 'City'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _profileHeightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Height (cm)'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _profileWeightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Weight (kg)'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _profileBloodController,
                              decoration: const InputDecoration(labelText: 'Blood group'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _profileHistoryController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Medical history',
                          hintText: 'Comma separated',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _profileReportsController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Reports',
                          hintText: 'Comma separated',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _profileAllergiesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Allergies',
                          hintText: 'Comma separated',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _profileMedicationsController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Current medications',
                          hintText: 'Comma separated',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _profileConditionsController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Chronic conditions',
                          hintText: 'Comma separated',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _profileEmergencyNameController,
                              decoration: const InputDecoration(
                                labelText: 'Emergency contact name',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _profileEmergencyPhoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Emergency contact phone',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _profileSaving
                              ? null
                              : () async {
                                  await _saveProfile();
                                  if (!mounted) return;
                                  Navigator.of(context).pop();
                                },
                          child: Text(
                            _profileSaving ? 'Saving...' : 'Save patient details',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showUserProfileSheet() async {
    final patient = _state.patient;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF0E7DA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 52,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBAAF9E),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _t('menu_profile'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(label: 'Name', value: patient.name),
                  _InfoRow(label: 'Patient ID', value: patient.patientId),
                  _InfoRow(label: 'City', value: patient.city),
                  _InfoRow(
                    label: 'Preferred language',
                    value: languageLabel(patient.preferredLanguage),
                  ),
                  _InfoRow(
                    label: 'Completed consultations',
                    value: '${patient.previousConsultations}',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showInsuranceSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF0E7DA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 52,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBAAF9E),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _t('insurance'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(_t('insurance_subtitle')),
                  const SizedBox(height: 16),
                  _InsuranceTile(
                    title: 'Life Secure Basic',
                    subtitle: 'Essential life cover for individuals',
                    price: 'Rs 299/month',
                    onTap: () => _buyInsurance('Life Secure Basic'),
                  ),
                  const SizedBox(height: 10),
                  _InsuranceTile(
                    title: 'Family Shield Plus',
                    subtitle: 'Life cover for family dependents',
                    price: 'Rs 699/month',
                    onTap: () => _buyInsurance('Family Shield Plus'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _buyInsurance(String planName) {
    Navigator.of(context, rootNavigator: true).maybePop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$planName selected. Insurance checkout can be connected next.')),
    );
  }

  Future<void> _saveProfile() async {
    final token = _token;
    if (token == null) return;

    final updatedPatient = _state.patient.copyWith(
      name: _profileNameController.text.trim().isEmpty
          ? _state.patient.name
          : _profileNameController.text.trim(),
      city: _profileCityController.text.trim().isEmpty
          ? _state.patient.city
          : _profileCityController.text.trim(),
      medicalHistory: _splitCsv(_profileHistoryController.text),
      reports: _splitCsv(_profileReportsController.text),
      metadata: _state.patient.metadata.copyWith(
        heightCm: double.tryParse(_profileHeightController.text.trim()),
        weightKg: double.tryParse(_profileWeightController.text.trim()),
        bloodGroup: _profileBloodController.text.trim().isEmpty
            ? null
            : _profileBloodController.text.trim(),
        allergies: _splitCsv(_profileAllergiesController.text),
        currentMedications: _splitCsv(_profileMedicationsController.text),
        chronicConditions: _splitCsv(_profileConditionsController.text),
        emergencyContactName: _profileEmergencyNameController.text.trim().isEmpty
            ? null
            : _profileEmergencyNameController.text.trim(),
        emergencyContactPhone: _profileEmergencyPhoneController.text.trim().isEmpty
            ? null
            : _profileEmergencyPhoneController.text.trim(),
      ),
    );

    setState(() {
      _profileSaving = true;
    });

    try {
      final savedPatient = await _backendClient.updateProfile(
        token: token,
        patient: updatedPatient,
      );
      if (!mounted) return;
      setState(() {
        _state = _state.copyWith(patient: savedPatient);
        _profileSaving = false;
      });
      _syncProfileControllers(savedPatient);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient metadata updated.')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _profileSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save patient metadata.')),
      );
    }
  }

  Future<void> _changePreferredLanguage(Language language) async {
    if (_token == null || _languageSaving || language == _state.patient.preferredLanguage) {
      return;
    }

    final previousLanguage = _state.patient.preferredLanguage;
    final updatedPatient = _state.patient.copyWith(preferredLanguage: language);

    setState(() {
      _languageSaving = true;
      _state = _state.copyWith(patient: updatedPatient);
    });

    try {
      final savedPatient = await _backendClient.updateProfile(
        token: _token!,
        patient: updatedPatient,
      );
      if (!mounted) return;
      setState(() {
        _languageSaving = false;
        _state = _state.copyWith(patient: savedPatient);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Language updated to ${_displayLanguage(savedPatient.preferredLanguage)}.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _languageSaving = false;
        _state = _state.copyWith(
          patient: _state.patient.copyWith(
            preferredLanguage: previousLanguage,
          ),
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not update language right now. Please sign out and sign in again once if you recently switched backend or app build.',
          ),
        ),
      );
    }
  }

  String _displayLanguage(Language language) {
    switch (language) {
      case Language.english:
        return 'English';
      case Language.hindi:
        return 'हिंदी';
      case Language.marathi:
        return 'मराठी';
    }
  }

  ConsultationRecord? _activeConsultation() {
    for (final item in _state.consultations) {
      if (item.recommendedMode == 'VIDEO_CALL' &&
          (item.status == ConsultationStatus.queued ||
              item.status == ConsultationStatus.inCall ||
              item.status == ConsultationStatus.followUp)) {
        return item;
      }
    }
    return null;
  }

  List<String> _splitCsv(String input) {
    return input
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  void _syncProfileControllers(PatientProfile patient) {
    _profileNameController.text = patient.name;
    _profileCityController.text = patient.city;
    _profileReportsController.text = patient.reports.join(', ');
    _profileHistoryController.text = patient.medicalHistory.join(', ');
    _profileHeightController.text =
        patient.metadata.heightCm != null ? patient.metadata.heightCm!.toString() : '';
    _profileWeightController.text =
        patient.metadata.weightKg != null ? patient.metadata.weightKg!.toString() : '';
    _profileBloodController.text = patient.metadata.bloodGroup ?? '';
    _profileAllergiesController.text = patient.metadata.allergies.join(', ');
    _profileMedicationsController.text = patient.metadata.currentMedications.join(', ');
    _profileConditionsController.text = patient.metadata.chronicConditions.join(', ');
    _profileEmergencyNameController.text = patient.metadata.emergencyContactName ?? '';
    _profileEmergencyPhoneController.text = patient.metadata.emergencyContactPhone ?? '';
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text(subtitle),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD4E8E0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(subtitle),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    this.highlighted = false,
  });

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFCFE8DE) : const Color(0xFFE5DDD0),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: highlighted ? const Color(0xFF0D8C74) : const Color(0xFF5D574E),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.isAssistant,
    required this.text,
  });

  final bool isAssistant;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isAssistant ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isAssistant ? Colors.white : const Color(0xFFCFE7DF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Text(text),
      ),
    );
  }
}

class _HomeActionTile extends StatelessWidget {
  const _HomeActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEEE6D9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD3C8B8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFD5E6DE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF0D8C74)),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0D8C74)),
      title: Text(label),
      onTap: onTap,
    );
  }
}

class _InsuranceTile extends StatelessWidget {
  const _InsuranceTile({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEE6D9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD3C7B8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFD5E6DE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.shield_outlined, color: Color(0xFF0D8C74)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Color(0xFF564F47)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(price, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: onTap,
              child: const Text('Buy insurance'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.currentLanguage,
    required this.onSelected,
    this.disabled = false,
  });

  final Language currentLanguage;
  final ValueChanged<Language> onSelected;
  final bool disabled;

  String _label(Language language) {
    switch (language) {
      case Language.english:
        return 'EN';
      case Language.hindi:
        return 'हिं';
      case Language.marathi:
        return 'मर';
    }
  }

  String _menuLabel(Language language) {
    switch (language) {
      case Language.english:
        return 'English';
      case Language.hindi:
        return 'हिंदी';
      case Language.marathi:
        return 'मराठी';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Language>(
      enabled: !disabled,
      tooltip: 'Select language',
      onSelected: onSelected,
      itemBuilder: (context) => Language.values
          .map(
            (language) => PopupMenuItem<Language>(
              value: language,
              child: Text(_menuLabel(language)),
            ),
          )
          .toList(),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEEE6D9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCEC3B3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 18, color: Color(0xFF0D8C74)),
            const SizedBox(width: 6),
            Text(
              _label(currentLanguage),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }
}

class _MiniInfoCard extends StatelessWidget {
  const _MiniInfoCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEE6D9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}

class _FeedbackComposer extends StatelessWidget {
  const _FeedbackComposer({
    required this.rating,
    required this.controller,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  final int rating;
  final TextEditingController controller;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rate this consultation',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        DropdownButton<int>(
          value: rating,
          items: const [5, 4, 3, 2, 1]
              .map((item) => DropdownMenuItem<int>(value: item, child: Text('$item Star')))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onRatingChanged(value);
            }
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Share feedback about the consultation',
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: onSubmit,
          child: const Text('Submit feedback'),
        ),
      ],
    );
  }
}

enum NoticeTone { info, error }

class _NoticeBanner extends StatelessWidget {
  const _NoticeBanner({
    required this.tone,
    required this.text,
  });

  final NoticeTone tone;
  final String text;

  @override
  Widget build(BuildContext context) {
    final background =
        tone == NoticeTone.error ? const Color(0xFFFFEFEA) : const Color(0xFFDCE8F0);
    final foreground =
        tone == NoticeTone.error ? const Color(0xFFAF4E33) : const Color(0xFF245F8A);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(color: foreground, fontWeight: FontWeight.w500),
      ),
    );
  }
}
