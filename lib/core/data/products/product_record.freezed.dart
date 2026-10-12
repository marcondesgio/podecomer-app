// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductRecord {

 String get barcode; ProductOrigin get origin; Product get product; String? get name; String? get brand;/// Categoria mais específica (usada para alternativas seguras).
 String? get category; String? get imageUrl;/// Última atualização dos dados na fonte.
 DateTime? get updatedAt;/// Veio do cache local do Open Food Facts.
 bool get fromCache;
/// Create a copy of ProductRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductRecordCopyWith<ProductRecord> get copyWith => _$ProductRecordCopyWithImpl<ProductRecord>(this as ProductRecord, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductRecord&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.product, product) || other.product == product)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.category, category) || other.category == category)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.fromCache, fromCache) || other.fromCache == fromCache));
}


@override
int get hashCode => Object.hash(runtimeType,barcode,origin,product,name,brand,category,imageUrl,updatedAt,fromCache);

@override
String toString() {
  return 'ProductRecord(barcode: $barcode, origin: $origin, product: $product, name: $name, brand: $brand, category: $category, imageUrl: $imageUrl, updatedAt: $updatedAt, fromCache: $fromCache)';
}


}

/// @nodoc
abstract mixin class $ProductRecordCopyWith<$Res>  {
  factory $ProductRecordCopyWith(ProductRecord value, $Res Function(ProductRecord) _then) = _$ProductRecordCopyWithImpl;
@useResult
$Res call({
 String barcode, ProductOrigin origin, Product product, String? name, String? brand, String? category, String? imageUrl, DateTime? updatedAt, bool fromCache
});


$ProductCopyWith<$Res> get product;

}
/// @nodoc
class _$ProductRecordCopyWithImpl<$Res>
    implements $ProductRecordCopyWith<$Res> {
  _$ProductRecordCopyWithImpl(this._self, this._then);

  final ProductRecord _self;
  final $Res Function(ProductRecord) _then;

/// Create a copy of ProductRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? barcode = null,Object? origin = null,Object? product = null,Object? name = freezed,Object? brand = freezed,Object? category = freezed,Object? imageUrl = freezed,Object? updatedAt = freezed,Object? fromCache = null,}) {
  return _then(_self.copyWith(
barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as ProductOrigin,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,fromCache: null == fromCache ? _self.fromCache : fromCache // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ProductRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductCopyWith<$Res> get product {
  
  return $ProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProductRecord].
extension ProductRecordPatterns on ProductRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductRecord value)  $default,){
final _that = this;
switch (_that) {
case _ProductRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductRecord value)?  $default,){
final _that = this;
switch (_that) {
case _ProductRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String barcode,  ProductOrigin origin,  Product product,  String? name,  String? brand,  String? category,  String? imageUrl,  DateTime? updatedAt,  bool fromCache)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductRecord() when $default != null:
return $default(_that.barcode,_that.origin,_that.product,_that.name,_that.brand,_that.category,_that.imageUrl,_that.updatedAt,_that.fromCache);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String barcode,  ProductOrigin origin,  Product product,  String? name,  String? brand,  String? category,  String? imageUrl,  DateTime? updatedAt,  bool fromCache)  $default,) {final _that = this;
switch (_that) {
case _ProductRecord():
return $default(_that.barcode,_that.origin,_that.product,_that.name,_that.brand,_that.category,_that.imageUrl,_that.updatedAt,_that.fromCache);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String barcode,  ProductOrigin origin,  Product product,  String? name,  String? brand,  String? category,  String? imageUrl,  DateTime? updatedAt,  bool fromCache)?  $default,) {final _that = this;
switch (_that) {
case _ProductRecord() when $default != null:
return $default(_that.barcode,_that.origin,_that.product,_that.name,_that.brand,_that.category,_that.imageUrl,_that.updatedAt,_that.fromCache);case _:
  return null;

}
}

}

/// @nodoc


class _ProductRecord implements ProductRecord {
  const _ProductRecord({required this.barcode, required this.origin, required this.product, this.name, this.brand, this.category, this.imageUrl, this.updatedAt, this.fromCache = false});
  

@override final  String barcode;
@override final  ProductOrigin origin;
@override final  Product product;
@override final  String? name;
@override final  String? brand;
/// Categoria mais específica (usada para alternativas seguras).
@override final  String? category;
@override final  String? imageUrl;
/// Última atualização dos dados na fonte.
@override final  DateTime? updatedAt;
/// Veio do cache local do Open Food Facts.
@override@JsonKey() final  bool fromCache;

/// Create a copy of ProductRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductRecordCopyWith<_ProductRecord> get copyWith => __$ProductRecordCopyWithImpl<_ProductRecord>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductRecord&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.product, product) || other.product == product)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.category, category) || other.category == category)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.fromCache, fromCache) || other.fromCache == fromCache));
}


@override
int get hashCode => Object.hash(runtimeType,barcode,origin,product,name,brand,category,imageUrl,updatedAt,fromCache);

@override
String toString() {
  return 'ProductRecord(barcode: $barcode, origin: $origin, product: $product, name: $name, brand: $brand, category: $category, imageUrl: $imageUrl, updatedAt: $updatedAt, fromCache: $fromCache)';
}


}

/// @nodoc
abstract mixin class _$ProductRecordCopyWith<$Res> implements $ProductRecordCopyWith<$Res> {
  factory _$ProductRecordCopyWith(_ProductRecord value, $Res Function(_ProductRecord) _then) = __$ProductRecordCopyWithImpl;
@override @useResult
$Res call({
 String barcode, ProductOrigin origin, Product product, String? name, String? brand, String? category, String? imageUrl, DateTime? updatedAt, bool fromCache
});


@override $ProductCopyWith<$Res> get product;

}
/// @nodoc
class __$ProductRecordCopyWithImpl<$Res>
    implements _$ProductRecordCopyWith<$Res> {
  __$ProductRecordCopyWithImpl(this._self, this._then);

  final _ProductRecord _self;
  final $Res Function(_ProductRecord) _then;

/// Create a copy of ProductRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? barcode = null,Object? origin = null,Object? product = null,Object? name = freezed,Object? brand = freezed,Object? category = freezed,Object? imageUrl = freezed,Object? updatedAt = freezed,Object? fromCache = null,}) {
  return _then(_ProductRecord(
barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as ProductOrigin,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,fromCache: null == fromCache ? _self.fromCache : fromCache // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ProductRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductCopyWith<$Res> get product {
  
  return $ProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}

// dart format on
