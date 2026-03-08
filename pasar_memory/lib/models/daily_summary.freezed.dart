// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DailySummary {

 String get id; DateTime get date; double get totalSales; double get digitalTotal; double get cashEstimate; int get unresolvedCount; bool get isConfirmed;
/// Create a copy of DailySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailySummaryCopyWith<DailySummary> get copyWith => _$DailySummaryCopyWithImpl<DailySummary>(this as DailySummary, _$identity);

  /// Serializes this DailySummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailySummary&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.totalSales, totalSales) || other.totalSales == totalSales)&&(identical(other.digitalTotal, digitalTotal) || other.digitalTotal == digitalTotal)&&(identical(other.cashEstimate, cashEstimate) || other.cashEstimate == cashEstimate)&&(identical(other.unresolvedCount, unresolvedCount) || other.unresolvedCount == unresolvedCount)&&(identical(other.isConfirmed, isConfirmed) || other.isConfirmed == isConfirmed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,totalSales,digitalTotal,cashEstimate,unresolvedCount,isConfirmed);

@override
String toString() {
  return 'DailySummary(id: $id, date: $date, totalSales: $totalSales, digitalTotal: $digitalTotal, cashEstimate: $cashEstimate, unresolvedCount: $unresolvedCount, isConfirmed: $isConfirmed)';
}


}

/// @nodoc
abstract mixin class $DailySummaryCopyWith<$Res>  {
  factory $DailySummaryCopyWith(DailySummary value, $Res Function(DailySummary) _then) = _$DailySummaryCopyWithImpl;
@useResult
$Res call({
 String id, DateTime date, double totalSales, double digitalTotal, double cashEstimate, int unresolvedCount, bool isConfirmed
});




}
/// @nodoc
class _$DailySummaryCopyWithImpl<$Res>
    implements $DailySummaryCopyWith<$Res> {
  _$DailySummaryCopyWithImpl(this._self, this._then);

  final DailySummary _self;
  final $Res Function(DailySummary) _then;

/// Create a copy of DailySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? totalSales = null,Object? digitalTotal = null,Object? cashEstimate = null,Object? unresolvedCount = null,Object? isConfirmed = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,totalSales: null == totalSales ? _self.totalSales : totalSales // ignore: cast_nullable_to_non_nullable
as double,digitalTotal: null == digitalTotal ? _self.digitalTotal : digitalTotal // ignore: cast_nullable_to_non_nullable
as double,cashEstimate: null == cashEstimate ? _self.cashEstimate : cashEstimate // ignore: cast_nullable_to_non_nullable
as double,unresolvedCount: null == unresolvedCount ? _self.unresolvedCount : unresolvedCount // ignore: cast_nullable_to_non_nullable
as int,isConfirmed: null == isConfirmed ? _self.isConfirmed : isConfirmed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DailySummary].
extension DailySummaryPatterns on DailySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailySummary value)  $default,){
final _that = this;
switch (_that) {
case _DailySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailySummary value)?  $default,){
final _that = this;
switch (_that) {
case _DailySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime date,  double totalSales,  double digitalTotal,  double cashEstimate,  int unresolvedCount,  bool isConfirmed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailySummary() when $default != null:
return $default(_that.id,_that.date,_that.totalSales,_that.digitalTotal,_that.cashEstimate,_that.unresolvedCount,_that.isConfirmed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime date,  double totalSales,  double digitalTotal,  double cashEstimate,  int unresolvedCount,  bool isConfirmed)  $default,) {final _that = this;
switch (_that) {
case _DailySummary():
return $default(_that.id,_that.date,_that.totalSales,_that.digitalTotal,_that.cashEstimate,_that.unresolvedCount,_that.isConfirmed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime date,  double totalSales,  double digitalTotal,  double cashEstimate,  int unresolvedCount,  bool isConfirmed)?  $default,) {final _that = this;
switch (_that) {
case _DailySummary() when $default != null:
return $default(_that.id,_that.date,_that.totalSales,_that.digitalTotal,_that.cashEstimate,_that.unresolvedCount,_that.isConfirmed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailySummary implements DailySummary {
  const _DailySummary({required this.id, required this.date, required this.totalSales, required this.digitalTotal, required this.cashEstimate, required this.unresolvedCount, required this.isConfirmed});
  factory _DailySummary.fromJson(Map<String, dynamic> json) => _$DailySummaryFromJson(json);

@override final  String id;
@override final  DateTime date;
@override final  double totalSales;
@override final  double digitalTotal;
@override final  double cashEstimate;
@override final  int unresolvedCount;
@override final  bool isConfirmed;

/// Create a copy of DailySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailySummaryCopyWith<_DailySummary> get copyWith => __$DailySummaryCopyWithImpl<_DailySummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailySummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailySummary&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.totalSales, totalSales) || other.totalSales == totalSales)&&(identical(other.digitalTotal, digitalTotal) || other.digitalTotal == digitalTotal)&&(identical(other.cashEstimate, cashEstimate) || other.cashEstimate == cashEstimate)&&(identical(other.unresolvedCount, unresolvedCount) || other.unresolvedCount == unresolvedCount)&&(identical(other.isConfirmed, isConfirmed) || other.isConfirmed == isConfirmed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,totalSales,digitalTotal,cashEstimate,unresolvedCount,isConfirmed);

@override
String toString() {
  return 'DailySummary(id: $id, date: $date, totalSales: $totalSales, digitalTotal: $digitalTotal, cashEstimate: $cashEstimate, unresolvedCount: $unresolvedCount, isConfirmed: $isConfirmed)';
}


}

/// @nodoc
abstract mixin class _$DailySummaryCopyWith<$Res> implements $DailySummaryCopyWith<$Res> {
  factory _$DailySummaryCopyWith(_DailySummary value, $Res Function(_DailySummary) _then) = __$DailySummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime date, double totalSales, double digitalTotal, double cashEstimate, int unresolvedCount, bool isConfirmed
});




}
/// @nodoc
class __$DailySummaryCopyWithImpl<$Res>
    implements _$DailySummaryCopyWith<$Res> {
  __$DailySummaryCopyWithImpl(this._self, this._then);

  final _DailySummary _self;
  final $Res Function(_DailySummary) _then;

/// Create a copy of DailySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? totalSales = null,Object? digitalTotal = null,Object? cashEstimate = null,Object? unresolvedCount = null,Object? isConfirmed = null,}) {
  return _then(_DailySummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,totalSales: null == totalSales ? _self.totalSales : totalSales // ignore: cast_nullable_to_non_nullable
as double,digitalTotal: null == digitalTotal ? _self.digitalTotal : digitalTotal // ignore: cast_nullable_to_non_nullable
as double,cashEstimate: null == cashEstimate ? _self.cashEstimate : cashEstimate // ignore: cast_nullable_to_non_nullable
as double,unresolvedCount: null == unresolvedCount ? _self.unresolvedCount : unresolvedCount // ignore: cast_nullable_to_non_nullable
as int,isConfirmed: null == isConfirmed ? _self.isConfirmed : isConfirmed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
