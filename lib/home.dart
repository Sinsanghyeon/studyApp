import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '스터디 온',
      debugShowCheckedModeBanner: false,
      home: StudyHomeScreen(),
    );
  }
}

class StudyHomeScreen extends StatelessWidget {
  final List<Map<String, String>> popularStudies = [
    {
      'title': '토익 실전 스터디',
      'category': '어학',
      'image': 'https://via.placeholder.com/150'
    },
    {
      'title': 'Flutter 앱 개발 스터디',
      'category': '개발',
      'image': 'https://via.placeholder.com/150'
    },
  ];

  final List<Map<String, String>> recommendedStudies = [
    {
      'title': '공기업 PSAT 대비반',
      'desc': '취준생을 위한 맞춤 스터디'
    },
    {
      'title': '자바스크립트 면접 준비',
      'desc': '프론트엔드 취업 준비생 추천'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text("스터디 매칭"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
              icon: Icon(Icons.notifications_none, color: Colors.grey[700]),
              onPressed: () {}),
          IconButton(
              icon: Icon(Icons.account_circle_outlined, color: Colors.grey[700]),
              onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 상단 배너
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            color: Colors.deepPurpleAccent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("어떤 스터디를 찾고 계신가요?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
                SizedBox(height: 10),
                Text("인기 스터디와 추천 스터디를 만나보세요!",
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          SizedBox(height: 20),

          // 인기 스터디
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("🔥 인기 스터디",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: popularStudies.length,
              itemBuilder: (context, index) {
                final study = popularStudies[index];
                return Container(
                  width: 140,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          study['image']!,
                          height: 90,
                          width: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(study['title']!,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text(study['category']!,
                                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 추천 스터디
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("🎯 맞춤형 스터디 추천",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: recommendedStudies.length,
            itemBuilder: (context, index) {
              final study = recommendedStudies[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(study['title']!,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(height: 6),
                    Text(study['desc']!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              );
            },
          ),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '커뮤니티'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이'),
        ],
      ),
    );
  }
}
