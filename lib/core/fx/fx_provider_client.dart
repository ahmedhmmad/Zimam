import 'dart:convert';
import 'dart:io';

import '../money/currency.dart';
import 'fx_rate.dart';

/// Thrown when rates cannot be fetched. Always recoverable: the caller falls
/// back to the cache, because the app has to work with no network at all.
class FxFetchException implements Exception {
  const FxFetchException(this.message, {this.cause});
  final String message;
  final Object? cause;
  @override
  String toString() => 'FxFetchException: $message';
}

/// Fetches daily rates from a remote provider.
///
/// An interface, not just an implementation detail: it is the seam that lets
/// every test run without a network, and it keeps the single outbound call in
/// the app behind one named type that is easy to audit.
abstract interface class FxProviderClient {
  /// All rates quoted against [base], for the provider's latest day.
  Future<List<FxRate>> fetchLatest(Currency base);
}

/// The app's rate source.
///
/// **This is one of only two network calls the app makes**, the other being
/// the Phase 5 parser rule pack. It sends nothing but a currency code — no
/// balances, no account names, no identifiers of any kind — and the app
/// functions fully without it, from cache.
///
/// Provider: `open.er-api.com`, chosen because it covers the currencies this
/// app exists for. The obvious alternative, the ECB-backed Frankfurter API,
/// publishes 29 rates and carries none of JOD, AED, EGP, KWD, BHD, SAR, TND,
/// OMR or IQD — which would make the app useless to most of its audience.
///
/// Attribution: the free tier is CC-BY-SA and requires crediting the source.
/// That credit is shown in Settings; do not remove it.
final class OpenErApiClient implements FxProviderClient {
  OpenErApiClient({HttpClient? httpClient, this.timeout = _defaultTimeout})
    : _httpClient = httpClient ?? HttpClient();

  static const _defaultTimeout = Duration(seconds: 15);

  /// The single endpoint this app talks to for rates.
  static const String endpoint = 'https://open.er-api.com/v6/latest';

  /// Shown in Settings to satisfy the provider's licence.
  static const String attribution = 'Rates by ExchangeRate-API '
      '(open.er-api.com), CC BY-SA 4.0';

  final HttpClient _httpClient;
  final Duration timeout;

  @override
  Future<List<FxRate>> fetchLatest(Currency base) async {
    final uri = Uri.parse('$endpoint/${base.code}');

    late final HttpClientResponse response;
    try {
      final request = await _httpClient.getUrl(uri).timeout(timeout);
      response = await request.close().timeout(timeout);
    } on Object catch (e) {
      // Offline, DNS failure, timeout — all the same to the caller, which
      // falls back to cache regardless.
      throw FxFetchException('Could not reach the rate provider', cause: e);
    }

    if (response.statusCode != 200) {
      throw FxFetchException('Rate provider returned ${response.statusCode}');
    }

    final body = await response.transform(utf8.decoder).join();
    return _parse(body, base);
  }

  List<FxRate> _parse(String body, Currency base) {
    final Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException catch (e) {
      throw FxFetchException('Rate provider returned malformed JSON', cause: e);
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FxFetchException('Unexpected response shape');
    }
    if (decoded['result'] == 'error') {
      throw FxFetchException(
        'Rate provider error: ${decoded['error-type'] ?? 'unknown'}',
      );
    }

    final rates = decoded['rates'];
    if (rates is! Map<String, dynamic>) {
      throw const FxFetchException('Response contained no rates');
    }

    final fetchedAt = DateTime.now().toUtc();
    final rateDate = _rateDate(decoded, fetchedAt);

    final parsed = <FxRate>[];
    for (final entry in rates.entries) {
      final quote = CurrencyRegistry.tryOf(entry.key);
      // Providers quote metals and defunct codes the registry does not carry.
      // Skipping them is correct: an unknown code has no decimal scale, so
      // there is no safe way to store an amount in it.
      if (quote == null || quote == base) continue;

      final value = entry.value;
      final text = value is num ? value.toString() : value?.toString();
      if (text == null) continue;
      try {
        parsed.add(
          FxRate.parse(
            base: base,
            quote: quote,
            rate: text,
            rateDate: rateDate,
            fetchedAt: fetchedAt,
          ),
        );
      } on FormatException {
        continue; // One bad rate must not discard the whole payload.
      }
    }

    if (parsed.isEmpty) {
      throw const FxFetchException('No usable rates in response');
    }
    return parsed;
  }

  /// The day the rates are for, normalised to UTC midnight.
  ///
  /// Falls back to today if the provider omits or mangles the field, since a
  /// rate with a plausible date is more useful than no rate.
  DateTime _rateDate(Map<String, dynamic> body, DateTime fetchedAt) {
    final seconds = body['time_last_update_unix'];
    if (seconds is int) {
      final moment = DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000,
        isUtc: true,
      );
      return DateTime.utc(moment.year, moment.month, moment.day);
    }
    return DateTime.utc(fetchedAt.year, fetchedAt.month, fetchedAt.day);
  }

  void close() => _httpClient.close(force: true);
}
