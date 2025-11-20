import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../layout/student_app_drawer.dart';
import '../layout/tutor_app_drawer.dart';
import 'profile_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
// Import 'class_page.dart' nanti saat sudah dibuat
// import '../../features/class/presentation/pages/class_page.dart';

// --- DEFINISI KONSTANTA LOKAL ---
// (Anda bisa pindahkan ini ke app_colors.dart jika mau)
const double containerPadding = 16.0;
const double containerMargin = 16.0;
const double borderRadius = 12.0;
const BorderSide calendarBorderSide = BorderSide(
  color: Color.fromARGB(255, 224, 224, 224),
  width: 1.0,
);

// Enum untuk mengelola view kalender yang aktif
enum CalendarView { monthly, weekly, daily }

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  CalendarView _selectedView = CalendarView.monthly;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context);

    // If user is not authenticated, redirect to login
    // Pengecekan ini penting jika user membuka app dan masih punya token,
    // tapi jika tokennya invalid atau sudah logout, ini akan redirect.
    if (provider.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Cek 'mounted' untuk memastikan widget masih ada di tree
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      // --- PERUBAHAN 1: Menggunakan StudentAppDrawer ---
      drawer: provider.user?.role == 'mentor'
          ? const TutorAppDrawer(activeRoute: 'dashboard')
          : const StudentAppDrawer(activeRoute: 'dashboard'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Image.asset('assets/GabaraColor.png', height: 30),
        centerTitle: true,
        actions: [_buildProfilePopupMenu()],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: containerMargin),
              child: _buildWelcomeSection(context),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: containerMargin),
              child: Row(
                children: provider.user?.role == 'mentor'
                    ? [
                        Expanded(
                          child: _buildSummaryCard(
                            icon: Icons.class_,
                            title: 'Kelas Dibuat',
                            count: '1',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            icon: Icons.question_mark,
                            title: 'Kuis Dibuat',
                            count: '0',
                          ),
                        ),
                      ]
                    : [
                        Expanded(
                          child: _buildSummaryCard(
                            icon: Icons.book,
                            title: 'Jumlah Kelas Diikuti',
                            count: '1',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            icon: Icons.assignment_turned_in_outlined,
                            title: 'Tugas Berjalan',
                            count: '0',
                          ),
                        ),
                      ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(
              'Pengumuman',
              padding: const EdgeInsets.symmetric(horizontal: containerMargin),
            ),
            _buildSectionWrapper(child: _buildAnnouncementSection()),
            const SizedBox(height: 16),
            _buildSectionTitle(
              'Daftar Deadline Tugas/Quiz',
              padding: const EdgeInsets.symmetric(horizontal: containerMargin),
            ),
            _buildSectionWrapper(child: _buildDeadlineSection()),
            const SizedBox(height: 16),
            _buildSectionTitle(
              'Kalender',
              padding: const EdgeInsets.symmetric(horizontal: containerMargin),
            ),
            _buildSectionWrapper(
              padding: const EdgeInsets.all(0.0),
              child: _buildCalendarSection(context),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // --- WIDGET-WIDGET LOKAL (DARI FILE LAMA) ---
  // Widget-widget ini kita biarkan di sini agar refactoring lebih cepat
  // dan tidak terlalu banyak perubahan sekaligus.

  // --- PERUBAHAN 2: Navigasi di _buildProfilePopupMenu sudah benar ---
  Widget _buildProfilePopupMenu() {
    // Ambil provider. 'listen: false' aman di sini karena hanya untuk aksi.
    final provider = Provider.of<AuthProvider>(context, listen: false);
    final user = provider.user!;

    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit_profile') {
          // Navigasi ke ProfilePage (file baru)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        } else if (value == 'logout') {
          // --- PERBAIKAN LOGOUT ---
          // 1. Navigasi ke home ('/') dan hapus semua riwayat navigasi.
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          // 2. SETELAH navigasi selesai, baru panggil logout() dari provider.
          //    Ini mencegah redirect di halaman dashboard (yang akan di-dispose)
          //    untuk ter-trigger.
          provider.logout();
        }
      },
      icon: const Icon(Icons.more_vert, color: Colors.black),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          enabled: false,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              child: Text(
                user.name[0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(user.name),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'edit_profile',
          child: ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Edit Profil'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: ListTile(leading: Icon(Icons.logout), title: Text('Keluar')),
        ),
      ],
    );
  }

  Widget _buildSectionWrapper({required Widget child, EdgeInsets? padding}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: containerMargin),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(containerPadding),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {EdgeInsets? padding}) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    final user = provider.user!;

    return Container(
      padding: const EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: lightGreyBackground.withAlpha(128),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat datang Kembali, ${user.name}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            DateTime.now().toString().split(' ')[0],
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String count,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(containerPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentBlue.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: accentBlue, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementSection() {
    return Column(
      children: [
        Image.asset(
          'assets/kosong.png',
          height: 150,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox(
              height: 150,
              child: Center(
                child: Icon(
                  Icons.notifications_off,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Tidak ada pengumuman',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Belum ada pengumuman yang tersedia.',
          style: TextStyle(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDeadlineSection() {
    return const ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        'Tidak ada deadline mendatang.',
        style: TextStyle(color: Colors.black54),
      ),
    );
  }

  Widget _buildCalendarSection(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: containerPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                onPressed: () {},
              ),
              const Text(
                'Oktober 2025',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 18),
                onPressed: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: containerPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCalendarTab('Bulan', CalendarView.monthly),
              _buildCalendarTab('Minggu', CalendarView.weekly),
              _buildCalendarTab('Hari', CalendarView.daily),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Padding(
            key: ValueKey(_selectedView),
            padding: const EdgeInsets.symmetric(horizontal: containerPadding),
            child: _getSelectedCalendarView(),
          ),
        ),
        const SizedBox(height: containerPadding),
      ],
    );
  }

  Widget _getSelectedCalendarView() {
    switch (_selectedView) {
      case CalendarView.monthly:
        return _buildMonthlyView();
      case CalendarView.weekly:
        return _buildWeeklyView();
      case CalendarView.daily:
        return _buildDailyView();
    }
  }

  Widget _buildCalendarTab(String text, CalendarView view) {
    final bool isSelected = _selectedView == view;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedView = view;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? lightGreyBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyView() {
    const List<String> dayHeaders = [
      'SEN',
      'SEL',
      'RAB',
      'KAM',
      'JUM',
      'SAB',
      'MIN',
    ];
    final Map<int, TableColumnWidth> columnWidthsMap = {
      for (int i = 0; i < dayHeaders.length; i++) i: const FlexColumnWidth(),
    };
    return Table(
      columnWidths: columnWidthsMap,
      border: TableBorder.all(
        color: calendarBorderSide.color,
        width: calendarBorderSide.width,
      ),
      children: [
        _buildCalendarRow(dayHeaders, isHeader: true),
        _buildCalendarRow([
          '29',
          '30',
          '1',
          '2',
          '3',
          '4',
          '5',
        ], isCurrentMonth: false),
        _buildCalendarRow(['6', '7', '8', '9', '10', '11', '12']),
        _buildCalendarRow([
          '13',
          '14',
          '15',
          '16',
          '17',
          '18',
          '19',
        ], highlightedDay: '15'),
        _buildCalendarRow(['20', '21', '22', '23', '24', '25', '26']),
        _buildCalendarRow([
          '27',
          '28',
          '29',
          '30',
          '31',
          '1',
          '2',
        ], isNextMonth: true),
      ],
    );
  }

  TableRow _buildCalendarRow(
    List<String> days, {
    bool isHeader = false,
    String? highlightedDay,
    bool isCurrentMonth = true,
    bool isNextMonth = false,
  }) {
    return TableRow(
      children: days.map((day) {
        bool isHighlighted =
            day == highlightedDay && isCurrentMonth && !isNextMonth;
        Color textColor = isCurrentMonth && !isNextMonth
            ? Colors.black
            : Colors.grey.shade400;
        if (isHeader) textColor = Colors.black54;

        return TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            color: Colors.white,
            height: isHeader ? 30 : 50,
            alignment: Alignment.center,
            child: Container(
              width: 30,
              height: 30,
              decoration: isHighlighted
                  ? BoxDecoration(
                      color: accentBlue,
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              alignment: Alignment.center,
              child: Text(
                day,
                style: TextStyle(
                  fontSize: isHeader ? 11 : 16,
                  fontWeight: isHighlighted
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isHighlighted ? Colors.white : textColor,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeeklyView() {
    const List<String> dayHeaders = [
      'SEN',
      'SEL',
      'RAB',
      'KAM',
      'JUM',
      'SAB',
      'MIN',
    ];
    const double timeColumnWidth = 50.0;
    const double hourRowHeight = 60.0;
    final List<String> timeSlots = List.generate(
      13,
      (index) => '${(index + 8).toString().padLeft(2, '0')}:00',
    );

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: timeColumnWidth),
            ...dayHeaders.map(
              (day) => Expanded(
                child: Container(
                  height: 30,
                  alignment: Alignment.center,
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: calendarBorderSide.color,
              width: calendarBorderSide.width,
            ),
          ),
          child: Column(
            children: timeSlots.map((time) {
              return Row(
                children: [
                  Container(
                    width: timeColumnWidth,
                    height: hourRowHeight,
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      time,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                  ...List.generate(
                    7,
                    (index) => Expanded(
                      child: Container(
                        height: hourRowHeight,
                        decoration: const BoxDecoration(
                          border: Border(
                            left: calendarBorderSide,
                            top: calendarBorderSide,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyView() {
    const double timeColumnWidth = 60.0;
    const double hourRowHeight = 80.0;
    final List<String> timeSlots = List.generate(
      13,
      (index) => '${(index + 8).toString().padLeft(2, '0')}:00',
    );

    return Column(
      children: [
        Container(
          height: 30,
          alignment: Alignment.center,
          child: const Text(
            "RABU",
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: calendarBorderSide.color,
              width: calendarBorderSide.width,
            ),
          ),
          child: Column(
            children: timeSlots.map((time) {
              return Row(
                children: [
                  Container(
                    width: timeColumnWidth,
                    height: hourRowHeight,
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      border: Border(right: calendarBorderSide),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: hourRowHeight,
                      decoration: const BoxDecoration(
                        border: Border(top: calendarBorderSide),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
