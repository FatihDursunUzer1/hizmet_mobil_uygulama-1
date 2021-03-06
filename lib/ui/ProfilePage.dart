import 'dart:collection';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_star_rating/flutter_star_rating.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hizmet_mobil_uygulama/models/Comments.dart';
import 'package:hizmet_mobil_uygulama/ui/Settings.dart';
import 'package:hizmet_mobil_uygulama/utils/DialogMessage.dart';
import 'package:hizmet_mobil_uygulama/utils/ToastMessage.dart';
import 'package:hizmet_mobil_uygulama/viewmodel/comments_model.dart';
import 'package:hizmet_mobil_uygulama/viewmodel/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name, surname, email;
  int degree;
  DateTime datetime;
  PickedFile _profilePhoto;
  var _userModel;

  @override
  void initState() {
    super.initState();
    _userModel = Provider.of<UserModel>(context, listen: false);
    name = _userModel.user.name;
    surname = _userModel.user.surname;
    email = _userModel.user.email;
    degree = _userModel.user.degree;
    datetime = _userModel.user.dateOfBirth;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //UserModel _userModel = Provider.of<UserModel>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            actions: [
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Settings()));
                },
              )
            ],
            expandedHeight: MediaQuery.of(context).size.height / 4,
            floating: true,
            pinned: true,
            snap: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.height / 12,
                    top: MediaQuery.of(context).size.height / 25),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      child: InkWell(
                        onLongPress: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                  height: 160,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading:
                                            Icon(Icons.camera_alt_outlined),
                                        title: Text("Kameradan Çek"),
                                        onTap: () {
                                          _takeAPhotoFromCamera(context);
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.image_outlined),
                                        title: Text("Galeriden Seç"),
                                        onTap: () {
                                          _choosePhotoFromGallery(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              });
                        },
                        child: CircleAvatar(
                          radius: 75,
                          backgroundColor: Colors.white,
                          backgroundImage: _profilePhoto == null
                              ? NetworkImage(_userModel.user.profileURL)
                              : FileImage(File(_profilePhoto.path)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 25,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          name + " " + surname,
                          style: TextStyle(fontSize: 12),
                        ),
                        Center(
                          child: StarRating(
                            rating: degree.toDouble(),
                            spaceBetween: 5.0,
                            starConfig: StarConfig(
                              fillColor: Colors.deepOrange,
                              size: 10,
                              // other props
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [readComments()],
            ),
          ),
        ],
      ),
    );
  }

  readComments() {
    final commentsModel = Provider.of<CommentsModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);
    var future = commentsModel.readComments(userModel.user.userID);
    return FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return Container(
              height: 500,
              width: 150,
              child: ListView.builder(
                  itemBuilder: (context, index) {
                      double a=snapshot.data[index].degree/(index+1);
                      userModel.user.degree=a.round();
                    return FutureBuilder(
                      future:userModel.differentUser(snapshot.data[index].senderID),
                      builder: (context,snapshot1)
                      {
                        if(snapshot1.hasData)
                          return Card(
                            child: ListTile(
                              title:Text(snapshot1.data.name),
                              subtitle: Text(snapshot.data[index].content),
                              leading:Column(
                                children: [
                                  CircleAvatar(backgroundImage: NetworkImage(snapshot1.data.profileURL),),
                                  SizedBox(height:6),
                                  Container(width:70,child: StarRating(starConfig: StarConfig(size: 10.0,strokeWidth: 1),rating: double.parse(snapshot.data[index].degree.toString()),spaceBetween: 1,)),
                                ],
                              ),
                            ),
                          );
                        else
                          return Center(child: CircularProgressIndicator(backgroundColor: Colors.red,));
                      },
                    );
                  },
                  itemCount: snapshot.data.length),
            );
          else
            return Center(child: CircularProgressIndicator(backgroundColor: Colors.red));
        },
        future: future);
  }

  starColor(int rating) {
    if (rating <= 2)
      return Colors.deepOrange;
    else if (rating <= 4) return Colors.orangeAccent;
    return Colors.yellow;
  }

  void _takeAPhotoFromCamera(BuildContext context) async {
    PickedFile _newProfilePhoto =
        await ImagePicker.platform.pickImage(source: ImageSource.camera);

    setState(() {
      _profilePhoto = _newProfilePhoto;
      _updateProfilePhoto(context);
      Navigator.of(context).pop();
    });
  }

  void _choosePhotoFromGallery(BuildContext context) async {
    PickedFile _newProfilePhoto =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);

    setState(() {
      _profilePhoto = _newProfilePhoto;
      _updateProfilePhoto(context);
      Navigator.of(context).pop();
    });
  }

  void _updateProfilePhoto(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    if (_profilePhoto != null) {
      String url = await _userModel.uploadFile(
          _userModel.user.userID, "profilePhoto", File(_profilePhoto.path));

      if (url != null) {
        _userModel.user.profileURL = url;
        /*showToast(
            context, "Profil fotoğrafınız başarıyla güncellendi", Colors.green);*/
      }
    }
  }
}
