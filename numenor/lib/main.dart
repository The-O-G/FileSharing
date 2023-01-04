import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'APIcalling.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  final String title = "title";

  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int progress = 0;
  final ReceivePort _receivePort = ReceivePort();
  final fileName = TextEditingController();

  static downloadingCallback(id, status, progress) {
    SendPort? sendPort = IsolateNameServer.lookupPortByName("downloading");
    sendPort?.send([id, status, progress]);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    IsolateNameServer.registerPortWithName(_receivePort.sendPort, "downloading");
    _receivePort.listen((message) {
      setState(() {
        progress = message[2];
      });
      print(progress);
    });
    FlutterDownloader.registerCallback(downloadingCallback);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Text("$progress", style: const TextStyle(fontSize: 40),),

            const SizedBox(height: 60,),

            ElevatedButton(
                child: const Text("Upload"),
                onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowData(),
                        )
                )
            ),
          TextField(
            controller: fileName,
            textAlign: TextAlign.center,
            onChanged: (text){
              print("$text");
            },
          ),

          ElevatedButton(
              child: const Text("Downloading"),
              onPressed: () async {
                final status = await Permission.storage.request();

                if (status.isGranted) {
                  final externalDir = await getExternalStorageDirectory();
                  final id = await FlutterDownloader.enqueue(
                    url:"https://sendfile.rubiks-tesseract.repl.co/dnld/${fileName.text}",
                    savedDir: '/storage/emulated/0/Download',
                    fileName: fileName.text,
                    showNotification: true,
                    openFileFromNotification: true,
                    saveInPublicStorage: true,
                  );
                  print('------------------------------------------------------------Here-------------------------------------');
                  print(externalDir!.path);

                } else {
                  print("Permission denied");
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

