import 'package:confmate/controller/FirestoreController.dart';
import 'package:confmate/view/profilePage.dart';
import 'package:confmate/view/talksPage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';
import 'dart:async';

import '../model/Product.dart';
import '../model/Profile.dart';
import '../model/Talk.dart';
import '../view/productsPage.dart';

class HomePage extends StatefulWidget {
  final FirestoreController _firestore;
  final _firebaseUser;

  HomePage(this._firestore, this._firebaseUser);

  @override
  _HomePageState createState() =>
      _HomePageState(this._firestore, this._firebaseUser);
}

class _HomePageState extends State<HomePage> {
  List<Talk> _talks = new List();
  List<Product> _products = new List();
  bool showLoadingIndicator = true;
  ScrollController scrollController;
  final _firebaseUser;
  Profile _profile;
  final FirestoreController _firestore;
  final storage = FirebaseStorage.instance;

  _HomePageState(this._firestore, this._firebaseUser);

  File _image;
  String _uploadedFileURL;

  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
      });
    });
  }

  Future uploadFile(String path, File file) async {
    Future<String> uploadFile(String path, File file) async {
      TaskSnapshot task = await storage.ref().child(path).putFile(file);

      return task.ref.getDownloadURL();
    }
  }

  @override
  void initState() {
    super.initState();
    this.refreshModel(true);
  }

  Future<void> refreshModel(bool showIndicator) async {
    Stopwatch sw = Stopwatch()..start();
    setState(() {
      showLoadingIndicator = showIndicator;
    });
    _talks = await widget._firestore.getTalks();
    _products = await widget._firestore.getProducts();
    _profile = await widget._firestore.getUser(this._firebaseUser.email);
    _firestore.setCurrentUser(_profile);

    if (this.mounted)
      setState(() {
        showLoadingIndicator = false;
      });
    print("Talks fetch time: " + sw.elapsed.toString());
  }

  Widget build(BuildContext context) {
    return showLoadingIndicator
        ? SpinKitRing(
            color: Colors.blue,
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: ListView(padding: EdgeInsets.only(left: 15.0), children: <
                Widget>[
              SizedBox(height: 50.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Welcome, ' + _profile.firstname,
                      style: TextStyle(
                          fontFamily: 'varela',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF473D3A))),
                  Padding(
                      padding: EdgeInsets.only(right: 30, top: 20),
                      child: _profile.photo == "assets/defaultpic.jpg"
                          ? Container(
                              height: 75.0,
                              width: 75.0,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1.5, color: Colors.blue[700]),
                                  borderRadius: BorderRadius.circular(200.0),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image:
                                          AssetImage("assets/defaultpic.jpg"))),
                            )
                          : FutureBuilder(
                              future: this._firestore.getImgURL(_profile.photo),
                              builder: (context, url) {
                                if (url.hasData) {
                                  return Container(
                                      height: 75.0,
                                      width: 75.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(url.data))));
                                } else {
                                  return SizedBox(
                                      child: CircularProgressIndicator());
                                }
                              },
                            )),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 100.0),
                child: Container(
                  child: Text(
                    'Let\'s select the best talk for you!',
                    style: TextStyle(
                        fontFamily: 'nunito',
                        fontSize: 17.0,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFFB0AAA7)),
                  ),
                ),
              ),
              SizedBox(height: 25.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Featured Talks',
                    style: TextStyle(
                        fontFamily: 'varela',
                        fontSize: 17.0,
                        color: Color(0xFF473D3A)),
                  ),
                ],
              ),
              Container(
                  height: 350.0,
                  child: ListView(scrollDirection: Axis.horizontal, children: [
                    for (Talk x in _talks)
                      if (x.host.reference.id !=
                          this._firestore.getCurrentUser().reference.id)
                        _talkListCard(x),
                  ])),
              SizedBox(height: 25.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Featured Products',
                    style: TextStyle(
                        fontFamily: 'varela',
                        fontSize: 17.0,
                        color: Color(0xFF473D3A)),
                  ),
                ],
              ),
              SizedBox(height: 15.0),
              Container(
                  height: 350.0,
                  child: ListView(scrollDirection: Axis.horizontal, children: [
                    for (Product x in _products)
                      if (x.talk.host.reference.id !=
                          this._firestore.getCurrentUser().reference.id)
                        _productListCard(x)
                  ])),
              SizedBox(height: 30.0),
            ]));
  }

  Widget _talkListCard(Talk talk) {
    return Padding(
        padding: EdgeInsets.only(left: 15.0, right: 15.0),
        child: Container(
            height: 100.0,
            width: 225.0,
            child: Column(
              children: <Widget>[
                Stack(children: [
                  Container(height: 335.0),
                  Positioned(
                      top: 75.0,
                      child: Container(
                          padding: EdgeInsets.only(left: 10.0, right: 20.0),
                          height: 260.0,
                          width: 225.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Colors.blue[200]),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 50.0,
                                ),
                                Text(
                                  talk.host.firstname +
                                      ' ' +
                                      talk.host.lastname,
                                  style: TextStyle(
                                      fontFamily: 'nunito',
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  talk.name,
                                  style: TextStyle(
                                      fontFamily: 'varela',
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ]))),
                  Positioned(
                      right: 5.0,
                      bottom: 10.0,
                      child: FlatButton.icon(
                        textColor: Color(0xFF6200EE),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      talkDescription(talk, this._firestore)));
                        },
                        icon: Icon(Icons.arrow_forward_ios, size: 18),
                        label: Text("MORE DETAILS"),
                      )),
                  Positioned(
                      left: 55.0,
                      top: 25.0,
                      child: Container(
                          child: FlatButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            UserPage(talk.host)));
                              },
                              child: talk.host.photo == "assets/defaultpic.jpg"
                                  ? Container(
                                      height: 90.0,
                                      width: 90.0,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1.5,
                                              color: Colors.blue[700]),
                                          borderRadius:
                                              BorderRadius.circular(200.0),
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: AssetImage(
                                                  "assets/defaultpic.jpg"))),
                                    )
                                  : FutureBuilder(
                                      future: this
                                          ._firestore
                                          .getImgURL(talk.host.photo),
                                      builder: (context, url) {
                                        if (url.hasData) {
                                          return Container(
                                              height: 90.0,
                                              width: 90.0,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 1.5,
                                                      color: Colors.blue[700]),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          200.0),
                                                  image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: NetworkImage(
                                                          url.data))));
                                        } else {
                                          return SizedBox(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                      },
                                    ))))
                ]),
              ],
            )));
  }

  _productListCard(Product product) {
    return Padding(
        padding: EdgeInsets.only(left: 15.0, right: 15.0),
        child: Container(
            height: 300.0,
            width: 225.0,
            child: Column(
              children: <Widget>[
                Stack(children: [
                  Container(height: 335.0),
                  Positioned(
                      top: 75.0,
                      child: Container(
                          padding: EdgeInsets.only(left: 10.0, right: 20.0),
                          height: 260.0,
                          width: 225.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Colors.blue[200]),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 50.0,
                                ),
                                Text(
                                  product.audience,
                                  style: TextStyle(
                                      fontFamily: 'nunito',
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  product.name,
                                  style: TextStyle(
                                      fontFamily: 'varela',
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ]))),
                  Positioned(
                      right: 5.0,
                      bottom: 10.0,
                      child: FlatButton.icon(
                        textColor: Color(0xFF6200EE),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => productDescription(
                                      product,
                                      this._profile,
                                      this._firestore)));
                        },
                        icon: Icon(Icons.arrow_forward_ios, size: 18),
                        label: Text("MORE DETAILS"),
                      )),
                  Positioned(
                      left: 70.0,
                      top: 25.0,
                      child: product.image == "assets/bag.png"
                          ? Container(
                              height: 90.0,
                              width: 90.0,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      width: 1.5, color: Colors.blue[700]),
                                  borderRadius: BorderRadius.circular(200.0),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: AssetImage("assets/bag.png"))),
                            )
                          : FutureBuilder(
                              future: this._firestore.getImgURL(product.image),
                              builder: (context, url) {
                                if (url.hasData) {
                                  return Container(
                                      height: 90.0,
                                      width: 90.0,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1.5,
                                              color: Colors.blue[700]),
                                          borderRadius:
                                              BorderRadius.circular(200.0),
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(url.data))));
                                } else {
                                  return SizedBox(
                                      child: CircularProgressIndicator());
                                }
                              },
                            ))
                ]),
              ],
            )));
  }
}
