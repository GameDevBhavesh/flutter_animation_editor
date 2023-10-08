import 'package:shortid/shortid.dart';

enum PropertyKeyType {
  positionRelative,
  scaleRelative,
  rotationRelative,
  position,
  scale,
  rotation,
}

class AnimationTimelineEntity {
  final String name;
  AnimDuration duration;
  String playType;
  final Map<String, Track> tracks;

  AnimationTimelineEntity(
      {required this.name,
      required this.duration,
      required this.tracks,
      required this.playType});

  factory AnimationTimelineEntity.fromJson(Map<String, dynamic> json) =>
      AnimationTimelineEntity(
        name: json["name"],
        playType: json["playType"],
        duration: AnimDuration.fromJson(json["duration"]),
        tracks: (json["tracks"] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, Track.fromJson(value))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "duration": duration.toJson(),
        "playType": playType,
        "tracks": tracks.map((key, value) => MapEntry(key, value.toJson())),
      };
}

class AnimDuration {
  final int seconds;

  AnimDuration({
    required this.seconds,
  });

  factory AnimDuration.fromJson(Map<String, dynamic> json) => AnimDuration(
        seconds: json["seconds"],
      );

  Map<String, dynamic> toJson() => {
        "seconds": seconds,
      };
}

class Track {
  final String name;
  bool isCollapsed;
  final Map<String, List<Keyframe>> keyframes;

  Track({required this.name, required this.keyframes, this.isCollapsed = true});

  factory Track.fromJson(Map<String, dynamic> json) => Track(
        name: json["name"],
        isCollapsed: json["isCollapsed"],
        keyframes: (json["keyframes"] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key,
                (value as List).map((e) => Keyframe.fromJson(e)).toList())),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "isCollapsed": isCollapsed,
        "keyframes": keyframes.map((key, value) =>
            MapEntry(key, value.map((e) => e.toJson()).toList())),
      };
}

class Keyframe {
  String? id;
  double time;
  final String itemId;
  final String propertyKey;
  final Map<String, dynamic> propertyValue;
  final String curve;

  Keyframe(
      {required this.time,
      required this.itemId,
      required this.propertyKey,
      required this.propertyValue,
      required this.curve,
      this.id}) {
    id = shortid.generate();
  }

  Keyframe copyWith({
    double? time,
    String? itemId,
    String? propertyKey,
    dynamic? propertyValue,
    String? curve,
  }) =>
      Keyframe(
        time: time ?? this.time,
        itemId: itemId ?? this.itemId,
        propertyKey: propertyKey ?? this.propertyKey,
        propertyValue: propertyValue ?? this.propertyValue,
        curve: curve ?? this.curve,
      );

  factory Keyframe.fromJson(Map<String, dynamic> json) => Keyframe(
        time: json["time"]?.toDouble(),
        itemId: json["itemId"],
        propertyKey: json["propertyKey"],
        propertyValue: json["propertyValue"],
        curve: json["curve"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "time": time,
        "itemId": itemId,
        "propertyKey": propertyKey,
        "propertyValue": propertyValue,
        "curve": curve,
        "id": id,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Keyframe && other.time == time;
  }

  @override
  int get hashCode => time.hashCode;
}

class PropertyValue {
  final int x;
  final int y;

  PropertyValue({
    required this.x,
    required this.y,
  });

  factory PropertyValue.fromJson(Map<String, dynamic> json) => PropertyValue(
        x: json["x"],
        y: json["y"],
      );

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
      };
}
