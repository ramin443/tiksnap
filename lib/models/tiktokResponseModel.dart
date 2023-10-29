class TikTokResponse {
  final int code;
  final String msg;
  final double processedTime;
  final TikTokData data;

  TikTokResponse({
    required this.code,
    required this.msg,
    required this.processedTime,
    required this.data,
  });
  factory TikTokResponse.fromJson(Map<String, dynamic> json) {
    return TikTokResponse(
      code: json['code'],
      msg: json['msg'],
      processedTime: json['processed_time'],
      data: TikTokData.fromJson(json['data']),
    );
  }
}

class TikTokData {
  final String awemeId;
  final String id;
  final String region;
  final String title;
  final String cover;
  final String originCover;
  final int duration;
  final String play;
  final String wmplay;
  final int size;
  final int wmSize;
  final String music;
  final MusicInfo musicInfo;
  final int playCount;
  final int diggCount;
  final int commentCount;
  final int shareCount;
  final int downloadCount;
  final int collectCount;
  final int createTime;
  final Author author;

  TikTokData({
    required this.awemeId,
    required this.id,
    required this.region,
    required this.title,
    required this.cover,
    required this.originCover,
    required this.duration,
    required this.play,
    required this.wmplay,
    required this.size,
    required this.wmSize,
    required this.music,
    required this.musicInfo,
    required this.playCount,
    required this.diggCount,
    required this.commentCount,
    required this.shareCount,
    required this.downloadCount,
    required this.collectCount,
    required this.createTime,
    required this.author,
  });

  factory TikTokData.fromJson(Map<String, dynamic> json) {
    return TikTokData(
      awemeId: json['aweme_id'],
      id: json['id'],
      region: json['region'],
      title: json['title'],
      cover: json['cover'],
      originCover: json['origin_cover'],
      duration: json['duration'],
      play: json['play'],
      wmplay: json['wmplay'],
      size: json['size'],
      wmSize: json['wm_size'],
      music: json['music'],
      musicInfo: MusicInfo.fromJson(json['music_info']),
      playCount: json['play_count'],
      diggCount: json['digg_count'],
      commentCount: json['comment_count'],
      shareCount: json['share_count'],
      downloadCount: json['download_count'],
      collectCount: json['collect_count'],
      createTime: json['create_time'],
      author: Author.fromJson(json['author']),
    );
  }
}

class MusicInfo {
  final String id;
  final String title;
  final String play;
  final String cover;
  final String author;
  final bool original;
  final int duration;
  final String album;

  MusicInfo({
    required this.id,
    required this.title,
    required this.play,
    required this.cover,
    required this.author,
    required this.original,
    required this.duration,
    required this.album,
  });
  factory MusicInfo.fromJson(Map<String, dynamic> json) {
    return MusicInfo(
      id: json['id'],
      title: json['title'],
      play: json['play'],
      cover: json['cover'],
      author: json['author'],
      original: json['original'],
      duration: json['duration'],
      album: json['album'],
    );
  }
}

class Author {
  final String id;
  final String uniqueId;
  final String nickname;
  final String avatar;

  Author({
    required this.id,
    required this.uniqueId,
    required this.nickname,
    required this.avatar,
  });
  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      uniqueId: json['unique_id'],
      nickname: json['nickname'],
      avatar: json['avatar'],
    );
  }
}
