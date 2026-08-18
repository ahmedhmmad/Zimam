import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;

import '../domain/parser_rule.dart';

/// Loads the parser rules, from the bundled asset and optionally from an
/// update published alongside the source.
///
/// The bundled pack is the floor: capture works on a fresh install with no
/// network, forever, and a downloaded pack only ever *replaces* it when it
/// claims a higher version. A rollback upstream therefore cannot downgrade a
/// working app, and an unreachable host cannot break one.
final class RulePackRepository {
  RulePackRepository({HttpClient? httpClient, this.timeout = _defaultTimeout})
    : _httpClient = httpClient ?? HttpClient();

  static const _defaultTimeout = Duration(seconds: 15);

  /// Where the app looks for rule updates.
  ///
  /// **This is the second and last outbound call in the app**, after the FX
  /// rates. It is a plain GET of a public file in the project's own
  /// repository: no query string, no headers identifying the device, no body,
  /// and nothing about the user or their notifications is sent. Serving the
  /// rules from the repo means they are versioned and reviewable in the same
  /// place as the code that uses them.
  static const String endpoint =
      'https://raw.githubusercontent.com/ahmedhmmad/Zimam/main/'
      'assets/parser_rules/rules.json';

  static const String assetPath = 'assets/parser_rules/rules.json';

  final HttpClient _httpClient;
  final Duration timeout;

  /// The pack shipped inside the app.
  Future<ParserRulePack> loadBundled() async {
    final raw = await rootBundle.loadString(assetPath);
    return _decode(raw);
  }

  /// Fetches an updated pack, or returns null.
  ///
  /// Null covers every failure — offline, a bad response, malformed JSON, a
  /// pack that is not newer. None of them are errors worth surfacing: the
  /// bundled rules are still there and capture keeps working.
  Future<ParserRulePack?> fetchUpdate({required int currentVersion}) async {
    final String body;
    try {
      final request = await _httpClient
          .getUrl(Uri.parse(endpoint))
          .timeout(timeout);
      final response = await request.close().timeout(timeout);
      if (response.statusCode != 200) return null;
      body = await response.transform(utf8.decoder).join();
    } on Object {
      return null;
    }

    final ParserRulePack pack;
    try {
      pack = _decode(body);
    } on Object {
      // A malformed or hostile pack must not be able to break parsing. Every
      // rule is validated on the way in and the whole pack is discarded if
      // any part of it is unusable.
      return null;
    }

    if (pack.version <= currentVersion) return null;
    if (pack.rules.isEmpty) return null;
    return pack;
  }

  static ParserRulePack _decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const ParserRuleFormatException('Pack is not a JSON object');
    }
    return ParserRulePack.fromJson(decoded);
  }

  void close() => _httpClient.close(force: true);
}
