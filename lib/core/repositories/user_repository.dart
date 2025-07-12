import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:whatsapp_clone/model/users/user_model.dart';

class UserRepository {
  final GetStorage _storage = GetStorage();
  final String _userKey = 'user_data';
  final CollectionReference _userCollection = FirebaseFirestore.instance
      .collection('users');

  Future<void> createUser(UserModel user) async {
    try {
      await _userCollection.doc(user.uId).set(user.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getUserById(String uId) async {
    try {
      final doc = await _userCollection.doc(uId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isUserExists(String uId) async {
    try {
      final doc = await _userCollection.doc(uId).get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createUserIfNotExist(User firebaseUser) async {
    final exists = await isUserExists(firebaseUser.uid);
    if (!exists) {
      final newUser = UserModel(
        uId: firebaseUser.uid,
        phoneNumber: firebaseUser.phoneNumber ?? '',
        userName: firebaseUser.displayName ?? 'User ${firebaseUser.phoneNumber?.substring(firebaseUser.phoneNumber!.length - 4) ?? 'Unknown'}',
        profileImageUrl: '',
        isOnline: true,
        status: 'Hey there! I am using Hisham\'s WhatsApp.',
        lastSeen: DateTime.now(),
      );
      await createUser(newUser);
      // print('✅ Created new user: ${newUser.userName}');
    }
  }

  Future<void> updateUser(String uId, Map<String, dynamic> data) async {
    try {
      await _userCollection.doc(uId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _userCollection.doc(uid).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getAllUsersExceptMe(String myId) async {
    final querySnapshot =
        await _userCollection.where('uId', isNotEqualTo: myId).get();
    return querySnapshot.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  //Save user locally >>>>>>>>>>>
  Future<void> cachUser(UserModel user) async {
    await _storage.write(_userKey, user.toMap());
  }

  UserModel? getCachedUser() {
    final data = _storage.read(_userKey);
    if (data != null && data is Map<String, dynamic>) {
      return UserModel.fromMap(data);
    }
    return null;
  }

  Future<void> clearCachedUser() async {
    await _storage.remove(_userKey);
  }
}
