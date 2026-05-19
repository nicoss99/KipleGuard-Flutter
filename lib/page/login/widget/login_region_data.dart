/// Login region codes with display names and flag emoji.
class LoginRegionOption {
  const LoginRegionOption({
    required this.code,
    required this.name,
    required this.flagEmoji,
  });

  final String code;
  final String name;
  final String flagEmoji;
}

const loginRegionOptionsList = <LoginRegionOption>[
  LoginRegionOption(code: 'MY', name: 'Malaysia', flagEmoji: '🇲🇾'),
  LoginRegionOption(code: 'ID', name: 'Indonesia', flagEmoji: '🇮🇩'),
  LoginRegionOption(code: 'VN', name: 'Vietnam', flagEmoji: '🇻🇳'),
];

const loginRegionOptions = <String, String>{
  'MY': 'Malaysia',
  'ID': 'Indonesia',
  'VN': 'Vietnam',
};

LoginRegionOption? loginRegionByCode(String? code) {
  if (code == null || code.isEmpty) return null;
  for (final o in loginRegionOptionsList) {
    if (o.code == code) return o;
  }
  return null;
}
