import 'package:flutter/material.dart';
import 'package:lokal_health_shared/lokal_health_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
            borderSide: const BorderSide(color: Color(0xFFD7D2C8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFD7D2C8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF0D8C74), width: 1.4),
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFF6EFE2),
        useMaterial3: true,
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
  int _currentIndex = 0;
  int _rating = 5;
  bool _chatLoading = false;
  bool _authLoading = false;
  bool _screenLoading = false;
  bool _bootLoading = true;
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
    _restoreSession();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _chatController.dispose();
    _feedbackController.dispose();
    _bookingConcernController.dispose();
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
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF7F1E6), Color(0xFFF1E6D1)],
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
        onDestinationSelected: (value) {
          setState(() => _currentIndex = value);
        },
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
    return ListView(
      key: const ValueKey('overview'),
      padding: const EdgeInsets.all(16),
      children: [
        _HeroCard(
          title: 'Local-language medical access',
          subtitle:
              'AI triage, doctor call, prescription, and clinic follow-up in one Android app.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricChip(label: 'City', value: patient.city),
              _MetricChip(label: 'Language', value: languageLabel(patient.preferredLanguage)),
              _MetricChip(label: 'Consultations', value: '${patient.previousConsultations}'),
              _MetricChip(label: 'BMI', value: '${patient.bmi}'),
            ],
          ),
        ),
        _SectionCard(
          title: 'Profile',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${patient.name}, ${patient.age} years, ${patient.sex}'),
              const SizedBox(height: 8),
              Text('Medical history: ${patient.medicalHistory.join(', ')}'),
              const SizedBox(height: 8),
              Text('Reports: ${patient.reports.join(', ')}'),
            ],
          ),
        ),
        if (_screenLoading)
          const _NoticeBanner(
            tone: NoticeTone.info,
            text: 'Refreshing backend data...',
          ),
        _SectionCard(
          title: 'What the backend will do',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('LLM handles symptom intake, multilingual guidance, and doctor handoff.'),
              const SizedBox(height: 8),
              const Text('Video, payments, appointments, and prescriptions are handled by backend services.'),
              const SizedBox(height: 8),
              Text(
                'Patient API: ${const String.fromEnvironment('PATIENT_API_BASE_URL', defaultValue: 'http://10.0.2.2:8080')}',
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
                  title: 'Backend triage summary',
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
                            label: _latestReply!.redFlagDetected ? 'Red flag' : 'No red flag',
                            highlighted: _latestReply!.redFlagDetected,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Doctor summary: ${_latestReply!.doctorSummary}'),
                      if (_latestReply!.followUpQuestions.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('Suggested follow-up questions:'),
                        const SizedBox(height: 4),
                        ..._latestReply!.followUpQuestions.map((item) => Text('- $item')),
                      ]
                    ],
                  ),
                ),
              if (_chatThreads.isNotEmpty)
                _SectionCard(
                  title: 'Saved conversations',
                  child: Column(
                    children: _chatThreads.take(4).map(
                      (thread) {
                        final selected = _conversationId == thread.conversationId;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFFE7F6F1) : const Color(0xFFF7F5F0),
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
                      },
                    ).toList(),
                  ),
                )
            ],
          ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: const InputDecoration(
                    hintText: 'Describe symptoms in English or Hindi',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: _chatLoading ? null : _sendChat,
                child: Text(_chatLoading ? 'Sending...' : 'Ask'),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoctors() {
    return ListView(
      key: const ValueKey('doctors'),
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader(
          title: 'Choose doctor',
          subtitle: 'If AI guidance is not enough, move directly to a paid video consult.',
        ),
        TextField(
          controller: _bookingConcernController,
          decoration: const InputDecoration(
            hintText: 'Enter the concern to send with booking',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        ..._state.doctors.map(
          (doctor) => Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          doctor.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      _StatusPill(
                        label: doctor.online ? 'Online' : 'Offline',
                        highlighted: doctor.online,
                      )
                    ],
                  ),
                  Text('${doctor.specialty} • ${doctor.experienceYears} yrs'),
                  const SizedBox(height: 8),
                  Text(
                    '${doctor.languages.map(languageLabel).join(' / ')} • Rating ${doctor.rating}',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: Text('Fee: Rs ${doctor.fee}')),
                      Expanded(child: Text('Queue: ${doctor.queueCount}')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed:
                          doctor.online && _token != null ? () => _bookDoctor(doctor) : null,
                      child: const Text('Pay and join queue'),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildRecords() {
    final latest = _state.consultations.isNotEmpty ? _state.consultations.first : null;
    return ListView(
      key: const ValueKey('records'),
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader(
          title: 'Consultation records',
          subtitle: 'Prescription, clinic visit, and feedback stay attached to the patient profile.',
        ),
        if (latest != null) ...[
          _SectionCard(
            title: latest.concern,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mode: ${latest.recommendedMode}'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusPill(label: latest.status.name),
                    if (latest.followUpRequired)
                      const _StatusPill(label: 'Follow-up'),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Prescription: ${latest.prescription ?? 'Pending doctor note'}'),
                const SizedBox(height: 8),
                Text(
                  'Clinic visit: ${latest.clinicVisitDate ?? 'Not booked'} ${latest.clinicVisitSlot ?? ''}',
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () => _scheduleFollowUp(latest),
                  child: const Text('Book physical follow-up'),
                ),
              ],
            ),
          ),
          if (_appointments.isNotEmpty)
            _SectionCard(
              title: 'Appointments',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _appointments
                    .map(
                      (appointment) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          '${appointment.date} at ${appointment.slot} • ${appointment.clinicName} • ${appointment.status}',
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          if (_prescriptions.isNotEmpty)
            _SectionCard(
              title: 'Prescriptions',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _prescriptions
                    .map(
                      (prescription) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Advice: ${prescription.advice}'),
                            const SizedBox(height: 4),
                            ...prescription.medicines.map(
                              (medicine) => Text(
                                '- ${medicine['name']} • ${medicine['dosage']} • ${medicine['frequency']} • ${medicine['duration']}',
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          _SectionCard(
            title: 'Rate your doctor',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<int>(
                  value: _rating,
                  items: const [5, 4, 3, 2, 1]
                      .map((item) => DropdownMenuItem<int>(value: item, child: Text('$item Star')))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _rating = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _feedbackController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Share feedback about the consultation',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _submitFeedback(latest),
                    child: const Text('Submit feedback'),
                  ),
                )
              ],
            ),
          ),
        ] else
          const _SectionCard(
            title: 'No records yet',
            child: Text('Bookings, appointments, and prescriptions will appear here once created.'),
          )
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
              'Sign in against the patient backend before using chat, doctors, bookings, appointments, and prescriptions.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
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
      final doctors = await _backendClient.fetchDoctors();
      final chats = await _backendClient.fetchChats(token);
      final bookings = await _backendClient.fetchBookings(token);
      final appointments = await _backendClient.fetchAppointments(token);
      final prescriptions = await _backendClient.fetchPrescriptions(token);
      if (!mounted) return;
      setState(() {
        _state = _state.copyWith(
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

      if (!mounted) {
        return;
      }

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
      if (!mounted) {
        return;
      }

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
        .then((_) => _refreshBackendData())
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

  void _scheduleFollowUp(ConsultationRecord consultation) {
    final token = _token;
    if (token == null) return;

    _backendClient
        .createAppointment(
          token: token,
          consultationId: consultation.id,
          doctorId: consultation.doctorId,
          date: '2026-03-31',
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
        borderRadius: BorderRadius.circular(24),
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
