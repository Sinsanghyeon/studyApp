import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const StudyOnApp());
}

class StudyOnApp extends StatelessWidget {
  const StudyOnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    StudyCategoryPage(),
    ContentPage(),
    MyPage(),
  ];

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: '카테고리'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library), label: '컨텐츠'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '마이페이지'),
        ],
      ),
    );
  }
}

class StudyCategoryPage extends StatefulWidget {
  const StudyCategoryPage({super.key});

  @override
  State<StudyCategoryPage> createState() => _StudyCategoryPageState();
}

class _StudyCategoryPageState extends State<StudyCategoryPage> {
  String selectedSort = '인기순';
  DateTimeRange? dateRange;
  String selectedCity = '서울';
  String selectedDistrict = '강남구';
  String? selectedDong;
  String selectedMainCategory = '외국어';
  List<String> selectedSubCategories = [];

  final List<String> sortOptions = ['인기순', '최근등록순', '마감임박순'];
  final Map<String, List<String>> districtMap = {
    '서울': ['강남구', '서초구'],
    '부산': ['해운대구'],
  };
  final Map<String, List<String>> dongMap = {
    '강남구': ['역삼동', '삼성동'],
    '서초구': ['반포동'],
    '해운대구': ['우동', '중동'],
  };
  final Map<String, List<String>> categoryMap = {
    '외국어': ['영어 회화', '비즈니스 영어', '일본어', '중국어'],
    '프로그래밍': ['Python 기초', 'Java 백엔드', 'Flutter 앱 개발'],
    '자격증': ['컴활 1급', '토익스피킹', '정보처리기능사'],
    '면접': ['삼성', 'LG', '카카오'],
  };

  List<Map<String, Object>> studies = [
    {
      'type': '온라인',
      'typeColor': Colors.teal,
      'title': '매일 영어 회화 스터디',
      'desc': '영어 회화 능력을 키우기 위한 스터디 그룹원 구해요.',
      'tags': ['어학', '주 3회', '초보자 환영'],
      'date': '2024-04-25',
      'popular': true,
    },
    {
      'type': '오프라인',
      'typeColor': Colors.orangeAccent,
      'title': '공무원 시험 준비 스터디',
      'desc': '함께 모여서 행정학 공부하실 분들 신청해주세요!',
      'tags': ['고시', '3개월', '서울'],
      'date': '2024-04-20',
      'popular': false,
    },
  ];

  List<Map<String, Object>> getSortedStudies() {
    List<Map<String, Object>> sorted = [...studies];
    if (selectedSort == '인기순') {
      sorted.sort((a, b) => (b['popular'] == true ? 1 : 0) - (a['popular'] == true ? 1 : 0));
    } else if (selectedSort == '최근등록순') {
      sorted.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
    } else {
      sorted.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
    }
    return sorted;
  }

  void _showFilterBottomSheet() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => StatefulBuilder(
      builder: (context, setStateBottom) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('종류별', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedMainCategory,
              items: categoryMap.keys.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (val) => setStateBottom(() {
                selectedMainCategory = val!;
                selectedSubCategories.clear();
              }),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: categoryMap[selectedMainCategory]!
                  .map((sub) => FilterChip(
                label: Text(sub),
                selected: selectedSubCategories.contains(sub),
                onSelected: (sel) => setStateBottom(() => sel
                    ? selectedSubCategories.add(sub)
                    : selectedSubCategories.remove(sub)),
              ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Text('기간별', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(dateRange == null
                  ? '날짜를 선택하세요'
                  : '${DateFormat('yyyy-MM-dd').format(dateRange!.start)} ~ ${DateFormat('yyyy-MM-dd').format(dateRange!.end)}'),
              TextButton(
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setStateBottom(() => dateRange = picked);
                },
                child: const Text('날짜 선택'),
              )
            ]),
            const SizedBox(height: 24),
            const Text('지역별', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedCity,
                  items: districtMap.keys
                      .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                      .toList(),
                  onChanged: (val) => setStateBottom(() {
                    selectedCity = val!;
                    selectedDistrict = districtMap[selectedCity]!.first;
                    selectedDong = dongMap[selectedDistrict]?.first;
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedDistrict,
                  items: districtMap[selectedCity]!
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (val) => setStateBottom(() {
                    selectedDistrict = val!;
                    selectedDong = dongMap[selectedDistrict]?.first;
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedDong,
                  items: dongMap[selectedDistrict]!
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (val) => setStateBottom(() => selectedDong = val!),
                ),
              ),
            ]),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48), backgroundColor: Colors.teal),
              child: const Text('설정 완료'),
            )
          ]),
        ),
      ),
    ),
  );

  void _showAddStudySheet() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('스터디 추가', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: '제목')),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: '설명')),
            const SizedBox(height: 12),
            Row(children: [
              Text('날짜: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
                child: const Text('선택'),
              )
            ]),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  studies.add({
                    'type': '온라인',
                    'typeColor': Colors.teal,
                    'title': titleCtrl.text,
                    'desc': descCtrl.text,
                    'tags': <String>[],
                    'date': DateFormat('yyyy-MM-dd').format(selectedDate),
                    'popular': false,
                  });
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: '스터디를 검색하세요.',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedSort,
                          icon: const Icon(Icons.arrow_drop_down),
                          onChanged: (val) => setState(() => selectedSort = val!),
                          items: sortOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                        ),
                      ),
                    ),
                    TextButton(onPressed: _showFilterBottomSheet, child: const Text('필터', style: TextStyle(fontSize: 16))),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: getSortedStudies().map((s) => StudyCard(study: s)).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudySheet,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class StudyCard extends StatelessWidget {
  final Map<String, Object> study;
  const StudyCard({super.key, required this.study});

  @override
  Widget build(BuildContext context) {
    final color = study['typeColor'] as Color;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudyDetailPage(
              title: study['title'] as String,
              desc: study['desc'] as String,
              tags: study['tags'] as List<String>,
              date: study['date'] as String,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(study['type'] as String, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Text(study['title'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(study['desc'] as String, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ...((study['tags'] as List<String>).map((tag) => Chip(label: Text(tag, style: const TextStyle(fontSize: 12))))),
              Chip(label: Text(study['date'] as String, style: const TextStyle(fontSize: 12))),
            ],
          ),
        ]),
      ),
    );
  }
}

class StudyDetailPage extends StatelessWidget {
  final String title;
  final String desc;
  final List<String> tags;
  final String date;

  const StudyDetailPage({
    required this.title,
    required this.desc,
    required this.tags,
    required this.date,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.teal),
                const SizedBox(width: 8),
                Text('시작 예정일: $date', style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),
            Text(desc, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 16),
            const Text("태그", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 4, children: tags.map((tag) => Chip(label: Text(tag))).toList()),
            const SizedBox(height: 24),
            const Text("스터디 정보", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _infoRow(Icons.people, "모집 인원: 최대 6명"),
            _infoRow(Icons.location_on, "진행 방식: 온라인"),
            _infoRow(Icons.schedule, "모임 시간: 매주 화/목 오후 8시"),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("스터디 신청하기"),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("스터디 신청이 완료되었습니다!")),
                  );
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), backgroundColor: Colors.teal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class ContentPage extends StatelessWidget {
  const ContentPage({super.key});

  @override
  Widget build(BuildContext context) => Center(child: Text('컨텐츠 페이지 준비중'));
}

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) => Center(child: Text('마이페이지'));
}
