// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Product {

/// Lista de ingredientes como está no rótulo (ou lida por OCR).
 String get ingredientsText;/// Alergênicos declarados como presentes ("CONTÉM ...", tags do OFF).
 Set<Allergen> get allergensContains;/// Alergênicos declarados como traços ("PODE CONTER ...").
 Set<Allergen> get allergensTraces;/// A lista de ingredientes é completa e confiável.
 bool get hasIngredients;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.ingredientsText, ingredientsText) || other.ingredientsText == ingredientsText)&&const DeepCollectionEquality().equals(other.allergensContains, allergensContains)&&const DeepCollectionEquality().equals(other.allergensTraces, allergensTraces)&&(identical(other.hasIngredients, hasIngredients) || other.hasIngredients == hasIngredients));
}


@override
int get hashCode => Object.hash(runtimeType,ingredientsText,const DeepCollectionEquality().hash(allergensContains),const DeepCollectionEquality().hash(allergensTraces),hasIngredients);

@override
String toString() {
  return 'Product(ingredientsText: $ingredientsText, allergensContains: $allergensContains, allergensTraces: $allergensTraces, hasIngredients: $hasIngredients)';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 String ingredientsText, Set<Allergen> allergensContains, Set<Allergen> allergensTraces, bool hasIngredients
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ingredientsText = null,Object? allergensContains = null,Object? allergensTraces = null,Object? hasIngredients = null,}) {
  return _then(_self.copyWith(
ingredientsText: null == ingredientsText ? _self.ingredientsText : ingredientsText // ignore: cast_nullable_to_non_nullable
as String,allergensContains: null == allergensContains ? _self.allergensContains : allergensContains // ignore: cast_nullable_to_non_nullable
as Set<Allergen>,allergensTraces: null == allergensTraces ? _self.allergensTraces : allergensTraces // ignore: cast_nullable_to_non_nullable
as Set<Allergen>,hasIngredients: null == hasIngredients ? _self.hasIngredients : hasIngredients // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ingredientsText,  Set<Allergen> allergensContains,  Set<Allergen> allergensTraces,  bool hasIngredients)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.ingredientsText,_that.allergensContains,_that.allergensTraces,_that.hasIngredients);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ingredientsText,  Set<Allergen> allergensContains,  Set<Allergen> allergensTraces,  bool hasIngredients)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.ingredientsText,_that.allergensContains,_that.allergensTraces,_that.hasIngredients);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ingredientsText,  Set<Allergen> allergensContains,  Set<Allergen> allergensTraces,  bool hasIngredients)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.ingredientsText,_that.allergensContains,_that.allergensTraces,_that.hasIngredients);case _:
  return null;

}
}

}

/// @nodoc


class _Product extends Product {
  const _Product({this.ingredientsText = '', final  Set<Allergen> allergensContains = const <Allergen>{}, final  Set<Allergen> allergensTraces = const <Allergen>{}, required this.hasIngredients}): _allergensContains = allergensContains,_allergensTraces = allergensTraces,super._();
  

/// Lista de ingredientes como está no rótulo (ou lida por OCR).
@override@JsonKey() final  String ingredientsText;
/// Alergênicos declarados como presentes ("CONTÉM ...", tags do OFF).
 final  Set<Allergen> _allergensContains;
/// Alergênicos declarados como presentes ("CONTÉM ...", tags do OFF).
@override@JsonKey() Set<Allergen> get allergensContains {
  if (_allergensContains is EqualUnmodifiableSetView) return _allergensContains;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_allergensContains);
}

/// Alergênicos declarados como traços ("PODE CONTER ...").
 final  Set<Allergen> _allergensTraces;
/// Alergênicos declarados como traços ("PODE CONTER ...").
@override@JsonKey() Set<Allergen> get allergensTraces {
  if (_allergensTraces is EqualUnmodifiableSetView) return _allergensTraces;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_allergensTraces);
}

/// A lista de ingredientes é completa e confiável.
@override final  bool hasIngredients;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.ingredientsText, ingredientsText) || other.ingredientsText == ingredientsText)&&const DeepCollectionEquality().equals(other._allergensContains, _allergensContains)&&const DeepCollectionEquality().equals(other._allergensTraces, _allergensTraces)&&(identical(other.hasIngredients, hasIngredients) || other.hasIngredients == hasIngredients));
}


@override
int get hashCode => Object.hash(runtimeType,ingredientsText,const DeepCollectionEquality().hash(_allergensContains),const DeepCollectionEquality().hash(_allergensTraces),hasIngredients);

@override
String toString() {
  return 'Product(ingredientsText: $ingredientsText, allergensContains: $allergensContains, allergensTraces: $allergensTraces, hasIngredients: $hasIngredients)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 String ingredientsText, Set<Allergen> allergensContains, Set<Allergen> allergensTraces, bool hasIngredients
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ingredientsText = null,Object? allergensContains = null,Object? allergensTraces = null,Object? hasIngredients = null,}) {
  return _then(_Product(
ingredientsText: null == ingredientsText ? _self.ingredientsText : ingredientsText // ignore: cast_nullable_to_non_nullable
as String,allergensContains: null == allergensContains ? _self._allergensContains : allergensContains // ignore: cast_nullable_to_non_nullable
as Set<Allergen>,allergensTraces: null == allergensTraces ? _self._allergensTraces : allergensTraces // ignore: cast_nullable_to_non_nullable
as Set<Allergen>,hasIngredients: null == hasIngredients ? _self.hasIngredients : hasIngredients // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$PersonAllergy {

 Allergen get allergen; AllergySeverity get severity;
/// Create a copy of PersonAllergy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonAllergyCopyWith<PersonAllergy> get copyWith => _$PersonAllergyCopyWithImpl<PersonAllergy>(this as PersonAllergy, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonAllergy&&(identical(other.allergen, allergen) || other.allergen == allergen)&&(identical(other.severity, severity) || other.severity == severity));
}


@override
int get hashCode => Object.hash(runtimeType,allergen,severity);

@override
String toString() {
  return 'PersonAllergy(allergen: $allergen, severity: $severity)';
}


}

/// @nodoc
abstract mixin class $PersonAllergyCopyWith<$Res>  {
  factory $PersonAllergyCopyWith(PersonAllergy value, $Res Function(PersonAllergy) _then) = _$PersonAllergyCopyWithImpl;
@useResult
$Res call({
 Allergen allergen, AllergySeverity severity
});




}
/// @nodoc
class _$PersonAllergyCopyWithImpl<$Res>
    implements $PersonAllergyCopyWith<$Res> {
  _$PersonAllergyCopyWithImpl(this._self, this._then);

  final PersonAllergy _self;
  final $Res Function(PersonAllergy) _then;

/// Create a copy of PersonAllergy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? allergen = null,Object? severity = null,}) {
  return _then(_self.copyWith(
allergen: null == allergen ? _self.allergen : allergen // ignore: cast_nullable_to_non_nullable
as Allergen,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as AllergySeverity,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonAllergy].
extension PersonAllergyPatterns on PersonAllergy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonAllergy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonAllergy() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonAllergy value)  $default,){
final _that = this;
switch (_that) {
case _PersonAllergy():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonAllergy value)?  $default,){
final _that = this;
switch (_that) {
case _PersonAllergy() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Allergen allergen,  AllergySeverity severity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonAllergy() when $default != null:
return $default(_that.allergen,_that.severity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Allergen allergen,  AllergySeverity severity)  $default,) {final _that = this;
switch (_that) {
case _PersonAllergy():
return $default(_that.allergen,_that.severity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Allergen allergen,  AllergySeverity severity)?  $default,) {final _that = this;
switch (_that) {
case _PersonAllergy() when $default != null:
return $default(_that.allergen,_that.severity);case _:
  return null;

}
}

}

/// @nodoc


class _PersonAllergy implements PersonAllergy {
  const _PersonAllergy({required this.allergen, this.severity = AllergySeverity.mild});
  

@override final  Allergen allergen;
@override@JsonKey() final  AllergySeverity severity;

/// Create a copy of PersonAllergy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonAllergyCopyWith<_PersonAllergy> get copyWith => __$PersonAllergyCopyWithImpl<_PersonAllergy>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonAllergy&&(identical(other.allergen, allergen) || other.allergen == allergen)&&(identical(other.severity, severity) || other.severity == severity));
}


@override
int get hashCode => Object.hash(runtimeType,allergen,severity);

@override
String toString() {
  return 'PersonAllergy(allergen: $allergen, severity: $severity)';
}


}

/// @nodoc
abstract mixin class _$PersonAllergyCopyWith<$Res> implements $PersonAllergyCopyWith<$Res> {
  factory _$PersonAllergyCopyWith(_PersonAllergy value, $Res Function(_PersonAllergy) _then) = __$PersonAllergyCopyWithImpl;
@override @useResult
$Res call({
 Allergen allergen, AllergySeverity severity
});




}
/// @nodoc
class __$PersonAllergyCopyWithImpl<$Res>
    implements _$PersonAllergyCopyWith<$Res> {
  __$PersonAllergyCopyWithImpl(this._self, this._then);

  final _PersonAllergy _self;
  final $Res Function(_PersonAllergy) _then;

/// Create a copy of PersonAllergy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? allergen = null,Object? severity = null,}) {
  return _then(_PersonAllergy(
allergen: null == allergen ? _self.allergen : allergen // ignore: cast_nullable_to_non_nullable
as Allergen,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as AllergySeverity,
  ));
}


}

/// @nodoc
mixin _$Person {

 String get id; String get name; List<PersonAllergy> get allergies;
/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonCopyWith<Person> get copyWith => _$PersonCopyWithImpl<Person>(this as Person, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Person&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.allergies, allergies));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(allergies));

@override
String toString() {
  return 'Person(id: $id, name: $name, allergies: $allergies)';
}


}

/// @nodoc
abstract mixin class $PersonCopyWith<$Res>  {
  factory $PersonCopyWith(Person value, $Res Function(Person) _then) = _$PersonCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<PersonAllergy> allergies
});




}
/// @nodoc
class _$PersonCopyWithImpl<$Res>
    implements $PersonCopyWith<$Res> {
  _$PersonCopyWithImpl(this._self, this._then);

  final Person _self;
  final $Res Function(Person) _then;

/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? allergies = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,allergies: null == allergies ? _self.allergies : allergies // ignore: cast_nullable_to_non_nullable
as List<PersonAllergy>,
  ));
}

}


/// Adds pattern-matching-related methods to [Person].
extension PersonPatterns on Person {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Person value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Person() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Person value)  $default,){
final _that = this;
switch (_that) {
case _Person():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Person value)?  $default,){
final _that = this;
switch (_that) {
case _Person() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<PersonAllergy> allergies)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Person() when $default != null:
return $default(_that.id,_that.name,_that.allergies);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<PersonAllergy> allergies)  $default,) {final _that = this;
switch (_that) {
case _Person():
return $default(_that.id,_that.name,_that.allergies);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<PersonAllergy> allergies)?  $default,) {final _that = this;
switch (_that) {
case _Person() when $default != null:
return $default(_that.id,_that.name,_that.allergies);case _:
  return null;

}
}

}

/// @nodoc


class _Person implements Person {
  const _Person({required this.id, required this.name, final  List<PersonAllergy> allergies = const <PersonAllergy>[]}): _allergies = allergies;
  

@override final  String id;
@override final  String name;
 final  List<PersonAllergy> _allergies;
@override@JsonKey() List<PersonAllergy> get allergies {
  if (_allergies is EqualUnmodifiableListView) return _allergies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allergies);
}


/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonCopyWith<_Person> get copyWith => __$PersonCopyWithImpl<_Person>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Person&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._allergies, _allergies));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_allergies));

@override
String toString() {
  return 'Person(id: $id, name: $name, allergies: $allergies)';
}


}

/// @nodoc
abstract mixin class _$PersonCopyWith<$Res> implements $PersonCopyWith<$Res> {
  factory _$PersonCopyWith(_Person value, $Res Function(_Person) _then) = __$PersonCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<PersonAllergy> allergies
});




}
/// @nodoc
class __$PersonCopyWithImpl<$Res>
    implements _$PersonCopyWith<$Res> {
  __$PersonCopyWithImpl(this._self, this._then);

  final _Person _self;
  final $Res Function(_Person) _then;

/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? allergies = null,}) {
  return _then(_Person(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,allergies: null == allergies ? _self._allergies : allergies // ignore: cast_nullable_to_non_nullable
as List<PersonAllergy>,
  ));
}


}

/// @nodoc
mixin _$VerdictReason {

 VerdictStatus get status; ReasonKind get kind; ReasonSource get source;/// Alergênico da pessoa que motivou o status.
 Allergen? get allergen;/// Trecho exato do texto original (ex.: "Pode conter amendoim").
 String? get excerpt;/// Casou por tolerância a erro de OCR, não por igualdade exata.
 bool get approximate; Escalation get escalation;
/// Create a copy of VerdictReason
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerdictReasonCopyWith<VerdictReason> get copyWith => _$VerdictReasonCopyWithImpl<VerdictReason>(this as VerdictReason, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerdictReason&&(identical(other.status, status) || other.status == status)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.source, source) || other.source == source)&&(identical(other.allergen, allergen) || other.allergen == allergen)&&(identical(other.excerpt, excerpt) || other.excerpt == excerpt)&&(identical(other.approximate, approximate) || other.approximate == approximate)&&(identical(other.escalation, escalation) || other.escalation == escalation));
}


@override
int get hashCode => Object.hash(runtimeType,status,kind,source,allergen,excerpt,approximate,escalation);

@override
String toString() {
  return 'VerdictReason(status: $status, kind: $kind, source: $source, allergen: $allergen, excerpt: $excerpt, approximate: $approximate, escalation: $escalation)';
}


}

/// @nodoc
abstract mixin class $VerdictReasonCopyWith<$Res>  {
  factory $VerdictReasonCopyWith(VerdictReason value, $Res Function(VerdictReason) _then) = _$VerdictReasonCopyWithImpl;
@useResult
$Res call({
 VerdictStatus status, ReasonKind kind, ReasonSource source, Allergen? allergen, String? excerpt, bool approximate, Escalation escalation
});




}
/// @nodoc
class _$VerdictReasonCopyWithImpl<$Res>
    implements $VerdictReasonCopyWith<$Res> {
  _$VerdictReasonCopyWithImpl(this._self, this._then);

  final VerdictReason _self;
  final $Res Function(VerdictReason) _then;

/// Create a copy of VerdictReason
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? kind = null,Object? source = null,Object? allergen = freezed,Object? excerpt = freezed,Object? approximate = null,Object? escalation = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VerdictStatus,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReasonKind,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ReasonSource,allergen: freezed == allergen ? _self.allergen : allergen // ignore: cast_nullable_to_non_nullable
as Allergen?,excerpt: freezed == excerpt ? _self.excerpt : excerpt // ignore: cast_nullable_to_non_nullable
as String?,approximate: null == approximate ? _self.approximate : approximate // ignore: cast_nullable_to_non_nullable
as bool,escalation: null == escalation ? _self.escalation : escalation // ignore: cast_nullable_to_non_nullable
as Escalation,
  ));
}

}


/// Adds pattern-matching-related methods to [VerdictReason].
extension VerdictReasonPatterns on VerdictReason {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerdictReason value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerdictReason() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerdictReason value)  $default,){
final _that = this;
switch (_that) {
case _VerdictReason():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerdictReason value)?  $default,){
final _that = this;
switch (_that) {
case _VerdictReason() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VerdictStatus status,  ReasonKind kind,  ReasonSource source,  Allergen? allergen,  String? excerpt,  bool approximate,  Escalation escalation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerdictReason() when $default != null:
return $default(_that.status,_that.kind,_that.source,_that.allergen,_that.excerpt,_that.approximate,_that.escalation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VerdictStatus status,  ReasonKind kind,  ReasonSource source,  Allergen? allergen,  String? excerpt,  bool approximate,  Escalation escalation)  $default,) {final _that = this;
switch (_that) {
case _VerdictReason():
return $default(_that.status,_that.kind,_that.source,_that.allergen,_that.excerpt,_that.approximate,_that.escalation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VerdictStatus status,  ReasonKind kind,  ReasonSource source,  Allergen? allergen,  String? excerpt,  bool approximate,  Escalation escalation)?  $default,) {final _that = this;
switch (_that) {
case _VerdictReason() when $default != null:
return $default(_that.status,_that.kind,_that.source,_that.allergen,_that.excerpt,_that.approximate,_that.escalation);case _:
  return null;

}
}

}

/// @nodoc


class _VerdictReason implements VerdictReason {
  const _VerdictReason({required this.status, required this.kind, this.source = ReasonSource.product, this.allergen, this.excerpt, this.approximate = false, this.escalation = Escalation.none});
  

@override final  VerdictStatus status;
@override final  ReasonKind kind;
@override@JsonKey() final  ReasonSource source;
/// Alergênico da pessoa que motivou o status.
@override final  Allergen? allergen;
/// Trecho exato do texto original (ex.: "Pode conter amendoim").
@override final  String? excerpt;
/// Casou por tolerância a erro de OCR, não por igualdade exata.
@override@JsonKey() final  bool approximate;
@override@JsonKey() final  Escalation escalation;

/// Create a copy of VerdictReason
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerdictReasonCopyWith<_VerdictReason> get copyWith => __$VerdictReasonCopyWithImpl<_VerdictReason>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerdictReason&&(identical(other.status, status) || other.status == status)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.source, source) || other.source == source)&&(identical(other.allergen, allergen) || other.allergen == allergen)&&(identical(other.excerpt, excerpt) || other.excerpt == excerpt)&&(identical(other.approximate, approximate) || other.approximate == approximate)&&(identical(other.escalation, escalation) || other.escalation == escalation));
}


@override
int get hashCode => Object.hash(runtimeType,status,kind,source,allergen,excerpt,approximate,escalation);

@override
String toString() {
  return 'VerdictReason(status: $status, kind: $kind, source: $source, allergen: $allergen, excerpt: $excerpt, approximate: $approximate, escalation: $escalation)';
}


}

/// @nodoc
abstract mixin class _$VerdictReasonCopyWith<$Res> implements $VerdictReasonCopyWith<$Res> {
  factory _$VerdictReasonCopyWith(_VerdictReason value, $Res Function(_VerdictReason) _then) = __$VerdictReasonCopyWithImpl;
@override @useResult
$Res call({
 VerdictStatus status, ReasonKind kind, ReasonSource source, Allergen? allergen, String? excerpt, bool approximate, Escalation escalation
});




}
/// @nodoc
class __$VerdictReasonCopyWithImpl<$Res>
    implements _$VerdictReasonCopyWith<$Res> {
  __$VerdictReasonCopyWithImpl(this._self, this._then);

  final _VerdictReason _self;
  final $Res Function(_VerdictReason) _then;

/// Create a copy of VerdictReason
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? kind = null,Object? source = null,Object? allergen = freezed,Object? excerpt = freezed,Object? approximate = null,Object? escalation = null,}) {
  return _then(_VerdictReason(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VerdictStatus,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReasonKind,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ReasonSource,allergen: freezed == allergen ? _self.allergen : allergen // ignore: cast_nullable_to_non_nullable
as Allergen?,excerpt: freezed == excerpt ? _self.excerpt : excerpt // ignore: cast_nullable_to_non_nullable
as String?,approximate: null == approximate ? _self.approximate : approximate // ignore: cast_nullable_to_non_nullable
as bool,escalation: null == escalation ? _self.escalation : escalation // ignore: cast_nullable_to_non_nullable
as Escalation,
  ));
}


}

/// @nodoc
mixin _$PersonVerdict {

 String get personId; String get personName; VerdictStatus get status;/// Ordenados do mais grave para o menos grave.
 List<VerdictReason> get reasons;
/// Create a copy of PersonVerdict
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonVerdictCopyWith<PersonVerdict> get copyWith => _$PersonVerdictCopyWithImpl<PersonVerdict>(this as PersonVerdict, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonVerdict&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.personName, personName) || other.personName == personName)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.reasons, reasons));
}


@override
int get hashCode => Object.hash(runtimeType,personId,personName,status,const DeepCollectionEquality().hash(reasons));

@override
String toString() {
  return 'PersonVerdict(personId: $personId, personName: $personName, status: $status, reasons: $reasons)';
}


}

/// @nodoc
abstract mixin class $PersonVerdictCopyWith<$Res>  {
  factory $PersonVerdictCopyWith(PersonVerdict value, $Res Function(PersonVerdict) _then) = _$PersonVerdictCopyWithImpl;
@useResult
$Res call({
 String personId, String personName, VerdictStatus status, List<VerdictReason> reasons
});




}
/// @nodoc
class _$PersonVerdictCopyWithImpl<$Res>
    implements $PersonVerdictCopyWith<$Res> {
  _$PersonVerdictCopyWithImpl(this._self, this._then);

  final PersonVerdict _self;
  final $Res Function(PersonVerdict) _then;

/// Create a copy of PersonVerdict
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? personId = null,Object? personName = null,Object? status = null,Object? reasons = null,}) {
  return _then(_self.copyWith(
personId: null == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String,personName: null == personName ? _self.personName : personName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VerdictStatus,reasons: null == reasons ? _self.reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<VerdictReason>,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonVerdict].
extension PersonVerdictPatterns on PersonVerdict {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonVerdict value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonVerdict() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonVerdict value)  $default,){
final _that = this;
switch (_that) {
case _PersonVerdict():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonVerdict value)?  $default,){
final _that = this;
switch (_that) {
case _PersonVerdict() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String personId,  String personName,  VerdictStatus status,  List<VerdictReason> reasons)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonVerdict() when $default != null:
return $default(_that.personId,_that.personName,_that.status,_that.reasons);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String personId,  String personName,  VerdictStatus status,  List<VerdictReason> reasons)  $default,) {final _that = this;
switch (_that) {
case _PersonVerdict():
return $default(_that.personId,_that.personName,_that.status,_that.reasons);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String personId,  String personName,  VerdictStatus status,  List<VerdictReason> reasons)?  $default,) {final _that = this;
switch (_that) {
case _PersonVerdict() when $default != null:
return $default(_that.personId,_that.personName,_that.status,_that.reasons);case _:
  return null;

}
}

}

/// @nodoc


class _PersonVerdict implements PersonVerdict {
  const _PersonVerdict({required this.personId, required this.personName, required this.status, final  List<VerdictReason> reasons = const <VerdictReason>[]}): _reasons = reasons;
  

@override final  String personId;
@override final  String personName;
@override final  VerdictStatus status;
/// Ordenados do mais grave para o menos grave.
 final  List<VerdictReason> _reasons;
/// Ordenados do mais grave para o menos grave.
@override@JsonKey() List<VerdictReason> get reasons {
  if (_reasons is EqualUnmodifiableListView) return _reasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reasons);
}


/// Create a copy of PersonVerdict
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonVerdictCopyWith<_PersonVerdict> get copyWith => __$PersonVerdictCopyWithImpl<_PersonVerdict>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonVerdict&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.personName, personName) || other.personName == personName)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._reasons, _reasons));
}


@override
int get hashCode => Object.hash(runtimeType,personId,personName,status,const DeepCollectionEquality().hash(_reasons));

@override
String toString() {
  return 'PersonVerdict(personId: $personId, personName: $personName, status: $status, reasons: $reasons)';
}


}

/// @nodoc
abstract mixin class _$PersonVerdictCopyWith<$Res> implements $PersonVerdictCopyWith<$Res> {
  factory _$PersonVerdictCopyWith(_PersonVerdict value, $Res Function(_PersonVerdict) _then) = __$PersonVerdictCopyWithImpl;
@override @useResult
$Res call({
 String personId, String personName, VerdictStatus status, List<VerdictReason> reasons
});




}
/// @nodoc
class __$PersonVerdictCopyWithImpl<$Res>
    implements _$PersonVerdictCopyWith<$Res> {
  __$PersonVerdictCopyWithImpl(this._self, this._then);

  final _PersonVerdict _self;
  final $Res Function(_PersonVerdict) _then;

/// Create a copy of PersonVerdict
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? personId = null,Object? personName = null,Object? status = null,Object? reasons = null,}) {
  return _then(_PersonVerdict(
personId: null == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String,personName: null == personName ? _self.personName : personName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VerdictStatus,reasons: null == reasons ? _self._reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<VerdictReason>,
  ));
}


}

/// @nodoc
mixin _$GroupVerdict {

/// Pior status entre as pessoas selecionadas.
 VerdictStatus get status; List<PersonVerdict> get people;
/// Create a copy of GroupVerdict
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupVerdictCopyWith<GroupVerdict> get copyWith => _$GroupVerdictCopyWithImpl<GroupVerdict>(this as GroupVerdict, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupVerdict&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.people, people));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(people));

@override
String toString() {
  return 'GroupVerdict(status: $status, people: $people)';
}


}

/// @nodoc
abstract mixin class $GroupVerdictCopyWith<$Res>  {
  factory $GroupVerdictCopyWith(GroupVerdict value, $Res Function(GroupVerdict) _then) = _$GroupVerdictCopyWithImpl;
@useResult
$Res call({
 VerdictStatus status, List<PersonVerdict> people
});




}
/// @nodoc
class _$GroupVerdictCopyWithImpl<$Res>
    implements $GroupVerdictCopyWith<$Res> {
  _$GroupVerdictCopyWithImpl(this._self, this._then);

  final GroupVerdict _self;
  final $Res Function(GroupVerdict) _then;

/// Create a copy of GroupVerdict
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? people = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VerdictStatus,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as List<PersonVerdict>,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupVerdict].
extension GroupVerdictPatterns on GroupVerdict {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupVerdict value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupVerdict() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupVerdict value)  $default,){
final _that = this;
switch (_that) {
case _GroupVerdict():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupVerdict value)?  $default,){
final _that = this;
switch (_that) {
case _GroupVerdict() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VerdictStatus status,  List<PersonVerdict> people)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupVerdict() when $default != null:
return $default(_that.status,_that.people);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VerdictStatus status,  List<PersonVerdict> people)  $default,) {final _that = this;
switch (_that) {
case _GroupVerdict():
return $default(_that.status,_that.people);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VerdictStatus status,  List<PersonVerdict> people)?  $default,) {final _that = this;
switch (_that) {
case _GroupVerdict() when $default != null:
return $default(_that.status,_that.people);case _:
  return null;

}
}

}

/// @nodoc


class _GroupVerdict implements GroupVerdict {
  const _GroupVerdict({required this.status, final  List<PersonVerdict> people = const <PersonVerdict>[]}): _people = people;
  

/// Pior status entre as pessoas selecionadas.
@override final  VerdictStatus status;
 final  List<PersonVerdict> _people;
@override@JsonKey() List<PersonVerdict> get people {
  if (_people is EqualUnmodifiableListView) return _people;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_people);
}


/// Create a copy of GroupVerdict
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupVerdictCopyWith<_GroupVerdict> get copyWith => __$GroupVerdictCopyWithImpl<_GroupVerdict>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupVerdict&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._people, _people));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_people));

@override
String toString() {
  return 'GroupVerdict(status: $status, people: $people)';
}


}

/// @nodoc
abstract mixin class _$GroupVerdictCopyWith<$Res> implements $GroupVerdictCopyWith<$Res> {
  factory _$GroupVerdictCopyWith(_GroupVerdict value, $Res Function(_GroupVerdict) _then) = __$GroupVerdictCopyWithImpl;
@override @useResult
$Res call({
 VerdictStatus status, List<PersonVerdict> people
});




}
/// @nodoc
class __$GroupVerdictCopyWithImpl<$Res>
    implements _$GroupVerdictCopyWith<$Res> {
  __$GroupVerdictCopyWithImpl(this._self, this._then);

  final _GroupVerdict _self;
  final $Res Function(_GroupVerdict) _then;

/// Create a copy of GroupVerdict
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? people = null,}) {
  return _then(_GroupVerdict(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VerdictStatus,people: null == people ? _self._people : people // ignore: cast_nullable_to_non_nullable
as List<PersonVerdict>,
  ));
}


}

// dart format on
