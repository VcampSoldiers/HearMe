import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  String name;
  String email;
  Person(email, name) {
    this.email = email;
    this.name = name;
  }
}

class FirestoreManager {
  static Firestore firestore = Firestore.instance;

  static Future<void> addPerson(String email, String id, String name) async {
    List<String> friends_id = [];
    await firestore.collection('users').document(email).setData(
        {'name': name, 'id': id, 'friends': friends_id, 'enrolled': false});
  }

  static Future<void> addFriendsRelation(String p1, String p2) async {
    var p1_list = await getPersonFriendsEmailList(p1);
    p1_list.add(p2);
    var p2_list = await getPersonFriendsEmailList(p2);
    p2_list.add(p1);
    await firestore
        .collection('users')
        .document(p1)
        .updateData({"friends": p1_list});
    await firestore
        .collection('users')
        .document(p2)
        .updateData({"friends": p2_list});
  }

  static Future<String> getPersonName(String email) async {
    String name = "";
    try {
      await firestore
          .collection('users')
          .document(email)
          .get()
          .then((DocumentSnapshot ds) {
        print("this is getPersonName");
        print(ds.data);
        name = ds.data['name'].toString();
      });
    } catch (e) {
      name = null;
    }
    if (name == "") {
      name = null;
    }
    return name;
  }

  static Future<String> getPersonID(String email) async {
    String id = "";
    try {
      await firestore
          .collection('users')
          .document(email)
          .get()
          .then((DocumentSnapshot ds) {
        id = ds.data['id'];
      });
    } catch (e) {
      id = null;
    }
    if (id == "") {
      id = null;
    }
    return id;
  }

  static Future<List<Person>> getPersonFriendsList(String id) async {
    List<Person> friends_list = [];
    try {
      var ds = await firestore.collection('users').document(id).get();
      for (var email in ds.data['friends']) {
        var name = await getPersonName(email);
        friends_list.add(Person(email.toString(), name.toString()));
      }
    } catch (e) {
      friends_list = [];
    }
    return friends_list;
  }

  static Future<List<String>> getPersonFriendsEmailList(String id) async {
    List<String> friends_list = [];
    try {
      await firestore
          .collection('users')
          .document(id)
          .get()
          .then((DocumentSnapshot ds) {
        ds.data['friends'].forEach((email) async {
          friends_list.add(email);
        });
      });
    } catch (e) {
      friends_list = [];
    }
    return friends_list;
  }

  static Future<Map<String, String>> getPersonFriendsIDList(
      String email) async {
    Map<String, String> friends_map = {};
    try {
      var ds = await firestore.collection('users').document(email).get();
      for (var f_email in ds.data['friends']) {
        var id = await getPersonID(f_email);
        var name = await getPersonName(f_email);
        friends_map[id] = name;
      }
    } catch (e) {
      friends_map = {};
    }
    return friends_map;
  }

  static Future<bool> getPersonEnrolled(String email) async {
    bool enrolled = false;
    try {
      await firestore
          .collection('users')
          .document(email)
          .get()
          .then((DocumentSnapshot ds) {
        enrolled = ds.data['enrolled'];
      });
    } catch (e) {
      enrolled = false;
    }
    return enrolled;
  }

  static Future<void> setPersonAsEnrolled(String email) async {
    await firestore
        .collection("users")
        .document(email)
        .updateData({"enrolled": true});
  }

  static Future<List<String>> getIDList() async {
    List<String> id_lis = [];
    var a = await firestore.collection('users').getDocuments();

    a.documents.forEach((element) {
      id_lis.add(element.data['id'].toString());
    });
    return id_lis;
  }
}
