class ChatUser {
  String id = '';
  String name = '';
  String imageUrl = '';
  int unreadMessages = 0;

  ChatUser();

  ChatUser.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    imageUrl = map['imageUrl'];
    unreadMessages = map['unreadMessages'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'unreadMessages': unreadMessages,
    };
  }
}

class ChatRoom {
  String id = '';
  List<String> users = []; // List of user ids for quick access in queries
  ChatUser? user1;
  ChatUser? user2;

  ChatRoom(ChatUser firstUser, ChatUser secondUser) {
    user1 = firstUser;
    user2 = secondUser;
    users.add(user1!.id);
    users.add(user2!.id);
  }

  ChatRoom.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    users = List<String>.from(map['users']);
    user1 = ChatUser.fromMap(map['user1']);
    user2 = ChatUser.fromMap(map['user2']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'users': users,
      'user1': user1!.toMap(),
      'user2': user2!.toMap(),
    };
  }
}
