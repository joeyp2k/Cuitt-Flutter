import 'package:cuitt/features/dashboard/data/datasources/cloud.dart';
import 'package:cuitt/features/groups/data/datasources/group_data.dart';
/*
void initState() {
  super.initState();

  bloc.state.listen((state) {
    if (state is PageOneSelected) {
      _navigateToPage2();
    } else if (state is PageTwoSelected) {
      _navigateToPage2();
    }
  });
}
*/

class GetGroupData {
  //load user data
  void _getUser() async {}

  //load user list
  var userNameIndex;
  var value;

  void _getUsers() async {
    userNameIndex = 0;

    var value = await firestoreInstance
        .collection("groups")
        .doc(selection) //selection = group name and should be group ID
        .get()
        .then((value) => userIDList = value.get("members"));

    userNameIndex = userIDList.length;
  }

  void _loadUserData() async {
    userNameList.clear();

    for (int i = 0; i < userNameIndex; i++) {
      value = await firestoreInstance
          .collection("users")
          .doc(userIDList[i])
          .get()
          .then((value) {
        userNameList.insert(i, value.get("username"));
      });
    }
  }

  void groupSelection() async {
    await _getUsers();
    await _loadUserData();

    if (userNameList.isEmpty) {
      /*
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return UserListEmpty();
      }));
      */
    } else {
      /*
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return UserList();
      }));
       */
    }
  }

  //load group list
  void groups() async {
    int arrayindex = 0;
    var firebaseUser = await FirebaseAuth.instance.currentUser;
    var value = await firestoreInstance
        .collection("groups")
        .where("members", arrayContains: firebaseUser.uid)
        .get();

    groupNameList.clear();
    groupIDList.clear();
    value.docs.forEach((element) {
      groupNameList.insert(arrayindex, element.get("group name"));
      groupIDList.insert(arrayindex, element.id);
      arrayindex++;
    });
    if (groupNameList.isEmpty) {
      /*
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return GroupListEmpty();
      }));
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return GroupList();
      }));

       */
    }
  }
}
