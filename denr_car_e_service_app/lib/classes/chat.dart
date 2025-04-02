import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize Responsive class
    Responsive.init(context);

    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mecenro', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('chats')
                      .doc(user?.uid) // Use the user UID to find the document.
                      .collection('messages') // Subcollection for messages.
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                return ListView(
                  reverse: true,
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.getWidthScale(
                      12.0,
                    ), // Responsive padding
                    vertical: Responsive.getHeightScale(
                      10.0,
                    ), // Responsive padding
                  ),
                  children:
                      snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final isMe = data['senderId'] == user?.uid;
                        final timestamp = data['timestamp'] as Timestamp?;

                        // Formatting the date and time
                        final formattedDate =
                            timestamp != null
                                ? DateFormat('MMM dd').format(
                                  timestamp.toDate(),
                                ) // Month and day
                                : '';
                        final formattedTime =
                            timestamp != null
                                ? DateFormat('HH:mm').format(
                                  timestamp.toDate(),
                                ) // Hour and minute
                                : '';

                        // Get the image URL from Firestore if available
                        final imageUrl =
                            data['imageUrl']; // Assuming Firestore contains the image URL

                        return Align(
                          alignment:
                              isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment:
                                isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: Responsive.getHeightScale(6.0),
                                ), // Responsive margin
                                padding: EdgeInsets.symmetric(
                                  horizontal: Responsive.getWidthScale(
                                    14.0,
                                  ), // Responsive padding
                                  vertical: Responsive.getHeightScale(
                                    10.0,
                                  ), // Responsive padding
                                ),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe ? Colors.blue : Colors.grey[300],
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(isMe ? 16 : 0),
                                    bottomRight: Radius.circular(isMe ? 0 : 16),
                                  ),
                                ),
                                child: Text(
                                  data['message'] ?? '',
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black87,
                                    fontSize: Responsive.getTextScale(
                                      16.0,
                                    ), // Responsive font size
                                  ),
                                ),
                              ),
                              if (imageUrl != null && imageUrl.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: Responsive.getHeightScale(
                                      4.0,
                                    ), // Responsive padding
                                  ),
                                  child: Image.network(
                                    imageUrl,
                                    width: Responsive.getWidthScale(
                                      200.0,
                                    ), // Responsive width
                                    height: Responsive.getHeightScale(
                                      200.0,
                                    ), // Responsive height
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: Responsive.getHeightScale(
                                      4.0,
                                    ), // Responsive padding
                                  ),
                                  child: Image.asset(
                                    'lib/images/logo.png', // Use a default local image
                                    width: Responsive.getWidthScale(
                                      15.0,
                                    ), // Responsive width
                                    height: Responsive.getHeightScale(
                                      15.0,
                                    ), // Responsive height
                                    fit: BoxFit.cover,
                                  ),
                                ),

                              // Displaying formatted date and time in a single line
                              Text(
                                '$formattedDate, $formattedTime',
                                style: TextStyle(
                                  fontSize: Responsive.getTextScale(
                                    12.0,
                                  ), // Responsive font size
                                  color: Colors.black54,
                                ),
                              ),
                              // Displaying Sent/Delivered status
                              Text(
                                isMe
                                    ? 'Sent'
                                    : 'Seen', // Sent for the current user, Delivered for others
                                style: TextStyle(
                                  fontSize: Responsive.getTextScale(
                                    12.0,
                                  ), // Responsive font size
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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
  const _MessageInputField({super.key});

  @override
  State<_MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<_MessageInputField> {
  final TextEditingController _controller = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(user?.uid) // User document ID
          .collection('messages') // Subcollection for messages
          .add({
            'senderId': user?.uid,
            'receiverId':
                'mPZ4nMNESZfxTtxkXHj2sHnAdYm1', // replace with actual admin UID if available
            'message': _controller.text.trim(),
            'timestamp': FieldValue.serverTimestamp(),
            'imageUrl':
                '', // Optional: If you want to send an image URL, use this field.
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
        horizontal: Responsive.getWidthScale(12.0), // Responsive padding
        vertical: Responsive.getHeightScale(10.0), // Responsive padding
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.getWidthScale(14.0),
              ), // Responsive padding
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
          SizedBox(width: Responsive.getWidthScale(10.0)), // Responsive gap
          CircleAvatar(
            backgroundColor: Colors.green,
            radius: Responsive.getWidthScale(20.0), // Responsive radius
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
