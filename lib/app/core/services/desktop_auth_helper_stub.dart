import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;

Future<auth.AutoRefreshingAuthClient> doClientViaUserConsent(
  auth.ClientId clientId,
  List<String> scopes, {
  http.Client? baseClient,
  int listenPort = 0,
}) {
  throw UnsupportedError('Desktop auth not available on web');
}
