import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var currentuser;
final _fireStore = Firestore.instance;


class ChatScreen extends StatefulWidget {
  static String id = 'chatscreen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
 bool isMe;
 final controller = TextEditingController();

  String message;
  final _auth = FirebaseAuth.instance;

  void getUser()async{
    try {
      var activeuser = await _auth.currentUser();
        if(activeuser!=null) {
          currentuser = activeuser;
        }
    }
    catch(e){print(e);}
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  void getData()async {
//    var qss = await _fireStore.collection('messages').getDocuments();
//    for (var dss in qss.documents){
//      print (dss.data);
    await for (var qss in _fireStore.collection('messages').snapshots()) {
       for(var dss in qss.documents){
        print(dss.data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pushNamed(context, LoginScreen.id);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            NewStreamBuilder(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: (value) {
                        message= value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      controller.clear();
                      _fireStore.collection('messages').add({
                        'sender' : currentuser.email,
                        'text' : message,
                        'time' : DateTime.now().millisecondsSinceEpoch
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewStreamBuilder extends StatelessWidget {
  const NewStreamBuilder() ;


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore.collection('messages').orderBy('time',descending: false).snapshots(),
      builder: (context,snapshot) {
        List<MessageBubble> oftext = [];
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
          for(var dss in snapshot.data.documents.reversed){
            var sender = dss.data['sender'];
            var text = dss.data['text'];
            var item = MessageBubble(sender: sender,text: text,isMe: sender == currentuser.email);
            oftext.add(item);

        }
           return Expanded(
             child: ListView(
               reverse: true,
               children: oftext,
             ),
           );
      }
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.text , this.sender,this.isMe});
  final text;
  final sender;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: <Widget>[
          Text('$sender',
            style: TextStyle(
                fontSize: 15,
                color: Colors.grey

            ),),
          Material(
            elevation: 6,
            borderRadius: BorderRadius.only(topLeft: isMe? Radius.circular(30):Radius.circular(0),
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
            topRight: isMe?Radius.circular(0):Radius.circular(30)
            ),
            color: isMe?Colors.blueAccent:Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: Text('$text'
                  ,style: TextStyle(
                      fontSize: 20,
                    color: isMe?Colors.white:Colors.black)
                ),
              ),
           ),
        ],
      ),
    );
  }
}

