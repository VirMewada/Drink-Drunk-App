import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drink_app/screens/create_account.dart';
import 'package:drink_app/screens/graph_page.dart';
import 'package:drink_app/screens/main_page.dart';
import 'package:drink_app/screens/profile_page.dart';
import 'package:drink_app/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:drink_app/database.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final Reference storageRef = FirebaseStorage.instance.ref();
final usersRef = Firestore.instance.collection('users');
final graphsRef = Firestore.instance.collection('graphs');

final DateTime timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;
  var globalSize;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      // 3) get username from create account, use it to make new user document in users collection
      usersRef.document(user.id).setData({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp
      });

      doc = await usersRef.document(user.id).get();
    }

    currentUser = User.fromDocument(doc);
    await Database().updateOfflineGraph();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: Container(
        child: PageView(
          children: <Widget>[
            MainPage(),
            GraphPage(),
            ProfilePage(),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: NeverScrollableScrollPhysics(),
        ),
      ),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: onTap,
          backgroundColor: Color(0xff231b10),
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  pageIndex == 0 ? Icons.home : Icons.home_outlined,
                  color: pageIndex == 0 ? Color(0xff975711) : Colors.white,
                ),
                title: Text(
                  "Home",
                  style: TextStyle(
                      color: pageIndex == 0 ? Color(0xff975711) : Colors.white),
                )),
            BottomNavigationBarItem(
                icon: Icon(
                  pageIndex == 1 ? Icons.trending_up : Icons.show_chart,
                  color: pageIndex == 1 ? Color(0xff975711) : Colors.white,
                ),
                title: Text(
                  "Graph",
                  style: TextStyle(
                      color: pageIndex == 1 ? Color(0xff975711) : Colors.white),
                )),
            BottomNavigationBarItem(
                icon: Icon(
                  pageIndex == 2 ? Icons.person : Icons.person_outlined,
                  color: pageIndex == 2 ? Color(0xff975711) : Colors.white,
                ),
                title: Text(
                  "Profile",
                  style: TextStyle(
                      color: pageIndex == 2 ? Color(0xff975711) : Colors.white),
                )),
          ]),
    );
  }

  Scaffold buildUnAuthScreen() {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xff231b10),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Top logo stack
            Stack(
              alignment: Alignment.center,
              children: [
                ClipPath(
                  clipper: DrawClip(),
                  child: Container(
                    //Gradient
                    height: size.height * 0.7,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xfff0c459),
                          Color(0xff975711),
                        ],
                      ),
                      image: DecorationImage(
                        image: AssetImage('assets/bubble1.png'),
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: size.height * 0.5,
                  width: size.width * 0.8,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/drink.png'),
                        alignment: Alignment.topCenter),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            _buildGoogleLogIn(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    globalSize = size;
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }

  Widget _buildGoogleLogIn() {
    return Container(
      height: 50,
      width: globalSize.width * 0.8,
      child: RaisedButton(
        onPressed: () {
          login();
        },
        child: Text(
          "Login with Google",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        color: Color(0xff975711),
        disabledColor: Colors.grey,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class DrawClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.85);
    path.quadraticBezierTo(
        size.width * 0.5, size.height * 1.05, size.width, size.height * 0.85);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
