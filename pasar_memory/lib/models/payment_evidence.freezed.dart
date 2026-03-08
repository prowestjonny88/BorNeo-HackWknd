// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_evidence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentEvidence {

 String get id; String get imagePath; DateTime get importedAt;
/// Create a copy of PaymentEvidence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentEvidenceCopyWith<PaymentEvidence> get copyWith => _$PaymentEvidenceCopyWithImpl<PaymentEvidence>(this as PaymentEvidence, _$identity);

  /// Serializes this PaymentEvidence to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentEvidence&&(identical(other.id, id) || other.id == id)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.importedAt, importedAt) || other.importedAt == importedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,imagePath,importedAt);

@override
String toString() {
  return 'PaymentEvidence(id: $id, imagePath: $imagePath, importedAt: $importedAt)';
}


}

/// @nodoc
abstract mixin class $PaymentEvidenceCopyWith<$Res>  {
  factory $PaymentEvidenceCopyWith(PaymentEvidence value, $Res Function(PaymentEvidence) _then) = _$PaymentEvidenceCopyWithImpl;
@useResult
$Res call({
 String id, String imagePath, DateTime importedAt
});




}
/// @nodoc
class _$PaymentEvidenceCopyWithImpl<$Res>
    implements $PaymentEvidenceCopyWith<$Res> {
  _$PaymentEvidenceCopyWithImpl(this._self, this._then);

  final PaymentEvidence _self;
  final $Res Function(PaymentEvidence) _then;

/// Create a copy of PaymentEvidence
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? imagePath = null,Object? importedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String,importedAt: null == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentEvidence].
extension PaymentEvidencePatterns on PaymentEvidence {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentEvidence value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentEvidence() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentEvidence value)  $default,){
final _that = this;
switch (_that) {
case _PaymentEvidence():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentEvidence value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentEvidence() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String imagePath,  DateTime importedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentEvidence() when $default != null:
return $default(_that.id,_that.imagePath,_that.importedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String imagePath,  DateTime importedAt)  $default,) {final _that = this;
switch (_that) {
case _PaymentEvidence():
return $default(_that.id,_that.imagePath,_that.importedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String imagePath,  DateTime importedAt)?  $default,) {final _that = this;
switch (_that) {
case _PaymentEvidence() when $default != null:
return $default(_that.id,_that.imagePath,_that.importedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentEvidence implements PaymentEvidence {
  const _PaymentEvidence({required this.id, required this.imagePath, required this.importedAt});
  factory _PaymentEvidence.fromJson(Map<String, dynamic> json) => _$PaymentEvidenceFromJson(json);

@override final  String id;
@override final  String imagePath;
@override final  DateTime importedAt;

/// Create a copy of PaymentEvidence
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentEvidenceCopyWith<_PaymentEvidence> get copyWith => __$PaymentEvidenceCopyWithImpl<_PaymentEvidence>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentEvidenceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentEvidence&&(identical(other.id, id) || other.id == id)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.importedAt, importedAt) || other.importedAt == importedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,imagePath,importedAt);

@override
String toString() {
  return 'PaymentEvidence(id: $id, imagePath: $imagePath, importedAt: $importedAt)';
}


}

/// @nodoc
abstract mixin class _$PaymentEvidenceCopyWith<$Res> implements $PaymentEvidenceCopyWith<$Res> {
  factory _$PaymentEvidenceCopyWith(_PaymentEvidence value, $Res Function(_PaymentEvidence) _then) = __$PaymentEvidenceCopyWithImpl;
@override @useResult
$Res call({
 String id, String imagePath, DateTime importedAt
});




}
/// @nodoc
class __$PaymentEvidenceCopyWithImpl<$Res>
    implements _$PaymentEvidenceCopyWith<$Res> {
  __$PaymentEvidenceCopyWithImpl(this._self, this._then);

  final _PaymentEvidence _self;
  final $Res Function(_PaymentEvidence) _then;

/// Create a copy of PaymentEvidence
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? imagePath = null,Object? importedAt = null,}) {
  return _then(_PaymentEvidence(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String,importedAt: null == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
