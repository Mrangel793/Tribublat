// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FeedState {
  // Tab y filtro actual
  FeedTab get currentTab => throw _privateConstructorUsedError;
  FeedFilter get currentFilter => throw _privateConstructorUsedError;
  String get searchQuery =>
      throw _privateConstructorUsedError; // Datos de planes
  List<PlanModel> get plans => throw _privateConstructorUsedError;
  Map<String, int> get matchScores =>
      throw _privateConstructorUsedError; // Datos del usuario para matching
  UserModel? get currentUser =>
      throw _privateConstructorUsedError; // Estados de carga
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isRefreshing => throw _privateConstructorUsedError;
  bool get isSearching => throw _privateConstructorUsedError;
  String? get joiningPlanId =>
      throw _privateConstructorUsedError; // Manejo de errores
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get successMessage => throw _privateConstructorUsedError;

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedStateCopyWith<FeedState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedStateCopyWith<$Res> {
  factory $FeedStateCopyWith(FeedState value, $Res Function(FeedState) then) =
      _$FeedStateCopyWithImpl<$Res, FeedState>;
  @useResult
  $Res call({
    FeedTab currentTab,
    FeedFilter currentFilter,
    String searchQuery,
    List<PlanModel> plans,
    Map<String, int> matchScores,
    UserModel? currentUser,
    bool isLoading,
    bool isRefreshing,
    bool isSearching,
    String? joiningPlanId,
    String? errorMessage,
    String? successMessage,
  });

  $UserModelCopyWith<$Res>? get currentUser;
}

/// @nodoc
class _$FeedStateCopyWithImpl<$Res, $Val extends FeedState>
    implements $FeedStateCopyWith<$Res> {
  _$FeedStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentTab = null,
    Object? currentFilter = null,
    Object? searchQuery = null,
    Object? plans = null,
    Object? matchScores = null,
    Object? currentUser = freezed,
    Object? isLoading = null,
    Object? isRefreshing = null,
    Object? isSearching = null,
    Object? joiningPlanId = freezed,
    Object? errorMessage = freezed,
    Object? successMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            currentTab: null == currentTab
                ? _value.currentTab
                : currentTab // ignore: cast_nullable_to_non_nullable
                      as FeedTab,
            currentFilter: null == currentFilter
                ? _value.currentFilter
                : currentFilter // ignore: cast_nullable_to_non_nullable
                      as FeedFilter,
            searchQuery: null == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                      as String,
            plans: null == plans
                ? _value.plans
                : plans // ignore: cast_nullable_to_non_nullable
                      as List<PlanModel>,
            matchScores: null == matchScores
                ? _value.matchScores
                : matchScores // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            currentUser: freezed == currentUser
                ? _value.currentUser
                : currentUser // ignore: cast_nullable_to_non_nullable
                      as UserModel?,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isRefreshing: null == isRefreshing
                ? _value.isRefreshing
                : isRefreshing // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSearching: null == isSearching
                ? _value.isSearching
                : isSearching // ignore: cast_nullable_to_non_nullable
                      as bool,
            joiningPlanId: freezed == joiningPlanId
                ? _value.joiningPlanId
                : joiningPlanId // ignore: cast_nullable_to_non_nullable
                      as String?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            successMessage: freezed == successMessage
                ? _value.successMessage
                : successMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res>? get currentUser {
    if (_value.currentUser == null) {
      return null;
    }

    return $UserModelCopyWith<$Res>(_value.currentUser!, (value) {
      return _then(_value.copyWith(currentUser: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FeedStateImplCopyWith<$Res>
    implements $FeedStateCopyWith<$Res> {
  factory _$$FeedStateImplCopyWith(
    _$FeedStateImpl value,
    $Res Function(_$FeedStateImpl) then,
  ) = __$$FeedStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    FeedTab currentTab,
    FeedFilter currentFilter,
    String searchQuery,
    List<PlanModel> plans,
    Map<String, int> matchScores,
    UserModel? currentUser,
    bool isLoading,
    bool isRefreshing,
    bool isSearching,
    String? joiningPlanId,
    String? errorMessage,
    String? successMessage,
  });

  @override
  $UserModelCopyWith<$Res>? get currentUser;
}

/// @nodoc
class __$$FeedStateImplCopyWithImpl<$Res>
    extends _$FeedStateCopyWithImpl<$Res, _$FeedStateImpl>
    implements _$$FeedStateImplCopyWith<$Res> {
  __$$FeedStateImplCopyWithImpl(
    _$FeedStateImpl _value,
    $Res Function(_$FeedStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentTab = null,
    Object? currentFilter = null,
    Object? searchQuery = null,
    Object? plans = null,
    Object? matchScores = null,
    Object? currentUser = freezed,
    Object? isLoading = null,
    Object? isRefreshing = null,
    Object? isSearching = null,
    Object? joiningPlanId = freezed,
    Object? errorMessage = freezed,
    Object? successMessage = freezed,
  }) {
    return _then(
      _$FeedStateImpl(
        currentTab: null == currentTab
            ? _value.currentTab
            : currentTab // ignore: cast_nullable_to_non_nullable
                  as FeedTab,
        currentFilter: null == currentFilter
            ? _value.currentFilter
            : currentFilter // ignore: cast_nullable_to_non_nullable
                  as FeedFilter,
        searchQuery: null == searchQuery
            ? _value.searchQuery
            : searchQuery // ignore: cast_nullable_to_non_nullable
                  as String,
        plans: null == plans
            ? _value._plans
            : plans // ignore: cast_nullable_to_non_nullable
                  as List<PlanModel>,
        matchScores: null == matchScores
            ? _value._matchScores
            : matchScores // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        currentUser: freezed == currentUser
            ? _value.currentUser
            : currentUser // ignore: cast_nullable_to_non_nullable
                  as UserModel?,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isRefreshing: null == isRefreshing
            ? _value.isRefreshing
            : isRefreshing // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSearching: null == isSearching
            ? _value.isSearching
            : isSearching // ignore: cast_nullable_to_non_nullable
                  as bool,
        joiningPlanId: freezed == joiningPlanId
            ? _value.joiningPlanId
            : joiningPlanId // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        successMessage: freezed == successMessage
            ? _value.successMessage
            : successMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$FeedStateImpl implements _FeedState {
  const _$FeedStateImpl({
    this.currentTab = FeedTab.paraTi,
    this.currentFilter = FeedFilter.todos,
    this.searchQuery = '',
    final List<PlanModel> plans = const [],
    final Map<String, int> matchScores = const {},
    this.currentUser,
    this.isLoading = true,
    this.isRefreshing = false,
    this.isSearching = false,
    this.joiningPlanId = null,
    this.errorMessage,
    this.successMessage,
  }) : _plans = plans,
       _matchScores = matchScores;

  // Tab y filtro actual
  @override
  @JsonKey()
  final FeedTab currentTab;
  @override
  @JsonKey()
  final FeedFilter currentFilter;
  @override
  @JsonKey()
  final String searchQuery;
  // Datos de planes
  final List<PlanModel> _plans;
  // Datos de planes
  @override
  @JsonKey()
  List<PlanModel> get plans {
    if (_plans is EqualUnmodifiableListView) return _plans;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_plans);
  }

  final Map<String, int> _matchScores;
  @override
  @JsonKey()
  Map<String, int> get matchScores {
    if (_matchScores is EqualUnmodifiableMapView) return _matchScores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_matchScores);
  }

  // Datos del usuario para matching
  @override
  final UserModel? currentUser;
  // Estados de carga
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isRefreshing;
  @override
  @JsonKey()
  final bool isSearching;
  @override
  @JsonKey()
  final String? joiningPlanId;
  // Manejo de errores
  @override
  final String? errorMessage;
  @override
  final String? successMessage;

  @override
  String toString() {
    return 'FeedState(currentTab: $currentTab, currentFilter: $currentFilter, searchQuery: $searchQuery, plans: $plans, matchScores: $matchScores, currentUser: $currentUser, isLoading: $isLoading, isRefreshing: $isRefreshing, isSearching: $isSearching, joiningPlanId: $joiningPlanId, errorMessage: $errorMessage, successMessage: $successMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedStateImpl &&
            (identical(other.currentTab, currentTab) ||
                other.currentTab == currentTab) &&
            (identical(other.currentFilter, currentFilter) ||
                other.currentFilter == currentFilter) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            const DeepCollectionEquality().equals(other._plans, _plans) &&
            const DeepCollectionEquality().equals(
              other._matchScores,
              _matchScores,
            ) &&
            (identical(other.currentUser, currentUser) ||
                other.currentUser == currentUser) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isRefreshing, isRefreshing) ||
                other.isRefreshing == isRefreshing) &&
            (identical(other.isSearching, isSearching) ||
                other.isSearching == isSearching) &&
            (identical(other.joiningPlanId, joiningPlanId) ||
                other.joiningPlanId == joiningPlanId) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.successMessage, successMessage) ||
                other.successMessage == successMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentTab,
    currentFilter,
    searchQuery,
    const DeepCollectionEquality().hash(_plans),
    const DeepCollectionEquality().hash(_matchScores),
    currentUser,
    isLoading,
    isRefreshing,
    isSearching,
    joiningPlanId,
    errorMessage,
    successMessage,
  );

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedStateImplCopyWith<_$FeedStateImpl> get copyWith =>
      __$$FeedStateImplCopyWithImpl<_$FeedStateImpl>(this, _$identity);
}

abstract class _FeedState implements FeedState {
  const factory _FeedState({
    final FeedTab currentTab,
    final FeedFilter currentFilter,
    final String searchQuery,
    final List<PlanModel> plans,
    final Map<String, int> matchScores,
    final UserModel? currentUser,
    final bool isLoading,
    final bool isRefreshing,
    final bool isSearching,
    final String? joiningPlanId,
    final String? errorMessage,
    final String? successMessage,
  }) = _$FeedStateImpl;

  // Tab y filtro actual
  @override
  FeedTab get currentTab;
  @override
  FeedFilter get currentFilter;
  @override
  String get searchQuery; // Datos de planes
  @override
  List<PlanModel> get plans;
  @override
  Map<String, int> get matchScores; // Datos del usuario para matching
  @override
  UserModel? get currentUser; // Estados de carga
  @override
  bool get isLoading;
  @override
  bool get isRefreshing;
  @override
  bool get isSearching;
  @override
  String? get joiningPlanId; // Manejo de errores
  @override
  String? get errorMessage;
  @override
  String? get successMessage;

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedStateImplCopyWith<_$FeedStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
