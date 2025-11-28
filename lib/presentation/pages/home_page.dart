import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gabara_mobile/core/constants/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  late PageController _pageController;
  bool _isScrolled = false;

  final GlobalKey layananKey = GlobalKey();
  final GlobalKey testimoniKey = GlobalKey();
  final GlobalKey mitraKey = GlobalKey();
  final GlobalKey faqKey = GlobalKey();

  final List<Map<String, String>> mitraData = [
    {'image': 'assets/DPHUR1.jpg', 'name': 'PKBM Bina Nusantara', 'address': 'Pucang, RT. 01 RW. I, Gemirit, Pucang, Kec. Bawang Banjarnegara'},
    {'image': 'assets/DPHUR2.jpg', 'name': 'PKBM Teknik Industri', 'address': 'Banjarkulon, RT. 02 RW. 03, Karang Gondang, Banjarkulon, Kec. Banjarnegara'},
    {'image': 'assets/DPHUR3.jpg', 'name': 'PKBM Teknologi Pangan', 'address': 'Jl. Serma Mukhlas No. 10B, Kutabanjarnegara, Karangtengah, Kec. Banjarnegara'},
    {'image': 'assets/DPHUR4.jpg', 'name': 'PKBM Sustainability', 'address': 'Pucang, RT. 01 RW. I, Gemirit, Pucang, Kec. Bawang Banjarnegara'},
    {'image': 'assets/DPHUR5.jpg', 'name': 'PKBM Pertanian Modern', 'address': 'Jl. Raya Kalibening No. 1, Kalibening, Kec. Banjarnegara'},
    {'image': 'assets/DPHUR6.jpg', 'name': 'PKBM Seni & Budaya', 'address': 'Jl. Pemuda No. 72, Krandegan, Kec. Banjarnegara'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _pageController = PageController(viewportFraction: 0.8, initialPage: 1);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 50 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  void _scrollToSection(GlobalKey key) {
    final targetContext = key.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      _isScrolled ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
    );

    return Scaffold(
      endDrawer: AppDrawer(
        onScrollToTop: _scrollToTop,
        onScrollToSection: _scrollToSection,
        layananKey: layananKey,
        testimoniKey: testimoniKey,
        mitraKey: mitraKey,
        faqKey: faqKey,
      ),
      appBar: AppBar(
        backgroundColor: _isScrolled ? Colors.white : Colors.transparent,
        elevation: _isScrolled ? 4.0 : 0.0,
        title: _isScrolled
            ? Image.asset('assets/GabaraColor.png', height: 35)
            : Image.asset('assets/GabaraWhite.png', height: 35),
        automaticallyImplyLeading: false,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: _isScrolled ? Colors.black87 : Colors.white),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroSection(),
            Container(key: layananKey, child: _buildWhyUsSection()),
            Container(key: testimoniKey, child: _buildTestimonialSection()),
            Container(key: mitraKey, child: _buildMitraSection()),
            Container(key: faqKey, child: _buildFaqSection()),
            _buildCtaSection(),
            _buildStudentSection(),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  /// === WIDGET HERO SECTION YANG SUDAH DIPERBAIKI ===
  /// Menggunakan Column untuk layout yang lebih stabil dan responsif.
  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      color: primaryBlue,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 140), // Memberi jarak dari AppBar
          const Text(
            'Kesempatan Baru untuk Terus Belajar Tanpa Batas',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.2),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sekolah boleh tertunda, tapi mimpi jangan berhenti. Gabara hadir agar kamu bisa belajar lagi dengan cara yang lebih mudah.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 24),
          // TOMBOL DENGAN NAVIGASI YANG SUDAH DIPERBAIKI
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF57C00),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              "Gabung Sekarang",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 30),
          // GAMBAR DENGAN POSISI YANG SUDAH DIPERBAIKI
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/herosec.png', // Pastikan path ini benar
              width: MediaQuery.of(context).size.width * 0.9,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyUsSection() {
    final List<Map<String, String>> infoData = [
      {'image': 'assets/Flexible.png', 'title': 'Kelas Fleksibel', 'subtitle': 'Belajar online atau tatap muka sesuai kebutuhan.'},
      {'image': 'assets/educated.png', 'title': 'Bimbingan Terarah', 'subtitle': 'Materi sesuai kurikulum ujian paket dengan tutor yang siap mendampingi.'},
      {'image': 'assets/PacketC.png', 'title': 'Persiapan Ujian', 'subtitle': 'Latihan soal & simulasi supaya lebih siap menghadapi ujian.'},
      {'image': 'assets/Community.png', 'title': 'Komunitas Belajar', 'subtitle': 'Ruang untuk saling dukung antar siswa dan tutor.'},
    ];

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Poppins'),
              children: <TextSpan>[
                TextSpan(text: 'Kenapa Harus '),
                TextSpan(text: 'Gabara?', style: TextStyle(color: accentBlue)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Banyak anak dan orang tua di Banjarnegara terhambat sekolah karena biaya, jarak, atau waktu. Gabara menawarkan cara belajar fleksibel dan mudah diakses agar pendidikan tetap bisa diselesaikan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
            ),
            itemCount: infoData.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = infoData[index];
              return _buildInfoCard(imagePath: item['image']!, title: item['title']!, subtitle: item['subtitle']!);
            },
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String imagePath, required String title, required String subtitle}) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 40),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text(
            'Cerita dari Mereka yang Kembali Belajar',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          _buildTestimonialCard(
            imagePath: 'assets/ari_lesmana.jpg',
            quote: '"Waktu SMP saya terpaksa berhenti sekolah... Sekarang saya kembali punya harapan untuk lulus Paket C."',
            name: 'Ari Lesmana',
          ),
          const SizedBox(height: 20),
          _buildTestimonialCard(
            imagePath: 'assets/DwiCahyani.jpg',
            quote: '"Dulu saya merasa minder... Sekarang saya jadi lebih semangat, nilai saya mulai naik, dan saya percaya bisa capai cita-cita."',
            name: 'Dwi Cahyani',
          ),
          const SizedBox(height: 20),
          _buildTestimonialCard(
            imagePath: 'assets/PutriKusuma.jpg',
            quote: '"Dulu sering ketinggalan pelajaran... Sekarang aku lebih berani jawab pertanyaan di kelas dan makin semangat belajar."',
            name: 'Putri Kusuma',
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard({required String imagePath, required String quote, required String name}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Image.asset('assets/Quotation.png', height: 24, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              quote,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, height: 1.5, fontSize: 15),
            ),
            const SizedBox(height: 16),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(imagePath, height: 80, width: 80, fit: BoxFit.cover),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMitraSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      color: lightBlueBg,
      child: Column(
        children: [
          const Text('Dari Persiapan Hingga Ujian Resmi', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 24),
          SizedBox(
            height: 340,
            child: PageView.builder(
              controller: _pageController,
              itemCount: mitraData.length,
              itemBuilder: (context, index) {
                final data = mitraData[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _buildPartnerCard(imagePath: data['image']!, name: data['name']!, address: data['address']!),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: accentBlue),
                onPressed: () {
                  _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: accentBlue),
                onPressed: () {
                  _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPartnerCard({required String imagePath, required String name, required String address}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(imagePath, height: 80, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(address, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: accentBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12)),
              child: const Text('Kunjungi', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 545 / 731,
              child: Image.asset('assets/child-FAQ.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Frequently Asked Questions', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Text('Pertanyaan yang mungkin ditanyakan tentang layanan kami', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          _buildExpansionTile('Apa itu Gabara?', 'Gabara (Garasi Belajar Banjarnegara) adalah wadah belajar non-formal yang hadir untuk membantu anak-anak, remaja, maupun orang dewasa yang sempat putus sekolah agar tetap bisa melanjutkan pendidikan dan meraih masa depan lebih baik.'),
          _buildExpansionTile('Siapa saja yang bisa ikut belajar?', 'Semua masyarakat Banjarnegara yang putus sekolah, baik tingkat SD, SMP, maupun SMA, dapat bergabung di Gabara tanpa batasan usia tertentu.'),
          _buildExpansionTile('Apakah belajar di Gabara berbayar?', 'Tidak. Gabara merupakan inisiatif sosial yang memberikan fasilitas belajar secara gratis agar pendidikan bisa diakses oleh semua kalangan.'),
          _buildExpansionTile('Apa saja program yang ada di Gabara?', 'Program Gabara meliputi bimbingan belajar mata pelajaran dasar, kelas persiapan Paket A, B, dan C, serta kegiatan pengembangan diri seperti literasi, diskusi, keterampilan hidup, dan kelas motivasi untuk membangun semangat belajar.'),
          _buildExpansionTile('Apakah Gabara hanya untuk anak-anak?', 'Tidak. Gabara terbuka untuk semua usia yang ingin melanjutkan pendidikan.'),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(String title, String description) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey[200]!)),
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(description, style: TextStyle(color: Colors.grey[700], height: 1.5)),
          )
        ],
      ),
    );
  }

  Widget _buildCtaSection() {
    return Container(
      color: lightBlueBg,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Poppins'),
              children: <TextSpan>[
                TextSpan(text: 'Siap Belajar '),
                TextSpan(text: 'Bersama Kami?', style: TextStyle(color: accentBlue)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Mari bergabung dengan Gabara dan temukan kembali semangat belajar tanpa batas. Pendidikan terbuka untuk siapa saja, kapan saja, dan di mana saja.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentBlue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Gabung Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      color: lightBlueBg,
      padding: const EdgeInsets.only(top: 40.0),
      child: Image.asset(
        'assets/herounder.png',
        width: screenWidth * 0.75,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    bool isLargeScreen = MediaQuery.of(context).size.width > 768;

    void scrollToTopSimple() {
      _scrollController.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.easeInOut);
    }

    void scrollToSectionSimple(GlobalKey key) {
       final targetContext = key.currentContext;
      if (targetContext != null) {
        Scrollable.ensureVisible(targetContext, duration: const Duration(seconds: 1), curve: Curves.easeInOut);
      }
    }

    return Container(
      color: footerBg,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isLargeScreen
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildFooterAbout()),
                    Expanded(flex: 1, child: _buildFooterNavigation(onScrollToTop: scrollToTopSimple, onScrollToSection: scrollToSectionSimple)),
                    Expanded(flex: 2, child: _buildFooterContact()),
                    Expanded(flex: 1, child: _buildFooterGallery()),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFooterAbout(),
                    const SizedBox(height: 32),
                    _buildFooterNavigation(onScrollToTop: scrollToTopSimple, onScrollToSection: scrollToSectionSimple),
                    const SizedBox(height: 32),
                    _buildFooterContact(),
                    const SizedBox(height: 32),
                    _buildFooterGallery(),
                  ],
                ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              '© 2025 Gabara. Hak Cipta Dilindungi oleh Telkom University Purwokerto.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFooterAbout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset('assets/GabaraColor.png', height: 40),
        const SizedBox(height: 16),
        const Text(
          'Adipasir II, Adipasir, Kec. Rakit, Kab. Banjarnegara, Jawa Tengah 53463, Indonesia',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildFooterNavigation({required VoidCallback onScrollToTop, required Function(GlobalKey) onScrollToSection}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFooterSectionTitle('Navigasi'),
        _buildFooterLink('Beranda', onTap: onScrollToTop),
        _buildFooterLink('Layanan', onTap: () => onScrollToSection(layananKey)),
        _buildFooterLink('Testimoni', onTap: () => onScrollToSection(testimoniKey)),
        _buildFooterLink('Mitra', onTap: () => onScrollToSection(mitraKey)),
        _buildFooterLink('FAQ', onTap: () => onScrollToSection(faqKey)),
      ],
    );
  }

  Widget _buildFooterLink(String text, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Text(text, style: const TextStyle(color: Colors.white70)),
      ),
    );
  }

  Widget _buildFooterContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFooterSectionTitle('Kontak'),
        _buildContactRow('assets/waicon.png', '0822 5510 8336'),
        const SizedBox(height: 12),
        _buildContactRow('assets/emailIcon.png', 'garasibelajar.id@gmail.com'),
        const SizedBox(height: 12),
        _buildContactRow('assets/igIcon.png', 'Gabara_Education'),
      ],
    );
  }

  Widget _buildFooterGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFooterSectionTitle('Galeri'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/footer1.png', fit: BoxFit.cover)),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/footer2.png', fit: BoxFit.cover)),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/footer3.png', fit: BoxFit.cover)),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/footer4.png', fit: BoxFit.cover)),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildContactRow(String iconPath, String text) {
    return Row(
      children: [
        Image.asset(iconPath, height: 20),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class AppDrawer extends StatelessWidget {
  final VoidCallback onScrollToTop;
  final Function(GlobalKey) onScrollToSection;
  final GlobalKey layananKey;
  final GlobalKey testimoniKey;
  final GlobalKey mitraKey;
  final GlobalKey faqKey;

  const AppDrawer({
    super.key,
    required this.onScrollToTop,
    required this.onScrollToSection,
    required this.layananKey,
    required this.testimoniKey,
    required this.mitraKey,
    required this.faqKey,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            decoration: const BoxDecoration(color: primaryBlue),
            child: Stack(
              children: [
                Center(child: Image.asset('assets/GabaraWhite.png', height: 50)),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  title: const Text('Beranda'),
                  onTap: () {
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 200), onScrollToTop);
                  },
                ),
                ListTile(
                  title: const Text('Layanan'),
                  onTap: () {
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 200), () => onScrollToSection(layananKey));
                  },
                ),
                ListTile(
                  title: const Text('Testimoni'),
                  onTap: () {
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 200), () => onScrollToSection(testimoniKey));
                  },
                ),
                ListTile(
                  title: const Text('Mitra'),
                  onTap: () {
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 200), () => onScrollToSection(mitraKey));
                  },
                ),
                ListTile(
                  title: const Text('FAQ'),
                  onTap: () {
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 200), () => onScrollToSection(faqKey));
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentOrange,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Login', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}