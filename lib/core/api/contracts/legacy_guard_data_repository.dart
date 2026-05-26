/// Legacy `data/kg_guards` PIN list (Android RetrofitListAPI).
abstract interface class LegacyGuardDataRepository {
  Future<String> fetchGuardPinJson(String securityCompanyUuid);

  String trimGuardPinPayload(String responseString);
}
