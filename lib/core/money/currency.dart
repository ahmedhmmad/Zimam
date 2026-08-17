/// An ISO 4217 currency and, crucially, how many decimal places it has.
///
/// The decimal count is not cosmetic. It defines what a minor unit *is*, so
/// getting it wrong corrupts stored amounts rather than merely mis-displaying
/// them: 1000 minor units is 10.00 USD, 1.000 JOD, or 1000 JPY. Any code that
/// stores or reads an amount must go through [Currency] to know the scale.
final class Currency implements Comparable<Currency> {
  const Currency({
    required this.code,
    required this.decimalDigits,
    required this.englishName,
  });

  /// ISO 4217 alphabetic code, uppercase. `JOD`, `USD`, `JPY`.
  final String code;

  /// ISO 4217 minor unit exponent. Almost always 2, but not always — see
  /// [CurrencyRegistry] for the exceptions that make this field necessary.
  final int decimalDigits;

  /// Untranslated name, for debugging and as a fallback. User-facing currency
  /// names are localised separately; this is not display copy.
  final String englishName;

  /// 10^[decimalDigits] — how many minor units make one major unit.
  int get minorUnitsPerMajor {
    var factor = 1;
    for (var i = 0; i < decimalDigits; i++) {
      factor *= 10;
    }
    return factor;
  }

  @override
  int compareTo(Currency other) => code.compareTo(other.code);

  @override
  bool operator ==(Object other) => other is Currency && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => code;
}

/// Thrown when a currency code is not in the registry.
class UnknownCurrencyException implements Exception {
  const UnknownCurrencyException(this.code);
  final String code;
  @override
  String toString() => 'UnknownCurrencyException: "$code" is not ISO 4217';
}

/// The set of currencies the app understands.
///
/// Covers the active ISO 4217 list. The entries that matter most here are the
/// ones that are *not* two decimal places, because a two-decimal assumption is
/// the single most likely way to corrupt a cross-border balance:
///
/// * **Three places** — BHD, IQD, JOD, KWD, LYD, OMR, TND. Gulf and North
///   African currencies, squarely in this app's audience.
/// * **Zero places** — JPY, KRW, VND, ISK, CLP, PYG, UGX, RWF, and the CFA
///   francs. A "cents" field for these is meaningless.
/// * **Four places** — CLF and UYW, both inflation-indexed accounting units.
abstract final class CurrencyRegistry {
  /// Every known currency, keyed by uppercase ISO 4217 code.
  static const Map<String, Currency> byCode = {
    'AED': Currency(
      code: 'AED',
      decimalDigits: 2,
      englishName: 'UAE Dirham',
    ),
    'AFN': Currency(code: 'AFN', decimalDigits: 2, englishName: 'Afghani'),
    'ALL': Currency(code: 'ALL', decimalDigits: 2, englishName: 'Lek'),
    'AMD': Currency(code: 'AMD', decimalDigits: 2, englishName: 'Armenian Dram'),
    'ANG': Currency(
      code: 'ANG',
      decimalDigits: 2,
      englishName: 'Netherlands Antillean Guilder',
    ),
    'AOA': Currency(code: 'AOA', decimalDigits: 2, englishName: 'Kwanza'),
    'ARS': Currency(code: 'ARS', decimalDigits: 2, englishName: 'Argentine Peso'),
    'AUD': Currency(
      code: 'AUD',
      decimalDigits: 2,
      englishName: 'Australian Dollar',
    ),
    'AWG': Currency(code: 'AWG', decimalDigits: 2, englishName: 'Aruban Florin'),
    'AZN': Currency(
      code: 'AZN',
      decimalDigits: 2,
      englishName: 'Azerbaijan Manat',
    ),
    'BAM': Currency(
      code: 'BAM',
      decimalDigits: 2,
      englishName: 'Convertible Mark',
    ),
    'BBD': Currency(
      code: 'BBD',
      decimalDigits: 2,
      englishName: 'Barbados Dollar',
    ),
    'BDT': Currency(code: 'BDT', decimalDigits: 2, englishName: 'Taka'),
    'BGN': Currency(code: 'BGN', decimalDigits: 2, englishName: 'Bulgarian Lev'),
    // Three decimal places.
    'BHD': Currency(code: 'BHD', decimalDigits: 3, englishName: 'Bahraini Dinar'),
    // Zero decimal places.
    'BIF': Currency(code: 'BIF', decimalDigits: 0, englishName: 'Burundi Franc'),
    'BMD': Currency(
      code: 'BMD',
      decimalDigits: 2,
      englishName: 'Bermudian Dollar',
    ),
    'BND': Currency(code: 'BND', decimalDigits: 2, englishName: 'Brunei Dollar'),
    'BOB': Currency(code: 'BOB', decimalDigits: 2, englishName: 'Boliviano'),
    'BRL': Currency(code: 'BRL', decimalDigits: 2, englishName: 'Brazilian Real'),
    'BSD': Currency(
      code: 'BSD',
      decimalDigits: 2,
      englishName: 'Bahamian Dollar',
    ),
    'BTN': Currency(code: 'BTN', decimalDigits: 2, englishName: 'Ngultrum'),
    'BWP': Currency(code: 'BWP', decimalDigits: 2, englishName: 'Pula'),
    'BYN': Currency(
      code: 'BYN',
      decimalDigits: 2,
      englishName: 'Belarusian Ruble',
    ),
    'BZD': Currency(code: 'BZD', decimalDigits: 2, englishName: 'Belize Dollar'),
    'CAD': Currency(
      code: 'CAD',
      decimalDigits: 2,
      englishName: 'Canadian Dollar',
    ),
    'CDF': Currency(
      code: 'CDF',
      decimalDigits: 2,
      englishName: 'Congolese Franc',
    ),
    'CHF': Currency(code: 'CHF', decimalDigits: 2, englishName: 'Swiss Franc'),
    // Four decimal places, an inflation-indexed unit of account.
    'CLF': Currency(
      code: 'CLF',
      decimalDigits: 4,
      englishName: 'Unidad de Fomento',
    ),
    'CLP': Currency(code: 'CLP', decimalDigits: 0, englishName: 'Chilean Peso'),
    'CNY': Currency(code: 'CNY', decimalDigits: 2, englishName: 'Yuan Renminbi'),
    'COP': Currency(code: 'COP', decimalDigits: 2, englishName: 'Colombian Peso'),
    'CRC': Currency(code: 'CRC', decimalDigits: 2, englishName: 'Costa Rican Colon'),
    'CUP': Currency(code: 'CUP', decimalDigits: 2, englishName: 'Cuban Peso'),
    'CVE': Currency(code: 'CVE', decimalDigits: 2, englishName: 'Cabo Verde Escudo'),
    'CZK': Currency(code: 'CZK', decimalDigits: 2, englishName: 'Czech Koruna'),
    'DJF': Currency(code: 'DJF', decimalDigits: 0, englishName: 'Djibouti Franc'),
    'DKK': Currency(code: 'DKK', decimalDigits: 2, englishName: 'Danish Krone'),
    'DOP': Currency(code: 'DOP', decimalDigits: 2, englishName: 'Dominican Peso'),
    'DZD': Currency(code: 'DZD', decimalDigits: 2, englishName: 'Algerian Dinar'),
    'EGP': Currency(code: 'EGP', decimalDigits: 2, englishName: 'Egyptian Pound'),
    'ERN': Currency(code: 'ERN', decimalDigits: 2, englishName: 'Nakfa'),
    'ETB': Currency(code: 'ETB', decimalDigits: 2, englishName: 'Ethiopian Birr'),
    'EUR': Currency(code: 'EUR', decimalDigits: 2, englishName: 'Euro'),
    'FJD': Currency(code: 'FJD', decimalDigits: 2, englishName: 'Fiji Dollar'),
    'FKP': Currency(code: 'FKP', decimalDigits: 2, englishName: 'Falkland Islands Pound'),
    'GBP': Currency(code: 'GBP', decimalDigits: 2, englishName: 'Pound Sterling'),
    'GEL': Currency(code: 'GEL', decimalDigits: 2, englishName: 'Lari'),
    'GHS': Currency(code: 'GHS', decimalDigits: 2, englishName: 'Ghana Cedi'),
    'GIP': Currency(code: 'GIP', decimalDigits: 2, englishName: 'Gibraltar Pound'),
    'GMD': Currency(code: 'GMD', decimalDigits: 2, englishName: 'Dalasi'),
    'GNF': Currency(code: 'GNF', decimalDigits: 0, englishName: 'Guinean Franc'),
    'GTQ': Currency(code: 'GTQ', decimalDigits: 2, englishName: 'Quetzal'),
    'GYD': Currency(code: 'GYD', decimalDigits: 2, englishName: 'Guyana Dollar'),
    'HKD': Currency(code: 'HKD', decimalDigits: 2, englishName: 'Hong Kong Dollar'),
    'HNL': Currency(code: 'HNL', decimalDigits: 2, englishName: 'Lempira'),
    'HTG': Currency(code: 'HTG', decimalDigits: 2, englishName: 'Gourde'),
    'HUF': Currency(code: 'HUF', decimalDigits: 2, englishName: 'Forint'),
    'IDR': Currency(code: 'IDR', decimalDigits: 2, englishName: 'Rupiah'),
    'ILS': Currency(code: 'ILS', decimalDigits: 2, englishName: 'New Israeli Sheqel'),
    'INR': Currency(code: 'INR', decimalDigits: 2, englishName: 'Indian Rupee'),
    'IQD': Currency(code: 'IQD', decimalDigits: 3, englishName: 'Iraqi Dinar'),
    'IRR': Currency(code: 'IRR', decimalDigits: 2, englishName: 'Iranian Rial'),
    'ISK': Currency(code: 'ISK', decimalDigits: 0, englishName: 'Iceland Krona'),
    'JMD': Currency(code: 'JMD', decimalDigits: 2, englishName: 'Jamaican Dollar'),
    'JOD': Currency(code: 'JOD', decimalDigits: 3, englishName: 'Jordanian Dinar'),
    'JPY': Currency(code: 'JPY', decimalDigits: 0, englishName: 'Yen'),
    'KES': Currency(code: 'KES', decimalDigits: 2, englishName: 'Kenyan Shilling'),
    'KGS': Currency(code: 'KGS', decimalDigits: 2, englishName: 'Som'),
    'KHR': Currency(code: 'KHR', decimalDigits: 2, englishName: 'Riel'),
    'KMF': Currency(code: 'KMF', decimalDigits: 0, englishName: 'Comorian Franc'),
    'KPW': Currency(code: 'KPW', decimalDigits: 2, englishName: 'North Korean Won'),
    'KRW': Currency(code: 'KRW', decimalDigits: 0, englishName: 'Won'),
    'KWD': Currency(code: 'KWD', decimalDigits: 3, englishName: 'Kuwaiti Dinar'),
    'KYD': Currency(code: 'KYD', decimalDigits: 2, englishName: 'Cayman Islands Dollar'),
    'KZT': Currency(code: 'KZT', decimalDigits: 2, englishName: 'Tenge'),
    'LAK': Currency(code: 'LAK', decimalDigits: 2, englishName: 'Lao Kip'),
    'LBP': Currency(code: 'LBP', decimalDigits: 2, englishName: 'Lebanese Pound'),
    'LKR': Currency(code: 'LKR', decimalDigits: 2, englishName: 'Sri Lanka Rupee'),
    'LRD': Currency(code: 'LRD', decimalDigits: 2, englishName: 'Liberian Dollar'),
    'LSL': Currency(code: 'LSL', decimalDigits: 2, englishName: 'Loti'),
    'LYD': Currency(code: 'LYD', decimalDigits: 3, englishName: 'Libyan Dinar'),
    'MAD': Currency(code: 'MAD', decimalDigits: 2, englishName: 'Moroccan Dirham'),
    'MDL': Currency(code: 'MDL', decimalDigits: 2, englishName: 'Moldovan Leu'),
    'MGA': Currency(code: 'MGA', decimalDigits: 2, englishName: 'Malagasy Ariary'),
    'MKD': Currency(code: 'MKD', decimalDigits: 2, englishName: 'Denar'),
    'MMK': Currency(code: 'MMK', decimalDigits: 2, englishName: 'Kyat'),
    'MNT': Currency(code: 'MNT', decimalDigits: 2, englishName: 'Tugrik'),
    'MOP': Currency(code: 'MOP', decimalDigits: 2, englishName: 'Pataca'),
    'MRU': Currency(code: 'MRU', decimalDigits: 2, englishName: 'Ouguiya'),
    'MUR': Currency(code: 'MUR', decimalDigits: 2, englishName: 'Mauritius Rupee'),
    'MVR': Currency(code: 'MVR', decimalDigits: 2, englishName: 'Rufiyaa'),
    'MWK': Currency(code: 'MWK', decimalDigits: 2, englishName: 'Malawi Kwacha'),
    'MXN': Currency(code: 'MXN', decimalDigits: 2, englishName: 'Mexican Peso'),
    'MYR': Currency(code: 'MYR', decimalDigits: 2, englishName: 'Malaysian Ringgit'),
    'MZN': Currency(code: 'MZN', decimalDigits: 2, englishName: 'Mozambique Metical'),
    'NAD': Currency(code: 'NAD', decimalDigits: 2, englishName: 'Namibia Dollar'),
    'NGN': Currency(code: 'NGN', decimalDigits: 2, englishName: 'Naira'),
    'NIO': Currency(code: 'NIO', decimalDigits: 2, englishName: 'Cordoba Oro'),
    'NOK': Currency(code: 'NOK', decimalDigits: 2, englishName: 'Norwegian Krone'),
    'NPR': Currency(code: 'NPR', decimalDigits: 2, englishName: 'Nepalese Rupee'),
    'NZD': Currency(code: 'NZD', decimalDigits: 2, englishName: 'New Zealand Dollar'),
    'OMR': Currency(code: 'OMR', decimalDigits: 3, englishName: 'Rial Omani'),
    'PAB': Currency(code: 'PAB', decimalDigits: 2, englishName: 'Balboa'),
    'PEN': Currency(code: 'PEN', decimalDigits: 2, englishName: 'Sol'),
    'PGK': Currency(code: 'PGK', decimalDigits: 2, englishName: 'Kina'),
    'PHP': Currency(code: 'PHP', decimalDigits: 2, englishName: 'Philippine Peso'),
    'PKR': Currency(code: 'PKR', decimalDigits: 2, englishName: 'Pakistan Rupee'),
    'PLN': Currency(code: 'PLN', decimalDigits: 2, englishName: 'Zloty'),
    'PYG': Currency(code: 'PYG', decimalDigits: 0, englishName: 'Guarani'),
    'QAR': Currency(code: 'QAR', decimalDigits: 2, englishName: 'Qatari Rial'),
    'RON': Currency(code: 'RON', decimalDigits: 2, englishName: 'Romanian Leu'),
    'RSD': Currency(code: 'RSD', decimalDigits: 2, englishName: 'Serbian Dinar'),
    'RUB': Currency(code: 'RUB', decimalDigits: 2, englishName: 'Russian Ruble'),
    'RWF': Currency(code: 'RWF', decimalDigits: 0, englishName: 'Rwanda Franc'),
    'SAR': Currency(code: 'SAR', decimalDigits: 2, englishName: 'Saudi Riyal'),
    'SBD': Currency(code: 'SBD', decimalDigits: 2, englishName: 'Solomon Islands Dollar'),
    'SCR': Currency(code: 'SCR', decimalDigits: 2, englishName: 'Seychelles Rupee'),
    'SDG': Currency(code: 'SDG', decimalDigits: 2, englishName: 'Sudanese Pound'),
    'SEK': Currency(code: 'SEK', decimalDigits: 2, englishName: 'Swedish Krona'),
    'SGD': Currency(code: 'SGD', decimalDigits: 2, englishName: 'Singapore Dollar'),
    'SHP': Currency(code: 'SHP', decimalDigits: 2, englishName: 'Saint Helena Pound'),
    'SLE': Currency(code: 'SLE', decimalDigits: 2, englishName: 'Leone'),
    'SOS': Currency(code: 'SOS', decimalDigits: 2, englishName: 'Somali Shilling'),
    'SRD': Currency(code: 'SRD', decimalDigits: 2, englishName: 'Surinam Dollar'),
    'SSP': Currency(code: 'SSP', decimalDigits: 2, englishName: 'South Sudanese Pound'),
    'STN': Currency(code: 'STN', decimalDigits: 2, englishName: 'Dobra'),
    'SVC': Currency(code: 'SVC', decimalDigits: 2, englishName: 'El Salvador Colon'),
    'SYP': Currency(code: 'SYP', decimalDigits: 2, englishName: 'Syrian Pound'),
    'SZL': Currency(code: 'SZL', decimalDigits: 2, englishName: 'Lilangeni'),
    'THB': Currency(code: 'THB', decimalDigits: 2, englishName: 'Baht'),
    'TJS': Currency(code: 'TJS', decimalDigits: 2, englishName: 'Somoni'),
    'TMT': Currency(code: 'TMT', decimalDigits: 2, englishName: 'Turkmenistan New Manat'),
    'TND': Currency(code: 'TND', decimalDigits: 3, englishName: 'Tunisian Dinar'),
    'TOP': Currency(code: 'TOP', decimalDigits: 2, englishName: "Pa'anga"),
    'TRY': Currency(code: 'TRY', decimalDigits: 2, englishName: 'Turkish Lira'),
    'TTD': Currency(code: 'TTD', decimalDigits: 2, englishName: 'Trinidad and Tobago Dollar'),
    'TWD': Currency(code: 'TWD', decimalDigits: 2, englishName: 'New Taiwan Dollar'),
    'TZS': Currency(code: 'TZS', decimalDigits: 2, englishName: 'Tanzanian Shilling'),
    'UAH': Currency(code: 'UAH', decimalDigits: 2, englishName: 'Hryvnia'),
    'UGX': Currency(code: 'UGX', decimalDigits: 0, englishName: 'Uganda Shilling'),
    'USD': Currency(code: 'USD', decimalDigits: 2, englishName: 'US Dollar'),
    'UYU': Currency(code: 'UYU', decimalDigits: 2, englishName: 'Peso Uruguayo'),
    'UYW': Currency(code: 'UYW', decimalDigits: 4, englishName: 'Unidad Previsional'),
    'UZS': Currency(code: 'UZS', decimalDigits: 2, englishName: 'Uzbekistan Sum'),
    'VES': Currency(code: 'VES', decimalDigits: 2, englishName: 'Bolivar Soberano'),
    'VND': Currency(code: 'VND', decimalDigits: 0, englishName: 'Dong'),
    'VUV': Currency(code: 'VUV', decimalDigits: 0, englishName: 'Vatu'),
    'WST': Currency(code: 'WST', decimalDigits: 2, englishName: 'Tala'),
    'XAF': Currency(code: 'XAF', decimalDigits: 0, englishName: 'CFA Franc BEAC'),
    'XCD': Currency(code: 'XCD', decimalDigits: 2, englishName: 'East Caribbean Dollar'),
    'XOF': Currency(code: 'XOF', decimalDigits: 0, englishName: 'CFA Franc BCEAO'),
    'XPF': Currency(code: 'XPF', decimalDigits: 0, englishName: 'CFP Franc'),
    'YER': Currency(code: 'YER', decimalDigits: 2, englishName: 'Yemeni Rial'),
    'ZAR': Currency(code: 'ZAR', decimalDigits: 2, englishName: 'Rand'),
    'ZMW': Currency(code: 'ZMW', decimalDigits: 2, englishName: 'Zambian Kwacha'),
    'ZWG': Currency(code: 'ZWG', decimalDigits: 2, englishName: 'Zimbabwe Gold'),
  };

  /// Looks up [code], case-insensitively.
  ///
  /// Throws [UnknownCurrencyException] rather than returning null: an unknown
  /// code reaching this point means a corrupt row or a bad parse, and silently
  /// substituting a default would put a wrong number in front of the user.
  static Currency of(String code) {
    final currency = byCode[code.toUpperCase()];
    if (currency == null) throw UnknownCurrencyException(code);
    return currency;
  }

  /// Looks up [code], returning null when it is not known. For validating
  /// user or parser input, where absence is an expected outcome.
  static Currency? tryOf(String code) => byCode[code.toUpperCase()];

  static bool isKnown(String code) => byCode.containsKey(code.toUpperCase());

  /// All currencies, ordered by code. The Phase 2 picker reads this.
  static List<Currency> get all =>
      byCode.values.toList(growable: false)..sort();
}
