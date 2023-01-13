import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ImagePicker _picker;
  File? image;
  String result = 'Your result will be shown here.';
  dynamic barcodeScanner;

  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();
    final List<BarcodeFormat> formats = [BarcodeFormat.all];
    barcodeScanner = BarcodeScanner(formats: formats);
  }

  @override
  void dispose() {
    super.dispose();
    barcodeScanner.close();
  }

  doBarcodeScanning() async {
    InputImage inputImage = InputImage.fromFile(image!);
    final List<Barcode> barcodes =
        await barcodeScanner.processImage(inputImage);
    for (Barcode barcode in barcodes) {
      final BarcodeType type = barcode.type;
      final Rect? boundingBox = barcode.boundingBox;
      final String? displayValue = barcode.displayValue;
      final String? rawValue = barcode.rawValue;

      switch (type) {
        case BarcodeType.wifi:
          BarcodeWifi barcodeWifi = barcode.value as BarcodeWifi;
          result =
              'WIFI:\n Name: ${barcodeWifi.ssid}\n Password: ${barcodeWifi.password}';
          break;
        case BarcodeType.url:
          BarcodeUrl barcodeUrl = barcode.value as BarcodeUrl;
          result = 'URL\n Web link: ${barcodeUrl.url}';
          break;
      }
      setState(() {
        result;
      });
    }
  }

  imgFromGallery() async {
    final XFile? pickedImg =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImg != null) {
      setState(() {
        image = File(pickedImg.path);
        doBarcodeScanning();
      });
    }
  }

  imgFromCamera() async {
    final XFile? pickedImg =
        await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      image = File(pickedImg!.path);
      doBarcodeScanning();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 100),
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        const Center(
                          child: Image(
                            image: AssetImage('images/frame.jpg'),
                            height: 350,
                            width: 350,
                          ),
                        ),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: () {
                              imgFromGallery();
                            },
                            onLongPress: () {
                              imgFromCamera();
                            },
                            child: image != null
                                ? Image.file(
                                    image!,
                                    height: 325,
                                    width: 325,
                                    fit: BoxFit.fill,
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    size: 80,
                                    color: Colors.black,
                                  ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: Text(
                      result,
                      style: const TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }
}
