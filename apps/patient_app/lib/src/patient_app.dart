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
          seedColor: const Color(0xFF0D8C74),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F4EC),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFD8D4CB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFD8D4CB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF0D8C74), width: 1.4),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient App'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _screenLoading ? null : _refreshBackendData,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
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
              colors: [Color(0xFFF9F5ED), Color(0xFFF2E9D7)],
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: pages[_currentIndex],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) => setState(() => _currentIndex = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'AI Chat'),
          NavigationDestination(icon: Icon(Icons.video_call_outlined), label: 'Doctors'),
          NavigationDestination(icon: Icon(Icons.folder_open_outlined), label: 'Records'),
        ],
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
          title: 'Medical help in your language',
          subtitle:
              'Start with AI guidance, escalate to a doctor, join a video call, and keep your care history in one place.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MetricChip(label: 'City', value: patient.city),
                  _MetricChip(label: 'Language', value: languageLabel(patient.preferredLanguage)),
                  _MetricChip(label: 'Consults', value: '${patient.previousConsultations}'),
                  _MetricChip(label: 'BMI', value: '${patient.bmi}'),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _QuickActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Ask AI',
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  _QuickActionButton(
                    icon: Icons.video_call_outlined,
                    label: 'Find doctor',
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                  _QuickActionButton(
                    icon: Icons.description_outlined,
                    label: 'Records',
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                  _QuickActionButton(
                    icon: Icons.person_outline,
                    label: 'Edit profile',
                    onTap: _showProfileEditor,
                  ),
                ],
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
            title: 'Active care',
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
                    _StatusPill(label: activeConsultation.doctorName ?? 'Doctor assigned'),
                    if (activeConsultation.videoSession != null)
                      _StatusPill(
                        label: 'Video ${activeConsultation.videoSession!.status.toLowerCase()}',
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  activeConsultation.videoSession != null
                      ? 'Your consultation room is ready. You can join directly from the app.'
                      : 'Your consultation is booked. The room will be prepared when the doctor is ready.',
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _joinConsultation(activeConsultation),
                      icon: const Icon(Icons.videocam_outlined),
                      label: const Text('Join video call'),
                    ),
                    FilledButton.tonal(
                      onPressed: () => setState(() => _currentIndex = 3),
                      child: const Text('Open records'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        _SectionCard(
          title: 'Health snapshot',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${patient.name}, ${patient.age} years, ${patient.sex}'),
              const SizedBox(height: 8),
              Text(
                'History: ${patient.medicalHistory.isEmpty ? 'No history saved' : patient.medicalHistory.join(', ')}',
              ),
              const SizedBox(height: 8),
              Text(
                'Current meds: ${metadata.currentMedications.isEmpty ? 'None listed' : metadata.currentMedications.join(', ')}',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (metadata.bloodGroup != null)
                    _StatusPill(label: 'Blood ${metadata.bloodGroup}'),
                  if (metadata.heightCm != null)
                    _StatusPill(
                      label: 'Height ${metadata.heightCm!.toStringAsFixed(0)} cm',
                    ),
                  if (metadata.weightKg != null)
                    _StatusPill(
                      label: 'Weight ${metadata.weightKg!.toStringAsFixed(0)} kg',
                    ),
                  if (metadata.allergies.isNotEmpty)
                    _StatusPill(label: 'Allergies ${metadata.allergies.length}'),
                ],
              ),
            ],
          ),
        ),
        _SectionCard(
          title: 'Care essentials',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                label: 'Reports',
                value: patient.reports.isEmpty ? 'No reports uploaded' : patient.reports.join(', '),
              ),
              _InfoRow(
                label: 'Allergies',
                value: metadata.allergies.isEmpty ? 'None listed' : metadata.allergies.join(', '),
              ),
              _InfoRow(
                label: 'Chronic conditions',
                value: metadata.chronicConditions.isEmpty
                    ? 'None listed'
                    : metadata.chronicConditions.join(', '),
              ),
              _InfoRow(
                label: 'Emergency contact',
                value: metadata.emergencyContactName == null
                    ? 'Not saved'
                    : '${metadata.emergencyContactName} • ${metadata.emergencyContactPhone ?? ''}',
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: _showProfileEditor,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Update patient details'),
                ),
              ),
            ],
          ),
        ),
      ],
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
                const _SectionHeader(
                  title: 'AI medical assistant',
                  subtitle:
                      'Describe your symptoms simply. The assistant will guide you and suggest when to involve a doctor.',
                ),
                ..._state.chat.map((message) {
                  final isAssistant = message.sender == 'assistant';
                  return _ChatBubble(
                    isAssistant: isAssistant,
                    text: message.text,
                  );
                }),
                if (_chatLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(label: Text('Generating triage response...')),
                    ),
                  ),
                if (_chatError != null)
                  _NoticeBanner(
                    tone: NoticeTone.error,
                    text: _chatError!,
                  ),
                if (_latestReply != null)
                  _SectionCard(
                    title: 'Triage summary',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _StatusPill(label: 'Risk ${_latestReply!.riskLevel}'),
                            _StatusPill(label: 'Mode ${_latestReply!.careMode}'),
                            _StatusPill(
                              label:
                                  _latestReply!.redFlagDetected ? 'Red flag' : 'No red flag',
                              highlighted: _latestReply!.redFlagDetected,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(_latestReply!.doctorSummary),
                        if (_latestReply!.followUpQuestions.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Text(
                            'Suggested follow-up questions',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          ..._latestReply!.followUpQuestions.map((item) => Text('• $item')),
                        ],
                      ],
                    ),
                  ),
                if (_chatThreads.isNotEmpty)
                  _SectionCard(
                    title: 'Recent conversations',
                    child: Column(
                      children: _chatThreads.take(4).map((thread) {
                        final selected = _conversationId == thread.conversationId;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFE7F6F1)
                                : const Color(0xFFF7F5F0),
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
                  decoration: const InputDecoration(
                    hintText: 'Example: I have fever and cough since yesterday',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: _chatLoading ? null : _sendChat,
                child: Text(_chatLoading ? 'Sending...' : 'Ask'),
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
        const _SectionHeader(
          title: 'Doctor consultations',
          subtitle:
              'If AI guidance is not enough, choose a doctor, pay once, and join a 1:1 video consultation.',
        ),
        if (activeVideoConsultation != null)
          _SectionCard(
            title: 'Your current consultation',
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
                    label: const Text('Join current video consultation'),
                  ),
                ),
              ],
            ),
          ),
        TextField(
          controller: _bookingConcernController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'What would you like to consult for?',
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
                          color: const Color(0xFFE7F4FF),
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
                              style: const TextStyle(color: Color(0xFF6C675D)),
                            ),
                          ],
                        ),
                      ),
                      _StatusPill(
                        label: doctor.online ? 'Online' : 'Offline',
                        highlighted: doctor.online,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniInfoCard(
                          label: 'Fee',
                          value: 'Rs ${doctor.fee}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MiniInfoCard(
                          label: 'Queue',
                          value: '${doctor.queueCount}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MiniInfoCard(
                          label: 'Rating',
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
                      child: const Text('Pay and join queue'),
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
        const _SectionHeader(
          title: 'Records and follow-up',
          subtitle:
              'Your past consultations, prescriptions, appointments, and feedback stay linked to your profile.',
        ),
        if (_state.consultations.isEmpty)
          const _SectionCard(
            title: 'No records yet',
            child: Text(
              'Bookings, appointments, prescriptions, and consultation summaries will appear here once created.',
            ),
          )
        else
          ..._state.consultations.map((consultation) {
            return _SectionCard(
              title: consultation.concern,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Doctor: ${consultation.doctorName ?? consultation.doctorId}'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatusPill(label: consultation.status.name),
                      _StatusPill(label: consultation.recommendedMode),
                      if (consultation.followUpRequired)
                        const _StatusPill(label: 'Follow-up'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Prescription: ${consultation.prescription ?? 'Pending doctor note'}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Clinic visit: ${consultation.clinicVisitDate ?? 'Not booked'} ${consultation.clinicVisitSlot ?? ''}',
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
                        child: const Text('Open video room'),
                      ),
                      FilledButton.tonal(
                        onPressed: () => _scheduleFollowUp(consultation),
                        child: const Text('Book follow-up'),
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
                                  'Advice: ${prescription.advice}',
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
                            'Appointment: ${appointment.date} • ${appointment.slot} • ${appointment.clinicName}',
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
          title: 'Patient authentication',
          subtitle:
              'Sign in to use AI guidance, doctor booking, video consultation, records, and patient profile tools.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 12),
              if (_authError != null) Text(_authError!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _authLoading ? null : _login,
                  child: Text(_authLoading ? 'Signing in...' : 'Sign in'),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Demo credentials: suman.verma@lokal.demo / Pass@123'),
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
        const SnackBar(content: Text('Signed in successfully.')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _authLoading = false;
        _authError = 'Login failed. Check backend, email, and password.';
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
              color: Color(0xFFF9F5ED),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 52,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0CABB),
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
        color: const Color(0xFFE8F7F2),
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
        color: highlighted ? const Color(0xFFDDF5EC) : const Color(0xFFF0ECE3),
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
          color: isAssistant ? Colors.white : const Color(0xFFD9F3EC),
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

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F5EF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE6E0D3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF0D8C74)),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
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
        color: const Color(0xFFF7F5EF),
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
        tone == NoticeTone.error ? const Color(0xFFFFEFEA) : const Color(0xFFEAF6FF);
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
