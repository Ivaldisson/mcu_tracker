// Template voor lokale API-sleutels. Kopieer dit bestand naar
// `api_keys.dart` (in .gitignore, komt dus nooit in git terecht) en vul je
// eigen sleutels in.
class ApiKeys {
  // Moet exact matchen met de API_KEY environment variable op de mcuapi-LXC
  // server (zie docker-compose.yml daar).
  static const String mcuApiKey = 'YOUR_MCUAPI_X_API_KEY';

  // TMDB API Read Access Token (v4 auth), te vinden op
  // https://www.themoviedb.org/settings/api.
  static const String tmdbReadAccessToken = 'YOUR_TMDB_READ_ACCESS_TOKEN';
}
