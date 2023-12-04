class User{
  int userID;
  String username;
  String barangay;
  String contactNum;
  String password;

  User(
    this.userID,
    this.username,
    this.barangay,
    this.contactNum,
    this.password,
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
    int.parse(json["userID"]),
    json["username"],
    json["barangay"],
    json["contactNum"],
    json["password"],
  );
  
  Map<String, dynamic> toJson() =>{
    'userID': userID.toString(),
    'username': username,
    'barangay': barangay,
    'contactNum': contactNum,
    'password': password,
  };
}