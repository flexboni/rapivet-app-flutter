import 'dart:async';
import 'dart:io';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swork_raon/0_Commons_totally/JToast.dart';
import 'package:swork_raon/RapiVet/7_Test_Guide.dart';
import 'package:swork_raon/TestModule/First_cameraTest/subFuncs/ImgSearch_subFuncs.dart';
import 'package:swork_raon/TestModule/First_cameraTest/subFuncs/animated_guide.dart';
import '../../0_CommonThisApp/rapivetStatics.dart';
import 'package:swork_raon/RapiVet/SceneSubFuncs/0_commonUI.dart';
import 'package:swork_raon/TestModule/First_cameraTest/testStatics.dart';
import 'package:swork_raon/TestModule/First_cameraTest/image_converter.dart';
import 'package:swork_raon/TestModule/First_cameraTest/myparams.dart';
import 'package:swork_raon/TestModule/First_cameraTest/opencv_originals_ex.dart';
import 'package:swork_raon/TestModule/First_cameraTest/process_after_class.dart';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:isolate';
import 'dart:math';
import 'package:image/image.dart' as imglib;

import '../Loading_imgsearch.dart';
import 'horizontal_checker.dart';

// jujego

class ImgSearchHome extends StatefulWidget {
  ImgSearchHome({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _ImgSearchHomeState createState() => _ImgSearchHomeState();
}

class _ImgSearchHomeState extends State<ImgSearchHome>
    with TickerProviderStateMixin {
  // test 모드에서는 어떻게 이미지가 입력되는지 확인가능함. test 모드에서는 프레임단위로 들고오는거 안 함.
  bool is_test_mode = false;

  int _stick_error_count = 0;

  bool is_computing = false;
  int compute_count = 0;

  bool is_pause_for_safeOperation = true;

  bool isPaused = true;
  CameraController controller;
  List cameras;
  int selectedCameraIdx;
  String imagePath;
  static const MethodChannel _channel = const MethodChannel('tflite');
  String model;
  List<dynamic> _recognitions;
  int imageHeight;
  int imageWidth;
  CameraImage photo;

  Image imageNew;

  bool _is_resolution_initialized = false;
  int frameH = 480;
  int frameW = 720;

  StreamSubscription<dynamic> _streamSubscriptions;

  @override
  void initState() {
    testStatics.is_to_show_jpg_to_check = false;
    is_pause_for_safeOperation = true;
    turn_off_is_pause_for_safeOperation(2000);

    _get_path();
    testStatics.is_to_show_result = false;
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      testStatics.is_to_captureFrame = false;
      imageNew = Image.asset("assets/temp.png");
      is_computing = false;
      compute_count = 0;

      if (cameras.length > 0) {
        setState(() {
          selectedCameraIdx = 0;
        });
        print("_initCameraController!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        _initCameraController(cameras[selectedCameraIdx]);
      } else {
        print("No camera available");
      }
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });

    //_update_looking();
    _initialize();
  }

  turn_off_is_pause_for_safeOperation(int time_mill)async{
    await Future.delayed(Duration(milliseconds: time_mill));
    is_pause_for_safeOperation = false;
  }

  _initialize() async {
    // prefs = await SharedPreferences.getInstance();
    // prefs.setBool("is_finded", false);
    testStatics.is_finded_area = false;
    testStatics.is_loading_forSearching = false;
    testStatics.jpg_to_check = null;
  }

  _get_path() async {
    testStatics.save_directory = await getApplicationSupportDirectory();
    print("!!!!!!!!!!!!!!!!!!");
    print("!!!!!!!!!!!!!!!!!!");
    print("!!!!!!!!!!!!!!!!!!");
    print("저장경로:" + testStatics.save_directory.path);
    print("!!!!!!!!!!!!!!!!!!");
    print("!!!!!!!!!!!!!!!!!!");
    print("!!!!!!!!!!!!!!!!!!");
  }

  int i = 0;

  void _initCameraController(CameraDescription cameraDescription) {
    print(cameraDescription.name);
    print(cameraDescription.sensorOrientation);
    print(cameraDescription.lensDirection);
   // cameraDescription.

    controller = CameraController(cameraDescription, ResolutionPreset.medium,
        enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
    controller.setFocusMode(FocusMode.auto);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.addListener(() {});
      controller.startImageStream((CameraImage img) {
        if (_is_resolution_initialized == false) {
          _is_resolution_initialized = true;
          frameH = img.height;
          frameW = img.width;

          if (Platform.isIOS) {
            print("is ios!@!!!!!!!");

            frameH = img.width;
            frameW = img.height;
          }

          setState(() {});
        }

        if (testStatics.is_to_captureFrame) {
          testStatics.is_to_captureFrame = false;
          call_operation(img);
        }

        if (is_computing == false && is_pause_for_safeOperation ==false) {
          if (testStatics.is_finded_area == false) call_operation(img);
        }

        i++;
      });

      setState(() {});
    });
  }

  // get_img_path() {
  //   String appDocumentsPath = Statics.save_directory.path; // 2
  //   String filePath = '$appDocumentsPath/' + "a.jpg"; //
  //
  //   File file = File(filePath);
  //
  //   return file;
  // }

  @override
  void dispose() {
    print("call controller?.dispose()");
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    double s_width = MediaQuery.of(context).size.width;
    double s_height = MediaQuery.of(context).size.height;

    double camear_area_height = s_height * 0.62;

    callback_setstate() {
      setState(() {});
    }

    callback_loading_on() {
      setState(() {
        testStatics.is_loading_forSearching = true;
      });
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => Test_Guide()));
        return false;
      },
      child: Scaffold(
        backgroundColor: rapivetStatics.app_bg,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    //Padding(padding: new EdgeInsets.all(5)),
                  ],
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      get_upbar(() {}, false, "TESTE", in_width: s_width,
                          callback_goBack: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    Test_Guide()));
                      }),
                      Padding(padding: new EdgeInsets.all(1)),
                      Stack(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            color: Colors.black,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  child: isPaused
                                      ? _cameraPreviewWidget()
                                      : _renderKeypoints(),
                                  //color: Colors.black,
                                  width: camear_area_height * frameH / frameW,
                                  height: camear_area_height,
                                ),
                              ],
                            ),
                          ),
                          animated_guide(camear_area_height),
                          Container(
                            alignment: Alignment.topCenter,
                            child: Visibility(
                              visible: testStatics.is_finded_area,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  //Padding(padding: new EdgeInsets.all(35)),
                                  Container(
                                    height: s_height*0.55,
                                    color: Colors.black,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: _getIMG(),
                                            //color: Colors.black,
                                            width: camear_area_height *
                                                frameH /
                                                frameW,
                                            height: camear_area_height,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                 // Padding(padding: new EdgeInsets.all(10)),
                                  Container(
                                    padding: new EdgeInsets.all(20),
                                    alignment: Alignment.topCenter,
                                    height: s_height*0.3,
                                    color: rapivetStatics.app_bg,
                                    child: get_find_end_check(
                                        context, s_width, s_height, callback_loading_on),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // get_find_end_check(
                      //     context, s_width, s_height, callback_loading_on),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    get_temp_downbar(context, callback_setstate,
                        DOWN_BAR_STATUS.TEST, s_width),
                  ],
                ),
                get_overlay_btns(context, callback_setstate, s_width, s_height),
                show_loading(s_height, s_width, statusBarHeight, this),
                get_test_result(context, is_test_mode, imageNew),
                show_guide_img(s_width, s_height,callback_setstate),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getIMG() {
    if (testStatics.is_to_show_jpg_to_check == false) {
      return Image.asset("assets/black.JPG");
    } else {
      return Image.memory(testStatics.jpg_to_check);
    }
  }

  /// Display Camera preview.
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: CameraPreview(controller),
    );
  }

  /// Display the control bar with buttons to take pictures
  Widget _captureControlRowWidget(context) {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            FloatingActionButton(
                child: (isPaused) ? Icon(Icons.play_arrow) : Icon(Icons.pause),
                backgroundColor: Colors.blueGrey,
                onPressed: () {
                  setState(() {
                    isPaused = !isPaused;
                  });
                })
          ],
        ),
      ),
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    if (cameras == null || cameras.isEmpty) {
      return Spacer();
    }

    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: FlatButton.icon(
            onPressed: _onSwitchCamera,
            icon: Icon(_getCameraLensIcon(lensDirection)),
            label: Text(
                "${lensDirection.toString().substring(lensDirection.toString().indexOf('.') + 1)}")),
      ),
    );
  }

  IconData _getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
  }

  void _onSwitchCamera() {
    selectedCameraIdx =
        selectedCameraIdx < cameras.length - 1 ? selectedCameraIdx + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    _initCameraController(selectedCamera);
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
    print(errorText);

    print('Error: ${e.code}\n${e.description}');
  }

  Future loadModel() async {}

  Future<List> runPoseNetOnFrame(
      {@required List<Uint8List> bytesList,
      int imageHeight = 1280,
      int imageWidth = 720,
      double imageMean = 127.5,
      double imageStd = 127.5,
      int rotation: 90, // Android only
      int numResults = 1,
      double threshold = 0.5,
      int nmsRadius = 20,
      bool asynch = true}) async {
    return await _channel.invokeMethod(
      'runPoseNetOnFrame',
      {
        "bytesList": bytesList,
        "imageHeight": imageHeight,
        "imageWidth": imageWidth,
        "imageMean": imageMean,
        "imageStd": imageStd,
        "rotation": rotation,
        "numResults": numResults,
        "threshold": threshold,
        "nmsRadius": nmsRadius,
        "asynch": asynch,
      },
    );
  }

  List<Widget> _renderKeypoints() {
    var lists = <Widget>[];
    _recognitions.forEach((re) {
      var list = re["keypoints"].values.map<Widget>((k) {
        var x = k["x"];
        var y = k["y"];

        return Positioned(
          left: x - 6,
          top: y - 6,
          width: 100,
          height: 12,
          child: Container(
            child: Text(
              "● ${k["part"]}",
              style: TextStyle(
                color: Color.fromRGBO(37, 213, 253, 1.0),
                fontSize: 12.0,
              ),
            ),
          ),
        );
      }).toList();

      lists.addAll(list);
    });

    return lists;
  }

  ///////// ======================================================================================
  @override
  Widget show_loading(double s_height, double s_width, double statusBarHeight,
      TickerProviderStateMixin tickerProvider) {
    return Visibility(
      visible: testStatics.is_loading_forSearching && is_test_mode == false,
      child: Container(
        height: s_height,
        width: s_width,
        color: Colors.black.withOpacity(0.38),
        child: SpinKitCircle(
          color: Colors.white,
          size: 50.0,
          controller: AnimationController(
              vsync: tickerProvider,
              duration: const Duration(milliseconds: 888)),
        ),
      ),
    );
  }

  //===============================================================================================
  call_operation(CameraImage img) async {
    // 전처리: raw 프레임영상에서 영역 찾기
    is_computing = true;
    List result_list = await process_frameIMG(img);
    print("result!!!!!!!!!!!!!!!!!!!!!!!: " + result_list[0].toString());

    if (result_list[0]) {
      imglib.Image img = result_list[2];
      print(img.height);
      testStatics.is_finded_area = true;
      testStatics.is_loading_forSearching = true;
      await Future.delayed(Duration(milliseconds: 1));
      setState(() {});
      await Future.delayed(Duration(milliseconds: 1));

      // post process 후처리: 영역에 표시해서 유저 확인 가능한 이미지 생성.
      List returnResult = await process_after(result_list);
      testStatics.jpg_to_check = returnResult[0];
      testStatics.compareRect_area_colorSets_list = returnResult[1];
      testStatics.stickRect_area_colorSets_list = returnResult[2];
      testStatics.stick_area_img = returnResult[3];

      testStatics.is_to_show_jpg_to_check = true;

      if (is_test_mode) {
        List<int> stick_jpeg = result_list[10];
        print(stick_jpeg.length);
        imageNew = Image.memory(stick_jpeg);
        testStatics.is_to_show_result = true;
      }

      await Future.delayed(Duration(milliseconds: 1));
      setState(() {});
    } else {
      String error_txt = result_list[1].toString();

      if (is_test_mode) {
        JToast()
            .show_toast(compute_count.toString() + "::: " + error_txt, true);
      } else {
        if (error_txt.indexOf("stick location error") != -1) {

          _stick_error_count++;

          if(_stick_error_count>=3){
            _stick_error_count = 0;
            JToast().show_toast("Insira a tira reagente corretamente. ", false);
          }
        }else{
          _stick_error_count = 0;
        }
      }
    }

    compute_count++;
    print("compute count::: " + compute_count.toString());
    testStatics.is_loading_forSearching = false;
    is_computing = false;

    return;

    // if(is_test_mode){
    //
    //   // 테스트 모드에서는 실패 시에도 이미지를 보여줌.
    //
    //   testStatics.is_finded_area = true;
    //   testStatics.is_loading_forSearching = true;
    //
    //   imglib.Image img = result_list[2];
    //   img = imglib.copyRotate(img, 90, interpolation: imglib.Interpolation.linear);
    //   testStatics.jpg_to_check=imglib.encodeJpg(img, quality: 92);
    //   testStatics.is_to_show_jpg_to_check = true;
    //   await Future.delayed(Duration(milliseconds: 10));
    //   setState(() {});
    // }
  }

  process_after(List result_list) async {
    return await compute(
        process_after_class.operate_process_after, result_list);
  }

  process_frameIMG(CameraImage img) async {
    myparams params = myparams();
    params.img = img;
    params.is_testMode = is_test_mode;
    //  params.filePath = testStatics.current_capturedFileName; // no needed

    // await Isolate.spawn(isolate_test_img, params);
    return await compute(isolate_process_frameIMG, params);
  }

  static isolate_process_frameIMG(myparams params) async {
    print("start ===========================");
    print(params.img.height);
    print(params.img.width);
    print(params.img.format.raw.toString());

    List result = [];

    try {
      result = await StickSearching_operation(
          params.img, params.filePath, params.is_testMode);
    } catch (e) {
      result.add(false);
      result.add("fatal error");
    }

    // print(result);
    // Statics.jResult = result;
    return result;
  }
}
