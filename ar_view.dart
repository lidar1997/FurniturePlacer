import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart' as fire_storage;
import 'package:vector_math/vector_math_64.dart';

class ARPlacementPage extends StatefulWidget {
  final String imagePath;

  const ARPlacementPage(this.imagePath, {super.key});

  @override
  State<StatefulWidget> createState() => _ARPlacementPageState();
}

class _ARPlacementPageState extends State<ARPlacementPage> {
  ArCoreController? arCoreController;
  bool isImageInit = false;
  Uint8List? image;
  final nodes = <String, ArCoreNode>{};

  @override
  void initState() {
    super.initState();
    getImageFromUrl();
  }

  Future<void> getImageFromUrl() async {
    fire_storage.Reference firebaseStorageRef =
        fire_storage.FirebaseStorage.instance.ref();
    fire_storage.Reference referenceImagesDir =
        firebaseStorageRef.child('Items Images');
    fire_storage.Reference referenceImageFile =
        referenceImagesDir.child(widget.imagePath);

    final im = await referenceImageFile.getData();
    setState(() {
      image = im;
      isImageInit = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ArCoreView(
            enableTapRecognizer: true,
            onArCoreViewCreated: _onARCoreViewCreated,
          ),
        ],
      ),
    );
  }

  void _onARCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController?.onPlaneTap = _onPlaneTapped;
    arCoreController?.onNodeTap = onNodeTapHandler;
  }

  void onNodeTapHandler(String node) async {
    try {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("Change the furniture size"),
          actions: [
            IconButton(
                onPressed: () {
                  try{
                    final width = nodes[node]?.image!.width;
                    final height = nodes[node]?.image!.height;
                    final image = ArCoreImage(
                        bytes: nodes[node]?.image?.bytes,
                        width: width! + 50,
                        height: height! + 50);
                    final n = ArCoreNode(
                        image: image,
                        position: nodes[node]!.position?.value,
                        rotation: nodes[node]!.rotation?.value);
                    nodes.remove(node);
                    arCoreController?.removeNode(nodeName: node);
                    arCoreController?.addArCoreNodeWithAnchor(n);
                    final nodeName = n.name!;
                    nodes[nodeName] = n;
                    setState(() {});
                  }
                  finally{
                    Navigator.pop(context, false);
                  }
                },
                icon: const Icon(Icons.add)),
            IconButton(
                onPressed: () {
                  try{
                    final width = nodes[node]?.image!.width;
                    final height = nodes[node]?.image!.height;
                    final image = ArCoreImage(
                        bytes: nodes[node]?.image?.bytes,
                        width: width! - 50,
                        height: height! - 50);
                    final n = ArCoreNode(
                        image: image,
                        position: nodes[node]!.position?.value,
                        rotation: nodes[node]!.rotation?.value);
                    nodes.remove(node);
                    arCoreController?.removeNode(nodeName: node);
                    arCoreController?.addArCoreNodeWithAnchor(n);
                    final nodeName = n.name!;
                    nodes[nodeName] = n;
                    setState(() {});
                  }
                  finally{
                    Navigator.pop(context, false);
                  }
                },
                icon: const Icon(Icons.remove)),
            TextButton(
                onPressed: () {
                  arCoreController?.removeNode(nodeName: node);
                  Navigator.pop(context, false);
                },
                child: const Text("Remove item")),
            TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text("Cancel"))
          ],
        ),
      );
    } on Exception catch (e) {
      print(e);
    }
  }

  void _onPlaneTapped(List<ArCoreHitTestResult> planes) =>
      _onPlaneHit(planes.first);

  Future<void> _onPlaneHit(ArCoreHitTestResult plane) async {
    final imageForSize = await decodeImageFromList(image!);
    final width = imageForSize.width;
    final height = imageForSize.height;
    final imageNode = ArCoreImage(bytes: image, width: width, height: height);
    final node = ArCoreNode(
        image: imageNode,
        position: plane.pose.translation,
        rotation: plane.pose.rotation);
    final nodeName = node.name!;
    arCoreController?.addArCoreNodeWithAnchor(node);
    nodes[nodeName] = (node);
    showDialog<void>(
        context: context,
        builder: (BuildContext context) => const AlertDialog(
              content: Text("Selected furniture is on the screen!\n"
                  "Tap on the image to change its size or remove it"),
            ));
  }

  @override
  void dispose() {
    arCoreController?.dispose();
    super.dispose();
  }
}
