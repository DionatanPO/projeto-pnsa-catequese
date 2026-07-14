import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:http/http.dart' as http;

Future<auth.AutoRefreshingAuthClient> doClientViaUserConsent(
  auth.ClientId clientId,
  List<String> scopes, {
  http.Client? baseClient,
  int listenPort = 0,
}) {
  return auth.clientViaUserConsent(
    clientId,
    scopes,
    (url) => launcher.launchUrl(
      Uri.parse(url),
      mode: launcher.LaunchMode.externalApplication,
    ),
    baseClient: baseClient,
    listenPort: listenPort,
  );
}
