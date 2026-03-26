import 'package:flutter/material.dart';
import 'package:lokal_health_shared/lokal_health_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/doctor_backend_client.dart';

class DoctorAppRoot extends StatelessWidget {
  const DoctorAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lokal MedAssist Doctor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF124E96),
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
            borderSide: const BorderSide(color: Color(0xFFD4DCE7)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFD4DCE7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF124E96), width: 1.4),
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F5F8),
        useMaterial3: true,
      ),
      home: const DoctorHomePage(),
    );
  }
}

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  static const _doctorTokenKey = 'doctor_auth_token';
  final DoctorBackendClient _backendClient = DoctorBackendClient();
  final TextEditingController _emailController =
      TextEditingController(text: 'meera.sharma@lokal.demo');
  final TextEditingController _passwordController =
      TextEditingController(text: 'Doc@123');
  final TextEditingController _prescriptionController = TextEditingController();

  DoctorProfile? _doctor;
  List<ConsultationRecord> _queue = const [];
  ConsultationRecord? _selected;
  String? _token;
  String? _authError;
  int _currentIndex = 0;
  bool _authLoading = false;
  bool _screenLoading = false;
  bool _bootLoading = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _prescriptionController.dispose();
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

    if (_token == null || _doctor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Doctor Login')),
        body: SafeArea(child: _buildAuthScreen()),
      );
    }

    final doctor = _doctor!;
    final pages = [
      _buildHome(doctor),
      _buildQueue(),
      _buildPrescriptionDesk(),
      _buildWallet(doctor),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor App'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _screenLoading ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text(doctor.doctorId)),
          ),
        ],
      ),
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.queue_outlined), label: 'Queue'),
          NavigationDestination(icon: Icon(Icons.description_outlined), label: 'Rx Desk'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'),
        ],
      ),
    );
  }

  Widget _buildAuthScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: 'Doctor authentication',
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
              const Text('Demo credentials: meera.sharma@lokal.demo / Doc@123'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHome(DoctorProfile doctor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_screenLoading)
          const _InfoCard(
            title: 'Syncing',
            child: Text('Refreshing backend data...'),
          ),
        _InfoCard(
          title: 'Consultation readiness',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doctor.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('${doctor.specialty} • ${doctor.experienceYears} yrs'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _DoctorStatusPill(label: 'Rating ${doctor.rating}'),
                  _DoctorStatusPill(
                    label: doctor.online ? 'Online' : 'Offline',
                    highlighted: doctor.online,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _toggleAvailability(!doctor.online),
                child: Text(doctor.online ? 'Go offline' : 'Go online'),
              ),
            ],
          ),
        ),
        _InfoCard(
          title: 'Operational summary',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatTile(label: 'Queue', value: '${doctor.queueCount}'),
              _StatTile(label: 'Consulted', value: '${doctor.consultationsCompleted}'),
              _StatTile(label: 'Patients', value: '${doctor.patientsAttended}'),
              _StatTile(label: 'Prescriptions', value: '${doctor.prescriptionsIssued}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQueue() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Patient traffic management',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text('Attend queued requests one by one and escalate to clinic visit when needed.'),
        const SizedBox(height: 16),
        ..._queue.map(
          (record) => Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.id, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(record.concern),
                  const SizedBox(height: 12),
                  _DoctorStatusPill(
                    label: record.status.name,
                    highlighted: record.status == ConsultationStatus.inCall,
                  ),
                  const SizedBox(height: 8),
                  Text('Amount paid: Rs ${record.amountPaid}'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _startConsultation(record),
                          child: const Text('Start call'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: () => _requestVisit(record),
                          child: const Text('Request visit'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildPrescriptionDesk() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: 'E-prescription desk',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_selected?.id ?? 'No consultation selected'),
              const SizedBox(height: 12),
              TextField(
                controller: _prescriptionController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Write dosage, precautions, and follow-up instructions',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selected == null ? null : _completeConsultation,
                  child: const Text('Complete consultation'),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildWallet(DoctorProfile doctor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: 'Wallet and payout',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Wallet balance: Rs ${doctor.walletBalance}'),
              const SizedBox(height: 8),
              Text('Ready for bank transfer: Rs ${doctor.nextPayoutEligible}'),
              const SizedBox(height: 8),
              const Text('Production flow: Razorpay settlement -> payout scheduler -> linked bank account'),
            ],
          ),
        )
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
      _doctor = session.doctor;
      await _refresh();
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

  Future<void> _refresh() async {
    final token = _token;
    if (token == null) return;
    setState(() {
      _screenLoading = true;
    });
    try {
      final doctor = await _backendClient.fetchMe(token);
      final queue = await _backendClient.fetchQueue(token);
      if (!mounted) return;
      setState(() {
        _doctor = doctor;
        _queue = queue;
        if (_selected != null) {
          final matches = queue.where((item) => item.id == _selected!.id);
          _selected = matches.isNotEmpty ? matches.first : _selected;
        }
        _screenLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _screenLoading = false;
      });
    }
  }

  Future<void> _toggleAvailability(bool online) async {
    final token = _token;
    if (token == null) return;
    try {
      await _backendClient.setAvailability(token: token, online: online);
      await _refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Availability update failed.')),
      );
    }
  }

  Future<void> _startConsultation(ConsultationRecord record) async {
    final token = _token;
    if (token == null) return;
    try {
      await _backendClient.startConsultation(
        token: token,
        consultationId: record.id,
      );
      if (!mounted) return;
      setState(() {
        _selected = record.copyWith(status: ConsultationStatus.inCall);
        _currentIndex = 2;
      });
      await _refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not start consultation.')),
      );
    }
  }

  Future<void> _requestVisit(ConsultationRecord record) async {
    final token = _token;
    if (token == null) return;
    try {
      await _backendClient.requestVisit(
        token: token,
        consultationId: record.id,
      );
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Physical visit requested.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not request visit.')),
      );
    }
  }

  Future<void> _completeConsultation() async {
    final token = _token;
    final current = _selected;
    if (token == null || current == null) {
      return;
    }

    try {
      await _backendClient.completeConsultation(
        token: token,
        consultationId: current.id,
        prescription: _prescriptionController.text.trim().isEmpty
            ? 'Take medicines as prescribed and review after 3 days.'
            : _prescriptionController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _selected = null;
        _prescriptionController.clear();
        _currentIndex = 1;
      });
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consultation completed.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not complete consultation.')),
      );
    }
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_doctorTokenKey);

    if (savedToken == null) {
      if (!mounted) return;
      setState(() {
        _bootLoading = false;
      });
      return;
    }

    _token = savedToken;
    await _refresh();
    if (!mounted) return;
    setState(() {
      _bootLoading = false;
    });
  }

  Future<void> _persistToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_doctorTokenKey, token);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_doctorTokenKey);
    if (!mounted) return;
    setState(() {
      _token = null;
      _doctor = null;
      _queue = const [];
      _selected = null;
      _currentIndex = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signed out.')),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

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

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _DoctorStatusPill extends StatelessWidget {
  const _DoctorStatusPill({
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
        color: highlighted ? const Color(0xFFE4EFFC) : const Color(0xFFF0F3F8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: highlighted ? const Color(0xFF124E96) : const Color(0xFF4E5D75),
        ),
      ),
    );
  }
}
