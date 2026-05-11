/// Android [LoginActivity] uses [FirebaseMessaging.getInstance().token] (or a random
/// UUID if token retrieval fails). Wire [firebase_messaging] here when Firebase is
/// configured for this app; until then the API accepts an empty string (see session flow).
Future<String> readLoginFirebaseMessagingToken() async {
  return '';
}
