// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fx_rates_dao.dart';

// ignore_for_file: type=lint
mixin _$FxRatesDaoMixin on DatabaseAccessor<AppDatabase> {
  $FxRatesTable get fxRates => attachedDatabase.fxRates;
  FxRatesDaoManager get managers => FxRatesDaoManager(this);
}

class FxRatesDaoManager {
  final _$FxRatesDaoMixin _db;
  FxRatesDaoManager(this._db);
  $$FxRatesTableTableManager get fxRates =>
      $$FxRatesTableTableManager(_db.attachedDatabase, _db.fxRates);
}
