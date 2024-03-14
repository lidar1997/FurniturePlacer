import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as fire_storage;
import 'package:image_picker/image_picker.dart';

import 'ar_view.dart';


class ItemUploadPage extends StatefulWidget {
  const ItemUploadPage({super.key});

  @override
  State<StatefulWidget> createState() => _UploadPageState();
}

class _UploadPageState extends State<ItemUploadPage> {
  Uint8List? imageFileUint8List;
  bool isUploading = false;
  String downloadUrlOfUploadedImage = '';
  TextEditingController pictureNameEditingController = TextEditingController();

  // default screen
  Widget defaultScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Upload New Item",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate,
              color: Colors.white,
              size: 200,
            ),
            ElevatedButton(
              onPressed: () {
                showDialogBox();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black54,
              ),
              child: const Text(
                "Add New Item",
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  showDialogBox() {
    return showDialog(
        context: context,
        builder: (c) {
          return SimpleDialog(
            backgroundColor: Colors.black,
            title: const Text(
              "Item Image",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  captureImageWithCamera();
                },
                child: const Text(
                  "Capture Image",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  chooseImageFromGallery();
                },
                child: const Text(
                  "Choose Image from gallery",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          );
        });
  }

  captureImageWithCamera() async {
    Navigator.pop(context);

    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        imageFileUint8List = await pickedImage.readAsBytes();

        // make image transparent
        // final image = await decodeImageFromList(await pickedImage.readAsBytes());
        // final pngBytes = await cutImage(context: context, image: image);
        // imageFileUint8List = Uint8List.view(pngBytes!.buffer);

        setState(() {
          imageFileUint8List;
        });

        await uploadImage();
      }
    } catch (errorMsg) {
      if (kDebugMode) {
        print(errorMsg);
      }
      setState(() {
        imageFileUint8List = null;
      });
    }
  }

  chooseImageFromGallery() async {
    Navigator.pop(context);

    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        imageFileUint8List = await pickedImage.readAsBytes();

        // final image = await decodeImageFromList(await pickedImage.readAsBytes());
        // final pngBytes = await cutImage(context: context, image: image);
        // imageFileUint8List = Uint8List.view(pngBytes!.buffer);

        setState(() {
          imageFileUint8List;
        });
        await uploadImage();
      }
    } catch (errorMsg) {
      if (kDebugMode) {
        print(errorMsg);

      }
      setState(() {
        imageFileUint8List = null;
      });
    }
  }

  Future<void> uploadImage() async {
    if (imageFileUint8List != null) {
      // try {

        //upload image to cloud fireStorage
        String imageUniqueName =
            DateTime.now().millisecondsSinceEpoch.toString();
        fire_storage.Reference firebaseStorageRef = fire_storage.FirebaseStorage.instance.ref();
        fire_storage.Reference referenceImagesDir = firebaseStorageRef.child('Items Images');
        fire_storage.Reference referenceImageFile = referenceImagesDir.child(imageUniqueName);

        await referenceImageFile.putData(imageFileUint8List!);
        await referenceImageFile.getDownloadURL().then((imageDownloadUrl) {
          downloadUrlOfUploadedImage = imageDownloadUrl;
        });
        //save item info to fireStore
        Navigator.push(context, MaterialPageRoute(builder: (c) => ARPlacementPage(imageUniqueName)));
        await saveItemInfoToFireStore(imageUniqueName);


      // } catch (errMsg) {
      //   if (kDebugMode) {
      //     print(errMsg);
      //   }
      // }
    }
  }

  saveItemInfoToFireStore(String itemUniqueId) async {
    await FirebaseFirestore.instance.collection('items').doc(itemUniqueId).set({
      'itemID': itemUniqueId,
      'itemImage': downloadUrlOfUploadedImage
    });
  }

  @override
  Widget build(BuildContext context) {
    return defaultScreen();
  }
}
