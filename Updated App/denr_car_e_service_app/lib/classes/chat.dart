import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:denr_car_e_service_app/model/responsive.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final User? user = FirebaseAuth.instance.currentUser;

  Uint8List? imageBytes;
  bool isImageLoading = true;

  @override
  void initState() {
    super.initState();
    if (user != null) fetchImageFromFirestore();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchImageFromFirestore() async {
    try {
      if (user == null) return;
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('mobile_users')
              .doc(user!.uid)
              .get();

      if (doc.exists && doc['photo'] != null) {
        Uint8List decodedBytes = base64Decode(doc['photo']);
        setState(() {
          imageBytes = decodedBytes;
          isImageLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching image: $e");
      setState(() {
        isImageLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('You must be logged in to chat.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: const AssetImage('lib/images/logo.png'),
              backgroundColor: Colors.white,
              radius: Responsive.getWidthScale(18),
            ),
            SizedBox(width: Responsive.getWidthScale(12)),
            Text(
              'MeCenro',
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.getTextScale(16),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream:
                  FirebaseDatabase.instance
                      .ref()
                      .child('chats')
                      .child(user!.uid)
                      .onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages.'));
                }

                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text('No messages yet.'));
                }

                Map<dynamic, dynamic> messages =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                final messageList =
                    messages.entries.toList()..sort((a, b) {
                      final format = DateFormat('MM/dd/yy h:mm a');
                      DateTime aTime, bTime;
                      try {
                        aTime = format.parse(a.value['timestamp']);
                      } catch (_) {
                        aTime = DateTime.fromMillisecondsSinceEpoch(0);
                      }
                      try {
                        bTime = format.parse(b.value['timestamp']);
                      } catch (_) {
                        bTime = DateTime.fromMillisecondsSinceEpoch(0);
                      }
                      return aTime.compareTo(bTime);
                    });

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.getWidthScale(10),
                  ),
                  itemCount: messageList.length,
                  itemBuilder: (context, index) {
                    final data = messageList[index].value;
                    final isMe = data['senderID'] == user!.uid;

                    DateTime dateTime;
                    final format = DateFormat('MM/dd/yy h:mm a');
                    try {
                      dateTime = format.parse(data['timestamp']);
                    } catch (_) {
                      dateTime = DateTime.now();
                    }

                    final formattedTime = DateFormat('h:mm a').format(dateTime);

                    return Container(
                      margin: EdgeInsets.symmetric(
                        vertical: Responsive.getHeightScale(6),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment:
                            isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                        children: [
                          if (!isMe)
                            CircleAvatar(
                              radius: Responsive.getWidthScale(10),
                              backgroundImage: const AssetImage(
                                'lib/images/logo.png',
                              ),
                              backgroundColor: Colors.white,
                            ),
                          if (!isMe)
                            SizedBox(width: Responsive.getWidthScale(8)),
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.getWidthScale(12),
                                vertical: Responsive.getHeightScale(8),
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isMe
                                        ? const Color(0xFF05b905)
                                        : Colors.grey[300],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(
                                    Responsive.getWidthScale(15),
                                  ),
                                  topRight: Radius.circular(
                                    Responsive.getWidthScale(15),
                                  ),
                                  bottomLeft: Radius.circular(
                                    isMe ? Responsive.getWidthScale(15) : 0,
                                  ),
                                  bottomRight: Radius.circular(
                                    isMe ? 0 : Responsive.getWidthScale(15),
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['message'] ?? '',
                                    style: TextStyle(
                                      color:
                                          isMe ? Colors.white : Colors.black87,
                                      fontSize: Responsive.getTextScale(13),
                                    ),
                                  ),
                                  SizedBox(
                                    height: Responsive.getHeightScale(4),
                                  ),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      fontSize: Responsive.getTextScale(8),
                                      color:
                                          isMe
                                              ? Colors.white70
                                              : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isMe)
                            SizedBox(width: Responsive.getWidthScale(8)),
                          if (isMe)
                            CircleAvatar(
                              radius: Responsive.getWidthScale(10),
                              backgroundImage:
                                  isImageLoading
                                      ? const AssetImage('lib/images/logo.png')
                                          as ImageProvider
                                      : (imageBytes != null
                                          ? MemoryImage(imageBytes!)
                                          : const AssetImage(
                                            'lib/images/user.png',
                                          )),
                              backgroundColor: Colors.white,
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const _MessageInputField(),
        ],
      ),
    );
  }
}

class _MessageInputField extends StatefulWidget {
  const _MessageInputField();

  @override
  State<_MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<_MessageInputField> {
  final TextEditingController _controller = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty || user == null) return;

    try {
      final messageRef =
          FirebaseDatabase.instance
              .ref()
              .child('chats')
              .child(user!.uid)
              .push();

      final nowFormatted = DateFormat('MM/dd/yy h:mm a').format(DateTime.now());

      await FirebaseDatabase.instance
          .ref()
          .child('indicator')
          .child(user!.uid)
          .set({'status': 'sent', 'timestamp': nowFormatted});

      await messageRef.set({
        'senderID': user!.uid,
        'message': _controller.text.trim(),
        'timestamp': nowFormatted,
      });

      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to send message')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.getWidthScale(8),
        vertical: Responsive.getHeightScale(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.getWidthScale(10),
                vertical: Responsive.getHeightScale(1),
              ),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(
                  Responsive.getWidthScale(13),
                ),
              ),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                style: TextStyle(fontSize: Responsive.getTextScale(12)),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(width: Responsive.getWidthScale(5)),
          CircleAvatar(
            backgroundColor: Colors.green,
            radius: Responsive.getWidthScale(20),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.white,
                size: Responsive.getWidthScale(18),
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
