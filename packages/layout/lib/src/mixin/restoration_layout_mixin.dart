/*
import 'package:flutter/widgets.dart';

import '../base_layout_controller.dart';
import '../layout.dart';

base mixin RestorationLayoutMixin on BaseLayoutController {
  /// The restoration ID used for the [RestorationBucket] in which the mixin
  /// will store the restoration data of all registered properties.
  ///
  /// The restoration ID is used to claim a child [RestorationScope] from the
  /// surrounding [RestorationScope] (accessed via [RestorationScope.of]) and
  /// the ID must be unique in that scope (otherwise an exception is triggered
  /// in debug mode).
  ///
  /// State restoration for this mixin is turned off when this getter returns
  /// null or when there is no surrounding [RestorationScope] available. When
  /// state restoration is turned off, the values of the registered properties
  /// cannot be restored.
  ///
  /// Whenever the value returned by this getter changes,
  /// [didUpdateRestorationId] must be called unless the (unless the change
  /// already triggered a call to [didUpdateLayout]).
  ///
  /// The restoration ID returned by this getter is often provided in the
  /// constructor of the [BaseLayoutController] object is associated
  /// with.
  @protected
  String? get restorationId;

  /// The [RestorationBucket] used for the restoration data of the
  /// [RestorableProperty]s registered to this mixin.
  ///
  /// The bucket has been claimed from the surrounding [RestorationScope] using
  /// [restorationId].
  ///
  /// The getter returns null if state restoration is turned off. When state
  /// restoration is turned on or off during the lifetime of this mixin (and
  /// hence the return value of this getter switches between null and non-null)
  /// [didToggleBucket] is called.
  ///
  /// Interacting directly with this bucket is uncommon. However, the bucket may
  /// be injected into the widget tree in the [UILayout]'s `build` method using an
  /// [UnmanagedRestorationScope]. That allows descendants to claim child
  /// buckets from this bucket for their own restoration needs.
  RestorationBucket? get bucket => _bucket;
  RestorationBucket? _bucket;

  /// Called to initialize or restore the [RestorableProperty]s used by the
  /// [BaseLayoutController] object.
  ///
  /// This method is always invoked at least once right after [BaseLayoutController.init]
  /// to register the [RestorableProperty]s with the mixin even when state
  /// restoration is turned off or no restoration data is available for this
  /// [BaseLayoutController] object.
  ///
  /// Typically, [registerForRestoration] is called from this method to register
  /// all [RestorableProperty]s used by the [BaseLayoutController] object with the mixin. The
  /// registration will either restore the property's value to the value
  /// described by the restoration data, if available, or, if no restoration
  /// data is available - initialize it to a property-specific default value.
  ///
  /// The method is called again whenever new restoration data (in the form of a
  /// new [bucket]) has been provided to the mixin. When that happens, the
  /// [BaseLayoutController] object must re-register all previously registered properties,
  /// which will restore their values to the value described by the new
  /// restoration data.
  ///
  /// Since the method may change the value of the registered properties when
  /// new restoration state is provided, all initialization logic that depends
  /// on a specific value of a [RestorableProperty] should be included in this
  /// method. That way, that logic re-executes when the [RestorableProperty]s
  /// have their values restored from newly provided restoration data.
  ///
  /// The first time the method is invoked, the provided `oldBucket` argument is
  /// always null. In subsequent calls triggered by new restoration data in the
  /// form of a new bucket, the argument given is the previous value of
  /// [bucket].
  @mustCallSuper
  @protected
  void restoreState(RestorationBucket? oldBucket, bool initialRestore);

  /// Called when [bucket] switches between null and non-null values.
  ///
  /// [BaseLayoutController] objects that wish to directly interact with the bucket may
  /// override this method to store additional values in the bucket when one
  /// becomes available or to save values stored in a bucket elsewhere when the
  /// bucket goes away. This is uncommon and storing those values in
  /// [RestorableProperty]s should be considered instead.
  ///
  /// The `oldBucket` is provided to the method when the [bucket] getter changes
  /// from non-null to null. The `oldBucket` argument is null when the [bucket]
  /// changes from null to non-null.
  ///
  /// See also:
  ///
  ///  * [restoreState], which is called when the [bucket] changes from one
  ///    non-null value to another non-null value.
  @mustCallSuper
  @protected
  void didToggleBucket(RestorationBucket? oldBucket) {
    // When a bucket is replaced, must `restoreState` is called instead.
    assert(_bucket?.isReplacing != true);
  }

  // Maps properties to their listeners.
  final _properties = <RestorableProperty<Object?>, VoidCallback>{};

  /// Registers a [RestorableProperty] for state restoration.
  ///
  /// The registration associates the provided `property` with the provided
  /// `restorationId`. If restoration data is available for the provided
  /// `restorationId`, the property's value is restored to the value described
  /// by the restoration data. If no restoration data is available, the property
  /// will be initialized to a property-specific default value.
  ///
  /// Each property within a [BaseLayoutController] object must be registered under a unique
  /// ID. Only registered properties will have their values restored during
  /// state restoration.
  ///
  /// Typically, this method is called from within [restoreState] to register
  /// all restorable properties of the owning [BaseLayoutController] object. However, if a
  /// given [RestorableProperty] is only needed when certain conditions are met
  /// within the [BaseLayoutController], [registerForRestoration] may also be called at any
  /// time after [restoreState] has been invoked for the first time.
  ///
  /// A property that has been registered outside of [restoreState] must be
  /// re-registered within [restoreState] the next time that method is called
  /// unless it has been unregistered with [unregisterFromRestoration].
  @protected
  void registerForRestoration(
    RestorableProperty<Object?> property,
    String restorationId,
  ) {
    assert(
      property._restorationId == null ||
          (_debugDoingRestore && property._restorationId == restorationId),
      'Property is already registered under ${property._restorationId}.',
    );
    assert(
      _debugDoingRestore ||
          !_properties.keys
              .map((RestorableProperty<Object?> r) => r._restorationId)
              .contains(restorationId),
      '"$restorationId" is already registered to another property.',
    );
    final bool hasSerializedValue = bucket?.contains(restorationId) ?? false;
    final Object? initialValue = hasSerializedValue
        ? property.fromPrimitives(bucket!.read<Object>(restorationId))
        : property.createDefaultValue();

    if (!property.isRegistered) {
      property._register(restorationId, this);
      void listener() {
        if (bucket == null) {
          return;
        }
        _updateProperty(property);
      }

      property.addListener(listener);
      _properties[property] = listener;
    }

    assert(
      property._restorationId == restorationId &&
          property._owner == this &&
          _properties.containsKey(property),
    );

    property.initWithValue(initialValue);
    if (!hasSerializedValue && property.enabled && bucket != null) {
      _updateProperty(property);
    }

    assert(() {
      _debugPropertiesWaitingForReregistration?.remove(property);
      return true;
    }());
  }

  /// Unregisters a [RestorableProperty] from state restoration.
  ///
  /// The value of the `property` is removed from the restoration data and it
  /// will not be restored if that data is used in a future state restoration.
  ///
  /// Calling this method is uncommon, but may be necessary if the data of a
  /// [RestorableProperty] is only relevant when the [State] object is in a
  /// certain state. When the data of a property is no longer necessary to
  /// restore the internal state of a [State] object, it may be removed from the
  /// restoration data by calling this method.
  @protected
  void unregisterFromRestoration(RestorableProperty<Object?> property) {
    assert(property._owner == this);
    _bucket?.remove<Object?>(property._restorationId!);
    _unregister(property);
  }

  /// Must be called when the value returned by [restorationId] changes.
  ///
  /// This method is automatically called from [didUpdateWidget]. Therefore,
  /// manually invoking this method may be omitted when the change in
  /// [restorationId] was caused by an updated widget.
  @protected
  void didUpdateRestorationId() {
    // There's nothing to do if:
    //  - We don't have a parent to claim a bucket from.
    //  - Our current bucket already uses the provided restoration ID.
    //  - There's a restore pending, which means that didChangeDependencies
    //    will be called and we handle the rename there.
    if (_currentParent == null ||
        _bucket?.restorationId == restorationId ||
        restorePending) {
      return;
    }

    final RestorationBucket? oldBucket = _bucket;
    assert(!restorePending);
    final didReplaceBucket = _updateBucketIfNecessary(
      parent: _currentParent,
      restorePending: false,
    );
    if (didReplaceBucket) {
      assert(oldBucket != _bucket);
      assert(_bucket == null || oldBucket == null);
      oldBucket?.dispose();
    }
  }

  @override
  void didUpdateLayout(covariant UILayout oldWidget) {
    super.didUpdateLayout(oldWidget);

    didUpdateRestorationId();
  }

  /// Whether [restoreState] will be called at the beginning of the next build
  /// phase.
  ///
  /// Returns true when new restoration data has been provided to the mixin, but
  /// the registered [RestorableProperty]s have not been restored to their new
  /// values (as described by the new restoration data) yet. The properties will
  /// get the values restored when [restoreState] is invoked at the beginning of
  /// the next build cycle.
  ///
  /// While this is true, [bucket] will also still return the old bucket with
  /// the old restoration data. It will update to the new bucket with the new
  /// data just before [restoreState] is invoked.
  bool get restorePending {
    if (_firstRestorePending) {
      return true;
    }

    if (restorationId == null) {
      return false;
    }

    final potentialNewParent = RestorationScope.maybeOf(context);

    return potentialNewParent != _currentParent &&
        (potentialNewParent?.isReplacing ?? false);
  }

  List<RestorableProperty<Object?>>? _debugPropertiesWaitingForReregistration;

  bool get _debugDoingRestore =>
      _debugPropertiesWaitingForReregistration != null;

  bool _firstRestorePending = true;
  RestorationBucket? _currentParent;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final RestorationBucket? oldBucket = _bucket;
    final bool needsRestore = restorePending;
    _currentParent = RestorationScope.maybeOf(context);

    final bool didReplaceBucket = _updateBucketIfNecessary(
        parent: _currentParent, restorePending: needsRestore);

    if (needsRestore) {
      _doRestore(oldBucket);
    }
    if (didReplaceBucket) {
      assert(oldBucket != _bucket);
      oldBucket?.dispose();
    }
  }

  void _doRestore(RestorationBucket? oldBucket) {
    assert(() {
      _debugPropertiesWaitingForReregistration = _properties.keys.toList();
      return true;
    }());

    restoreState(oldBucket, _firstRestorePending);
    _firstRestorePending = false;

    assert(() {
      if (_debugPropertiesWaitingForReregistration!.isNotEmpty) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'Previously registered RestorableProperties must be re-registered in "restoreState".',
          ),
          ErrorDescription(
            'The RestorableProperties with the following IDs were not re-registered to $this when '
            '"restoreState" was called:',
          ),
          ..._debugPropertiesWaitingForReregistration!
              .map((RestorableProperty<Object?> property) => ErrorDescription(
                    ' * ${property._restorationId}',
                  )),
        ]);
      }
      _debugPropertiesWaitingForReregistration = null;
      return true;
    }());
  }

  // Returns true if `bucket` has been replaced with a new bucket. It's the
  // responsibility of the caller to dispose the old bucket when this returns true.
  bool _updateBucketIfNecessary({
    required RestorationBucket? parent,
    required bool restorePending,
  }) {
    if (restorationId == null || parent == null) {
      final bool didReplace = _setNewBucketIfNecessary(
          newBucket: null, restorePending: restorePending);
      assert(_bucket == null);
      return didReplace;
    }
    assert(restorationId != null);
    if (restorePending || _bucket == null) {
      final RestorationBucket newBucket =
          parent.claimChild(restorationId!, debugOwner: this);
      final bool didReplace = _setNewBucketIfNecessary(
          newBucket: newBucket, restorePending: restorePending);
      assert(_bucket == newBucket);
      return didReplace;
    }
    // We have an existing bucket, make sure it has the right parent and id.
    assert(_bucket != null);
    assert(!restorePending);
    _bucket!.rename(restorationId!);
    parent.adoptChild(_bucket!);
    return false;
  }

  // Returns true if `bucket` has been replaced with a new bucket. It's the
  // responsibility of the caller to dispose the old bucket when this returns true.
  bool _setNewBucketIfNecessary(
      {required RestorationBucket? newBucket, required bool restorePending}) {
    if (newBucket == _bucket) {
      return false;
    }
    final RestorationBucket? oldBucket = _bucket;
    _bucket = newBucket;
    if (!restorePending) {
      // Write the current property values into the new bucket to persist them.
      if (_bucket != null) {
        _properties.keys.forEach(_updateProperty);
      }
      didToggleBucket(oldBucket);
    }
    return true;
  }

  void _updateProperty(RestorableProperty<Object?> property) {
    if (property.enabled) {
      _bucket?.write(property._restorationId!, property.toPrimitives());
    } else {
      _bucket?.remove<Object>(property._restorationId!);
    }
  }

  void _unregister(RestorableProperty<Object?> property) {
    final VoidCallback listener = _properties.remove(property)!;
    assert(() {
      _debugPropertiesWaitingForReregistration?.remove(property);
      return true;
    }());
    property.removeListener(listener);
    property._unregister();
  }

  @override
  void dispose() {
    _properties
        .forEach((RestorableProperty<Object?> property, VoidCallback listener) {
      if (!property._disposed) {
        property.removeListener(listener);
      }
    });
    _bucket?.dispose();
    _bucket = null;
    super.dispose();
  }
}
*/
