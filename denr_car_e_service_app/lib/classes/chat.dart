import 'dart:convert'; // For base64 encoding/decoding
import 'dart:typed_data'; // For typed data
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

    if (user != null) {
      fetchImageFromFirestore();
    }
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

      if (doc.exists) {
        String base64String = doc['photo'];

        Uint8List decodedBytes = base64Decode(base64String);

        setState(() {
          imageBytes = decodedBytes;
          isImageLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching or decoding image: $e");
      setState(() {
        isImageLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mecenro', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
        body: const Center(child: Text('You must be logged in to chat.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mecenro', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
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
                      final aTimestamp = a.value['timestamp'];
                      final bTimestamp = b.value['timestamp'];

                      final format = DateFormat('MM/dd/yy h:mm a');
                      DateTime aTime, bTime;

                      try {
                        aTime = format.parse(aTimestamp);
                      } catch (_) {
                        aTime = DateTime.fromMillisecondsSinceEpoch(0);
                      }

                      try {
                        bTime = format.parse(bTimestamp);
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
                    horizontal: Responsive.getWidthScale(10.0),
                    vertical: Responsive.getHeightScale(10.0),
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

                    final formattedTime = format.format(dateTime);

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: Responsive.getHeightScale(4.0),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isMe)
                            Column(
                              children: [
                                CircleAvatar(
                                  radius: Responsive.getWidthScale(12.0),
                                  backgroundImage: const AssetImage(
                                    'lib/images/logo.png',
                                  ),
                                  backgroundColor: Colors.transparent,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Admin',
                                  style: TextStyle(fontSize: 9),
                                ),
                              ],
                            ),

                          if (!isMe)
                            SizedBox(width: Responsive.getWidthScale(10.0)),
                          Flexible(
                            child: Column(
                              crossAxisAlignment:
                                  isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Responsive.getWidthScale(10.0),
                                    vertical: Responsive.getHeightScale(10.0),
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isMe
                                            ? const Color.fromARGB(
                                              212,
                                              5,
                                              185,
                                              5,
                                            )
                                            : Colors.grey[300],
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(14),
                                      topRight: const Radius.circular(14),
                                      bottomLeft: Radius.circular(
                                        isMe ? 14 : 0,
                                      ),
                                      bottomRight: Radius.circular(
                                        isMe ? 0 : 14,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    data['message'] ?? '',
                                    style: TextStyle(
                                      color:
                                          isMe ? Colors.white : Colors.black87,
                                      fontSize: Responsive.getTextScale(12.5),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  formattedTime,
                                  style: TextStyle(
                                    fontSize: Responsive.getTextScale(9.0),
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isMe)
                            SizedBox(width: Responsive.getWidthScale(10.0)),
                          if (isMe)
                            CircleAvatar(
                              radius: Responsive.getWidthScale(12.0),
                              backgroundImage:
                                  isImageLoading
                                      ? const AssetImage(
                                        'lib/images/logo.png',
                                      ) // Placeholder
                                      : (imageBytes != null
                                          ? MemoryImage(imageBytes!)
                                          : const AssetImage(
                                            'lib/images/user.png',
                                          )), // User's image
                              backgroundColor: Colors.transparent,
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

class _MessageInputField extends StatelessWidget {
  const _MessageInputField();

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    final User? user = FirebaseAuth.instance.currentUser;

    void _sendMessage() async {
      if (_controller.text.trim().isEmpty || user == null) return;

      try {
        final messageRef =
            FirebaseDatabase.instance
                .ref()
                .child('chats')
                .child(user.uid)
                .push();

        final nowFormatted = DateFormat(
          'MM/dd/yy h:mm a',
        ).format(DateTime.now());
        final indicator = FirebaseDatabase.instance.ref().child('indicator');

        await indicator.child(user.uid).set('sent');

        await messageRef.set({
          'senderID': user.uid,
          'message': _controller.text.trim(),
          'timestamp': nowFormatted,
        });

        _controller.clear();
      } catch (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to send message')));
      }
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.getWidthScale(12.0),
        vertical: Responsive.getHeightScale(10.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.getWidthScale(14.0),
              ),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(width: Responsive.getWidthScale(10.0)),
          CircleAvatar(
            backgroundColor: Colors.green,
            radius: Responsive.getWidthScale(20.0),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
