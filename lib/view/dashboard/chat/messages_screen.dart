import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:intl/intl.dart';

class MessagesScreen extends StatefulWidget {
  final String name;
  final String image;
  final String email;
  final String receiverId;

  MessagesScreen({
    required this.name,
    required this.image,
    required this.email,
    required this.receiverId,
  });

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  DateTime? selectedTimeStamp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe5f3fd),
      appBar: AppBar(
        backgroundColor: Color(0xFFe5f3fd),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.image),
              radius: 18,
            ),
            SizedBox(width: 10),
            Text(widget.name),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('senderId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .where('receiverId', isEqualTo: widget.receiverId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> senderSnapshot) {
                if (senderSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (senderSnapshot.hasError) {
                  return Center(child: Text('Error: ${senderSnapshot.error}'));
                }

                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('messages')
                      .where('senderId', isEqualTo: widget.receiverId)
                      .where('receiverId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> receiverSnapshot) {
                    if (receiverSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (receiverSnapshot.hasError) {
                      return Center(child: Text('Error: ${receiverSnapshot.error}'));
                    }

                    List<QueryDocumentSnapshot> messages = [];
                    messages.addAll(senderSnapshot.data!.docs);
                    messages.addAll(receiverSnapshot.data!.docs);

                    messages.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

                    return ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.all(10),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data = messages[index].data() as Map<String, dynamic>;
                        bool isSender = data['senderId'] == FirebaseAuth.instance.currentUser?.uid;
                        bool isSeen = data['isSeen'] ?? false;

                        return Row(
                          mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isSender)
                              CircleAvatar(
                                backgroundImage: NetworkImage(widget.image),
                                radius: 10,
                              ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  if (!isSender)
                                    Text(
                                      widget.name,
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ChatBubble(
                                    clipper: ChatBubbleClipper5(
                                      type: isSender ? BubbleType.sendBubble : BubbleType.receiverBubble,
                                    ),
                                    alignment: isSender ? Alignment.topRight : Alignment.bottomLeft,
                                    margin: EdgeInsets.only(top: 8),
                                    backGroundColor: isSender ? Colors.blueAccent : Colors.black.withOpacity(0.9),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['text'],
                                          style: TextStyle(color: isSender ? Colors.white : Colors.white),
                                        ),
                                        // if (!isSender && !isSeen)
                                        //   Text('Seen', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                        Text(
                                          _formatTimestamp(data['timestamp'].toDate()),
                                          style: TextStyle(color: Colors.white38, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _textEditingController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        cursorColor: Colors.blueAccent,
                        style: TextStyle(fontWeight: FontWeight.normal),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    iconSize: 25,
                    color: Colors.blueAccent,
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
SizedBox(height: 3,)
        ],
      ),
    );
  }

  // Function to format the timestamp based on the current date
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    if (now.year != timestamp.year) {
      // If the year is different, display the full date
      return DateFormat.yMMMd().add_jm().format(timestamp);
    } else if (now.day != timestamp.day) {
      // If the day is different (not today), display only the day and time
      return DateFormat.MMMd().add_jm().format(timestamp);
    } else {
      // If it's today, display only the time
      return DateFormat.jm().format(timestamp);
    }
  }
  bool _isSendingMessage = false;
  void _sendMessage() async {
    String message = _textEditingController.text.trim();
    if (message.isNotEmpty) {
      String senderId = FirebaseAuth.instance.currentUser?.uid ?? "Unknown sender";
      print("Sending message: '$message' from sender with ID: $senderId to receiver with ID: ${widget.receiverId}");

      try {
        await FirebaseFirestore.instance.collection('messages').add({
          'senderId': senderId,
          'receiverId': widget.receiverId,
          'text': message,
          'timestamp': Timestamp.now(),
          'isSeen': false
        });
        _textEditingController.clear();
        print("Message sent successfully");



      } catch (error) {
        print("Error sending message: $error");
      }
    } else {
      print("Message is empty, not sending.");
    }
  }
}
