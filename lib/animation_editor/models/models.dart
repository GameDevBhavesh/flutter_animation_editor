import 'package:flutter/widgets.dart';

class AnimationsCollection {
  final List<TrackedAnimation> animations;
  AnimationsCollection({
    required this.animations,
  });
  AnimationsCollection copyWith({
    List<TrackedAnimation>? animations,
  }) =>
      AnimationsCollection(
        animations: animations ?? this.animations,
      );

  factory AnimationsCollection.fromJson(Map<String, dynamic> json) =>
      AnimationsCollection(
        animations: List<TrackedAnimation>.from(
            json["animations"].map((x) => TrackedAnimation.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "animations": List<dynamic>.from(animations.map((x) => x.toJson())),
      };
}

class TrackedAnimation {
  final String name;
  Duration duration;
  final Map<String, ObjectTrack> objectTracks;

  TrackedAnimation({
    required this.duration,
    required this.name,
    required this.objectTracks,
  });

  TrackedAnimation copyWith({
    String? name,
    Duration? duration,
    Map<String, ObjectTrack>? objectTracks,
  }) =>
      TrackedAnimation(
          name: name ?? this.name,
          objectTracks: objectTracks ?? this.objectTracks,
          duration: duration ?? this.duration);

  factory TrackedAnimation.fromJson(Map<String, dynamic> json) =>
      TrackedAnimation(
          name: json["name"],
          duration: Duration(seconds: json["duration"]["seconds"].toDouble()),
          objectTracks: (json["objectTracks"] as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, ObjectTrack.fromJson(value))));

  Map<String, dynamic> toJson() => {
        "name": name,
        "duration": {"seconds": duration.inSeconds},
        "objectTracks":
            objectTracks.map((key, value) => MapEntry(key, value.toJson())),
      };
}

class ObjectTrack {
  final String name;
  final Map<String, PropertyTrack> tracks;
  bool isCollapsed;
  ObjectTrack({
    required this.name,
    required this.isCollapsed,
    required this.tracks,
  });

  ObjectTrack copyWith({
    String? name,
    bool? isCollapsed,
    Map<String, PropertyTrack>? tracks,
  }) =>
      ObjectTrack(
        name: name ?? this.name,
        isCollapsed: isCollapsed ?? this.isCollapsed,
        tracks: tracks ?? this.tracks,
      );

  factory ObjectTrack.fromJson(Map<String, dynamic> json) => ObjectTrack(
        name: json["name"],
        isCollapsed: json["isCollapsed"],
        tracks: (json["tracks"] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, PropertyTrack.fromJson(value))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "isCollapsed": isCollapsed,
        "tracks": tracks.map((key, value) => MapEntry(key, value.toJson())),
      };
}

class PropertyTrack {
  final String name;
  final String objectTrackKey;
  final String key;
  final String group;
  final String dataType;

  final List<Keyframe> keyframes;

  PropertyTrack({
    required this.name,
    required this.group,
    required this.key,
    required this.objectTrackKey,
    required this.dataType,
    required this.keyframes,
  });

  PropertyTrack copyWith({
    String? name,
    String? group,
    String? key,
    String? objectTrackKey,
    String? dataType,
    List<Keyframe>? keyframes,
  }) =>
      PropertyTrack(
        name: name ?? this.name,
        group: group ?? this.group,
        key: key ?? this.key,
        objectTrackKey: objectTrackKey ?? this.objectTrackKey,
        dataType: dataType ?? this.dataType,
        keyframes: keyframes ?? this.keyframes,
      );

  factory PropertyTrack.fromJson(Map<String, dynamic> json) => PropertyTrack(
        name: json["name"],
        group: json["group"],
        objectTrackKey: json["objectTrackKey"],
        key: json["key"],
        dataType: json["dataType"],
        keyframes: List<Keyframe>.from(
            json["keyframes"].map((x) => Keyframe.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "group": group,
        "objectTrackKey": objectTrackKey,
        "key": key,
        "dataType": dataType,
        "keyframes": List<dynamic>.from(keyframes.map((x) => x.toJson())),
      };
}

class KeyframeCurve {
  const KeyframeCurve(
      {required this.curveType,
      required this.custom,
      required this.enableCustom});
  final bool enableCustom;
  final Cubic custom;
  final String curveType;

  factory KeyframeCurve.fromJson(dynamic json) {
    return KeyframeCurve(
        curveType: json["curveType"],
        custom: Cubic(json["custom"]["a"], json["custom"]["b"],
            json["custom"]["c"], json["custom"]["d"]),
        enableCustom: json["enableCustom"]);
  }
  toJson() {
    return {
      "curveType": curveType,
      "custom": {"a": custom.a, "b": custom.b, "c": custom.c, "d": custom.d},
      "enableCustom": enableCustom
    };
  }
}

class Keyframe<T> {
  double time;
  T value;
  Cubic? curve;
  final String trackKey;
  final String objectKey;

  Keyframe(
      {required this.curve,
      required this.time,
      required this.value,
      required this.objectKey,
      required this.trackKey});

  @override
  bool operator ==(other) {
    return time == (other as dynamic).time;
  }

  Keyframe copyWith({
    double? time,
    Map<String, dynamic>? value,
    String? trackKey,
    Cubic? curve,
    String? objectKey,
  }) =>
      Keyframe(
          curve: curve ?? this.curve,
          time: time ?? this.time,
          value: value ?? this.value,
          objectKey: objectKey ?? this.objectKey,
          trackKey: trackKey ?? this.trackKey);

  factory Keyframe.fromJson(
    Map<String, dynamic> json,
  ) =>
      Keyframe(
        curve: Cubic(
            json["curve"]["a"].toDouble(),
            json["curve"]["b"].toDouble(),
            json["curve"]["c"].toDouble(),
            json["curve"]["d"].toDouble()),
        time: json["time"]?.toDouble(),
        value: json["value"],
        objectKey: json["objectKey"],
        trackKey: json["trackKey"],
      );

  Map<String, dynamic> toJson() => {
        "time": time,
        "value": value,
        "curve": {"a": curve!.a, "b": curve!.b, "c": curve!.c, "d": curve!.d},
        "objectKey": objectKey,
        "trackKey": trackKey,
      };
  @override
  int get hashCode => super.hashCode;
}

class Vector2 {
  const Vector2(this.x, this.y);
  final double x;
  final double y;

  operator -(Vector2 other) => Vector2(x - other.x, y - other.y);
  operator +(Vector2 other) => Vector2(x + other.x, y + other.y);
  operator -() => Vector2(-x, -y);
  Vector2 operator *(double operand) => Vector2(x * operand, y * operand);
  Vector2 operator /(double operand) => Vector2(x / operand, y / operand);

  toJson() => {"x": x, "y": y};
  factory Vector2.fromJson(Map<String, dynamic> json) =>
      Vector2(json["x"].toDouble(), json["y"].toDouble());
}
