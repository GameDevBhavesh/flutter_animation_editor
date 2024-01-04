import 'dart:math';

import 'package:animation_editor/animation_editor/property_animators/animator.dart';
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
          duration:
              Duration(seconds: (json["duration"]["seconds"] as num).toInt()),
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
  final String id;
  final String name;
  final Map<String, PropertyTrack> tracks;
  bool isCollapsed;
  ObjectTrack({
    required this.id,
    required this.name,
    required this.isCollapsed,
    required this.tracks,
  });

  ObjectTrack copyWith({
    String? name,
    String? id,
    bool? isCollapsed,
    Map<String, PropertyTrack>? tracks,
  }) =>
      ObjectTrack(
        id: id ?? this.id,
        name: name ?? this.name,
        isCollapsed: isCollapsed ?? this.isCollapsed,
        tracks: tracks ?? this.tracks,
      );

  factory ObjectTrack.fromJson(Map<String, dynamic> json) => ObjectTrack(
        id: json["id"],
        name: json["name"],
        isCollapsed: json["isCollapsed"],
        tracks: (json["tracks"] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, PropertyTrack.fromJson(value))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "isCollapsed": isCollapsed,
        "tracks": tracks.map((key, value) => MapEntry(key, value.toJson())),
      };
}

class PropertyTrack<T> {
  final String name;
  final String objectTrackId;
  final String id;
  final String group;
  Type dataType;

  final List<Keyframe<T>> keyframes;

  PropertyTrack(
      {required this.name,
      required this.group,
      required this.id,
      required this.objectTrackId,
      required this.keyframes,
      required this.dataType}) {
    keyframes.forEach((element) {
      element.dataType = dataType;
    });
  }

  PropertyTrack copyWith({
    String? name,
    String? group,
    String? key,
    String? objectTrackKey,
    Type? dataType,
    List<Keyframe>? keyframes,
  }) =>
      PropertyTrack(
        dataType: dataType ?? this.dataType,
        name: name ?? this.name,
        group: group ?? this.group,
        id: key ?? this.id,
        objectTrackId: objectTrackKey ?? this.objectTrackId,
        keyframes: keyframes ?? this.keyframes,
      );

  factory PropertyTrack.fromJson(Map<String, dynamic> json) {
    Type? type;

    for (var element in Animator.interpolators.entries) {
      if (element.key.toString() == json["dataType"] as String) {
        type = element.key;
        break;
      }
    }
    if (type == null) {
      throw FlutterError(
          "Incoming dataType for PopertyTrack isn't defined in animators parameters");
    }

    return PropertyTrack(
      name: json["name"],
      group: json["group"],
      objectTrackId: json["objectTrackKey"],
      id: json["key"],
      dataType: type,
      keyframes: List<Keyframe<T>>.from(json["keyframes"]
          .map((x) => Keyframe<T>.fromJson(x)..dataType = type)),
    );
  }
  Map<String, dynamic> toJson() {
    print(dataType.toString());
    return {
      "name": name,
      "group": group,
      "objectTrackKey": objectTrackId,
      "key": id,
      "dataType": dataType.toString(),
      "keyframes": List<dynamic>.from(keyframes.map((x) => x.toJson())),
    };
  }
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
  final String trackId;
  final String objectId;
  Type? dataType;

  Keyframe(
      {this.dataType,
      required this.curve,
      required this.time,
      required this.value,
      required this.objectId,
      required this.trackId});

  @override
  bool operator ==(other) {
    return time == (other as dynamic).time;
  }

  Keyframe copyWith({
    double? time,
    dynamic value,
    String? trackKey,
    Cubic? curve,
    String? objectKey,
  }) =>
      Keyframe(
          curve: curve ?? this.curve,
          time: time ?? this.time,
          value: value ?? this.value,
          objectId: objectKey ?? this.objectId,
          trackId: trackKey ?? this.trackId);

  factory Keyframe.fromJson(
    Map<String, dynamic> json,
  ) {
    return Keyframe(
      curve: Cubic(json["curve"]["a"].toDouble(), json["curve"]["b"].toDouble(),
          json["curve"]["c"].toDouble(), json["curve"]["d"].toDouble()),
      time: json["time"]?.toDouble(),
      value: json["value"],
      objectId: json["objectKey"],
      trackId: json["trackKey"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "time": time,
      "value": Animator.interpolators[dataType]!.toJson(value),
      "curve": {"a": curve!.a, "b": curve!.b, "c": curve!.c, "d": curve!.d},
      "dataType": dataType.toString(),
      "objectKey": objectId,
      "trackKey": trackId,
    };
  }

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
