import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'WebSocket Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController scrollController = ScrollController();
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://ip address:8080'),
    // Add your ip address
  );
  TextEditingController controller = TextEditingController();
  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Demo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: channel.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<String> rawdata = [];
                  try {
                    rawdata = snapshot.data
                        .toString()
                        .replaceAll("[", "")
                        .replaceAll("]", "")
                        .split(",");

                    log("data ${rawdata.runtimeType} $rawdata");
                  } catch (e) {
                    log("data err ${e}");
                  }

                  return showDataInList(rawdata);
                  Text(snapshot.data.toString());
                } else {
                  return const Center(child: Text("Start Chat"));
                }
              },
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  constraints:
                      const BoxConstraints(maxHeight: 120, minHeight: 30),
                  child: TextField(
                    maxLines: 5,
                    minLines: 1,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.multiline,
                    controller: controller,
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      channel.sink.add(controller.text.trim());
                      controller.clear();
                    }

                    _scrollDown();
                  },
                  icon: const Icon(Icons.send))
            ],
          )
        ],
      ),
    );
  }

  void _scrollDown() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  Widget showDataInList(List<String> rawdata) {
    return ListView.builder(
      controller: scrollController,
      itemCount: rawdata.length,
      itemBuilder: (context, i) {
        return Align(
          alignment: i % 2 != 0 ? Alignment.centerLeft : Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ClipPath(
              clipper: ChatBubbleClipperNoRadius(i),
              child: Container(
                constraints: BoxConstraints(
                    minHeight: 40,
                    maxWidth: MediaQuery.of(context).size.width * 0.7),
                color: i % 2 != 0
                    ? const Color.fromARGB(255, 207, 245, 209)
                    : const Color.fromARGB(255, 219, 225, 219),
                alignment: Alignment.center,
                child: Text(
                  rawdata[i],
                  style: TextStyle(
                    color: i % 2 == 0
                        ? const Color.fromARGB(255, 6, 9, 6)
                        : const Color.fromARGB(255, 5, 35, 59),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ChatBubbleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double radius = 10;
    final width = size.width;
    final height = size.height;

    final path = Path();

    path.moveTo(0, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class ChatBubbleClipperNoRadius extends CustomClipper<Path> {
  final int i;
  const ChatBubbleClipperNoRadius(this.i);

  @override
  Path getClip(Size size) {
    bool leftSide = i % 2 != 0;
    final double radius = 10;
    final width = size.width;
    final height = size.height;
    final Radius rad = Radius.circular(radius);
    final path = Path();
    if (leftSide) {
      path.moveTo(0, 0);

      path.lineTo(width - radius, 0);
      path.arcToPoint(Offset(width, radius), radius: Radius.circular(radius));
      path.lineTo(width, height - radius);
      path.arcToPoint(Offset(width - radius, height),
          radius: Radius.circular(radius));

      path.lineTo(radius + radius, height);
      path.arcToPoint(Offset(radius, height - radius),
          radius: Radius.circular(radius));
      path.lineTo(radius, radius);
      path.close();

      return path;
    } else {
      path.moveTo(width, 0);
      path.lineTo(radius, 0);
      path.arcToPoint(Offset(0, radius), radius: rad, clockwise: false);
      path.lineTo(0, height - radius);
      path.arcToPoint(Offset(radius, height), radius: rad, clockwise: false);
      path.lineTo(width - radius * 2, height);
      path.arcToPoint(Offset(width - radius, height - radius),
          radius: rad, clockwise: false);
      path.lineTo(width - radius, radius);

      path.close();
      return path;
    }
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
