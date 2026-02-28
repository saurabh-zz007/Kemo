class Message {
  final String sender;
  final String text;

  Message({
    required this.sender,
    required this.text,
  });

  bool get isUser => sender == "user";
}
