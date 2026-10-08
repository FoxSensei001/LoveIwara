/// Canonical HTTP proxy endpoint shared by the editor and its connection test.
/// Stored as host:port because both startup proxy consumers expect that form.
String? normalizeHttpProxyAddress(String value) {
  // Parse the explicit port ourselves: Uri drops an explicit :80 for HTTP.
  // Limit hosts to the IPv4/domain forms supported by both startup consumers.
  final match = RegExp(
    r'^(?:http://)?([a-zA-Z0-9](?:[a-zA-Z0-9._-]*[a-zA-Z0-9])?):([0-9]{1,5})/?$',
    caseSensitive: false,
  ).firstMatch(value.trim());
  if (match == null) return null;
  final port = int.tryParse(match.group(2)!);
  if (port == null || port < 1 || port > 65535) return null;
  return '${match.group(1)!.toLowerCase()}:$port';
}

/// Windows can report protocol-specific entries. HTTP CONNECT also handles the
/// HTTPS entry, but a SOCKS-only entry must never be presented as an HTTP URL.
String? preferredHttpProxyAddress(String server) {
  if (!server.contains('=')) return normalizeHttpProxyAddress(server);
  final entries = <String, String>{};
  for (final part in server.split(';')) {
    final separator = part.indexOf('=');
    if (separator < 0) continue;
    entries[part.substring(0, separator).trim().toLowerCase()] = part
        .substring(separator + 1)
        .trim();
  }
  for (final key in ['http', 'https']) {
    final candidate = entries[key];
    if (candidate == null) continue;
    final address = normalizeHttpProxyAddress(candidate);
    if (address != null) return address;
  }
  return null;
}
