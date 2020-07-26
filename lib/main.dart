import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:tflite/tflite.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ML know me',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  final picker = ImagePicker();
  List _outputs;
  bool _loading=false;
  String result;

  //loading model
  @override
  void initState(){
    super.initState();
    _loading=true;

   loadModel().then((value){
     setState(() {
       _loading=false;
     });
   });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
        title: Text('Know Me'),
      ),
      body: _loading ? Container(
        alignment: Alignment.center,
        child: Text("Loading..",style: TextStyle(color: Colors.green,fontSize: 20),),
      ):
      Container(
        child: Column(
          children: <Widget>[
            _image==null? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(),
            ): Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(_image),
            ),
            SizedBox(
              height: 20,
            ),
            _outputs!=null? Text("${result.substring(1)}", style: TextStyle(color: Colors.green,fontSize: 20.0),):
                Container(
                  child: Text("Pick the image"),
                ),
          ],
        ),
      ),

      floatingActionButton:SpeedDial(
        // both default to 16
        marginRight: 18,
        marginBottom: 20,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        // this is ignored if animatedIcon is non null
        // child: Icon(Icons.add),
        // If true user is forced to close dial manually
        // by tapping main button and overlay is not rendered.
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        tooltip: 'Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
              child: Icon(Icons.camera),
              backgroundColor: Colors.green,
              label: 'Camera',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => getImage("camera"),
          ),
          SpeedDialChild(
            child: Icon(Icons.photo_album),
            backgroundColor: Colors.deepPurple,
            label: 'Gallery',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => getImage("gallery"),
          ),
        ],
      ) ,
    );
  }

  //pick image
  Future getImage(String type) async {
    // image file from camera
    if(type=="camera"){
      final pickedfile = await picker.getImage(source: ImageSource.camera);
      setState(() {
        _image = File(pickedfile.path);
      });
      classifyImage(_image);
    }
    // image file from gallery
    else{
      final pickedfile = await picker.getImage(source: ImageSource.gallery);
      setState(() {
        _image = File(pickedfile.path);
      });
      classifyImage(_image);
    }
  }

  // Load model
  loadModel() async{
    await Tflite.loadModel(model: "assets/model_unquant.tflite",labels: "assets/labels.txt",);
  }

  // image classification
  classifyImage(File image) async{
    var output= await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading=false;
      _outputs=output;
      result=_outputs[0]["label"];
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

}
