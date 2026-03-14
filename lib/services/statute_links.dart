/// Maps statute references from flashcards to legislation.gov.uk URLs
class StatuteLinks {
  static String? getUrl(String statute) {
    final s = statute.toLowerCase().trim();

    // ── Theft Act 1968 ──
    if (s.contains('theft act 1968')) {
      return _theftAct1968(s);
    }

    // ── Theft Act 1978 ──
    if (s.contains('theft act 1978')) {
      return 'https://www.legislation.gov.uk/ukpga/1978/31';
    }

    // ── Fraud Act 2006 ──
    if (s.contains('fraud act 2006')) {
      return _buildUrl('ukpga/2006/35', s);
    }

    // ── OAPA 1861 ──
    if (s.contains('oapa 1861') || s.contains('offences against the person act 1861')) {
      return _oapa1861(s);
    }

    // ── CJA 1988 ──
    if (s.contains('cja 1988') || s.contains('criminal justice act 1988')) {
      return _buildUrl('ukpga/1988/33', s);
    }

    // ── Public Order Act 1986 ──
    if (s.contains('poa 1986') || s.contains('public order act 1986')) {
      return _buildUrl('ukpga/1986/64', s);
    }

    // ── Public Order Act 2023 ──
    if (s.contains('poa 2023') || s.contains('public order act 2023')) {
      return _buildUrl('ukpga/2023/15', s);
    }

    // ── Crime and Courts Act 2013 ──
    if (s.contains('crime and courts act 2013')) {
      return 'https://www.legislation.gov.uk/ukpga/2013/22';
    }

    // ── ASBCPA 2014 ──
    if (s.contains('asbcpa 2014') || s.contains('anti-social behaviour')) {
      return _buildUrl('ukpga/2014/12', s);
    }

    // ── Protection from Harassment Act 1997 ──
    if (s.contains('pha 1997') || s.contains('protection from harassment')) {
      return _buildUrl('ukpga/1997/40', s);
    }

    // ── Stalking Protection Act 2019 ──
    if (s.contains('stalking protection act 2019') || s.contains('spa 2019')) {
      return 'https://www.legislation.gov.uk/ukpga/2019/9';
    }

    // ── Serious Crime Act 2015 ──
    if (s.contains('sca 2015') || s.contains('serious crime act 2015')) {
      return _buildUrl('ukpga/2015/9', s);
    }

    // ── Crime and Security Act 2010 ──
    if (s.contains('crime and security act 2010')) {
      return 'https://www.legislation.gov.uk/ukpga/2010/17';
    }

    // ── Family Law Act 1996 ──
    if (s.contains('fla 1996') || s.contains('family law act 1996')) {
      return 'https://www.legislation.gov.uk/ukpga/1996/27';
    }

    // ── PACE 1984 ──
    if (s.contains('pace 1984') || s.contains('pace')) {
      return _pace1984(s);
    }

    // ── Criminal Damage Act 1971 ──
    if (s.contains('cda 1971') || s.contains('criminal damage act 1971')) {
      return _buildUrl('ukpga/1971/48', s);
    }

    // ── Air Navigation Order 2016 ──
    if (s.contains('ano 2016') || s.contains('air navigation order')) {
      return 'https://www.legislation.gov.uk/uksi/2016/765';
    }

    // ── ATMUA Act 2021 ──
    if (s.contains('atmua') || s.contains('air traffic management')) {
      return 'https://www.legislation.gov.uk/ukpga/2021/12';
    }

    // ── Assaults on Emergency Workers 2018 ──
    if (s.contains('aew') || s.contains('emergency workers')) {
      return 'https://www.legislation.gov.uk/ukpga/2018/23';
    }

    // ── PCSC Act 2022 ──
    if (s.contains('pcsc act 2022')) {
      return 'https://www.legislation.gov.uk/ukpga/2022/32';
    }

    return null;
  }

  static String? _theftAct1968(String s) {
    final sectionNum = _extractSection(s);
    if (sectionNum != null) {
      return 'https://www.legislation.gov.uk/ukpga/1968/60/section/$sectionNum';
    }
    return 'https://www.legislation.gov.uk/ukpga/1968/60';
  }

  static String? _oapa1861(String s) {
    final sectionNum = _extractSection(s);
    if (sectionNum != null) {
      return 'https://www.legislation.gov.uk/ukpga/Vict/24-25/100/section/$sectionNum';
    }
    return 'https://www.legislation.gov.uk/ukpga/Vict/24-25/100';
  }

  static String? _pace1984(String s) {
    final sectionNum = _extractSection(s);
    if (sectionNum != null) {
      return 'https://www.legislation.gov.uk/ukpga/1984/60/section/$sectionNum';
    }
    return 'https://www.legislation.gov.uk/ukpga/1984/60';
  }

  static String _buildUrl(String actPath, String s) {
    final sectionNum = _extractSection(s);
    if (sectionNum != null) {
      return 'https://www.legislation.gov.uk/$actPath/section/$sectionNum';
    }
    return 'https://www.legislation.gov.uk/$actPath';
  }

  /// Extracts the first section number from a statute string
  /// e.g. "Theft Act 1968, s.8(1)" -> "8"
  /// e.g. "PACE 1984, s.24(1)-(3)" -> "24"
  /// e.g. "OAPA 1861, s.47" -> "47"
  static String? _extractSection(String s) {
    // Match patterns like s.24, s24, s.1(1), s.41-44
    final regex = RegExp(r's\.?(\d+)');
    final match = regex.firstMatch(s);
    if (match != null) {
      return match.group(1);
    }
    return null;
  }
}
