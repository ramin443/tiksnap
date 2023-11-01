class SavedAudios {
  int? id;
  String? title;
  String? play;
  String? cover;
  String? author;
  int? duration;
  String? album;


  SavedAudios({
    required this.title,
    required this.play,
    required this.cover,
    required this.author,
    required this.duration,
    required this.album,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'play': play,
      'cover': cover,
      'author': author,
      'duration': duration,
      'album': album,
    };
  }
  SavedAudios.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    play = map['play'];
    cover = map['cover'];
    author = map['author'];
    duration = map['duration'];
    album = map['album'];
  }

}