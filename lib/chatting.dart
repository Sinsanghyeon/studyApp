import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '스터디 그룹 채팅',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.teal[50],
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          surfaceTint: Colors.transparent, // Material 3의 Surface Tint 제거
        ),
      ),
      home: const ChatScreen(),
    );
  }
}

/// ChatMessage 모델: 각 메시지의 발신자, 내용, 타임스탬프, 그리고 본인 여부 저장
class ChatMessage {
  final String sender;
  final String message;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
    this.isMe = false,
  });
}

/// ChatScreen: 채팅 메시지를 표시하고, 그룹 정보 및 출석 체크, 일간 출석표, 방장 기능을 포함한 채팅 화면
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();

  // 참가자 목록 및 단일 출석 체크 기록 (null이면 미출석, 값이 있으면 해당 시간에 출석 체크 완료)
  final Map<String, DateTime?> _attendanceRecords = {
    "나": null,
    "김호현": null,
    "민재홍": null,
    "오은수": null,
  };

  // 기본 방장: "나"가 방장
  String _roomLeader = "나";

  // 일간 출석 데이터
  final Map<String, Map<String, bool>> _dailyAttendanceRecords = {
    "2025-03-19": {
      "나": true,
      "김호현": true,
      "민재홍": true,
      "오은수": true,
    },
    "2025-03-26": {
      "나": true,
      "김호현": true,
      "민재홍": false,
      "오은수": true,
    },
    "2025-04-02": {
      "나": true,
      "김호현": true,
      "민재홍": true,
      "오은수": false,
    },
  };

  /// 채팅 메시지 전송 함수
  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(
        sender: '나',
        message: text,
        timestamp: DateTime.now(),
        isMe: true,
      ));
    });
    _textController.clear();
  }

  /// 메시지 버블 위젯: 본인과 상대방 메시지를 구분하는 것임
  Widget _buildChatBubble(ChatMessage message) {
    final bool isMe = message.isMe;
    final bubbleColor = isMe ? Colors.teal[300] : Colors.white;
    final textColor = isMe ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe)
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text(
                    message.sender.substring(0, 1),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              if (!isMe) const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(color: textColor),
                  ),
                ),
              ),
              if (isMe) const SizedBox(width: 8),
              if (isMe)
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text(
                    message.sender.substring(0, 1),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('HH:mm').format(message.timestamp),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// 채팅 입력창: 텍스트 입력 필드와 전송 버튼을 포함함ㄴ
  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration.collapsed(hintText: "메시지를 입력하세요"),
              onSubmitted: _handleSubmitted,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }

  /// 방장 넘기기 기능: 현재 방장 외의 참가자 목록을 보여주고, 새 방장 선택가능
  void _transferRoomLeader() {
    List<String> candidates = _attendanceRecords.keys.where((name) => name != _roomLeader).toList();
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("새로운 방장을 선택하세요"),
          children: candidates.map((candidate) {
            return SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _roomLeader = candidate;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("방장이 $candidate 으로 변경되었습니다.")),
                );
              },
              child: Text(candidate),
            );
          }).toList(),
        );
      },
    );
  }

  /// 그룹 정보와 개별 출석 체크 내역, 일간 출석표, 그리고 방장 정보를 한 번에 보여주는 대화상자임
  void _showGroupAndAttendanceInfo() {
    final List<String> sortedDates = _dailyAttendanceRecords.keys.toList()..sort();
    final List<String> participants = _attendanceRecords.keys.toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("스터디 그룹 정보 및 출석 체크"),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("모임 시간: 매주 수요일 오후 7시"),
                  const Text("장소: 부산 서면"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text("방장: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_roomLeader, style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (_roomLeader == "나")
                        TextButton(
                          onPressed: _transferRoomLeader,
                          child: const Text("방장 넘기기"),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text("참여자:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text("- 김호현"),
                  const Text("- 민재홍"),
                  const Text("- 오은수"),
                  const SizedBox(height: 16),
                  const Text("개별 출석 체크 내역", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  DataTable(
                    columns: const [
                      DataColumn(label: Text("이름")),
                      DataColumn(label: Text("출석 여부")),
                      DataColumn(label: Text("출석 시간")),
                    ],
                    rows: _attendanceRecords.entries.map((entry) {
                      final name = entry.key;
                      final time = entry.value;
                      final status = time != null ? "출석" : "미출석";
                      final timeStr = time != null ? DateFormat('HH:mm').format(time) : "";
                      final displayName = name == _roomLeader ? "$name (방장)" : name;
                      return DataRow(cells: [
                        DataCell(Text(displayName)),
                        DataCell(Text(status)),
                        DataCell(Text(timeStr)),
                      ]);
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text("일간 출석표", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  DataTable(
                    columns: [
                      const DataColumn(label: Text("이름")),
                      for (var date in sortedDates)
                        DataColumn(label: Text(date)),
                    ],
                    rows: participants.map((name) {
                      return DataRow(
                        cells: [
                          DataCell(Text(name)),
                          for (var date in sortedDates)
                            DataCell(Text(_dailyAttendanceRecords[date]?[name] == true ? "O" : "X")),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("닫기"),
            ),
          ],
        );
      },
    );
  }

  /// 출석 체크 기능:
  /// - 현재 사용자가 방장("나")이면 전체 참가자에 대해 출석 체크를 진행?
  /// - 아니면 자신의 출석만 갱신(애매)- 수정필요함
  void _checkAttendance() {
    if (_roomLeader == "나") {
      setState(() {
        _attendanceRecords.updateAll((key, value) => DateTime.now());
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("전체 출석 체크가 완료되었습니다.")),
      );
    } else {
      setState(() {
        if (_attendanceRecords["나"] == null) {
          _attendanceRecords["나"] = DateTime.now();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("출석 체크가 완료되었습니다.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("이미 출석 체크가 완료되었습니다.")),
          );
        }
      });
    }
    _showGroupAndAttendanceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("스터디 그룹 채팅"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showGroupAndAttendanceInfo,
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: _checkAttendance,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildChatBubble(
                  _messages[_messages.length - index - 1],
                );
              },
            ),
          ),
          const Divider(height: 1),
          _buildTextComposer(),
        ],
      ),
    );
  }
}
