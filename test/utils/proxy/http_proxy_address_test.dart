import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/utils/proxy/http_proxy_address.dart';

void main() {
  test('system candidates retain the HTTP protocol requirement', () {
    expect(preferredHttpProxyAddress('socks=127.0.0.1:1080'), isNull);
    expect(preferredHttpProxyAddress('socks5://127.0.0.1:1080'), isNull);
    expect(
      preferredHttpProxyAddress('http://user:pass@localhost:7890'),
      isNull,
    );
    expect(
      preferredHttpProxyAddress('socks=127.0.0.1:1080; HTTP=localhost:7890'),
      'localhost:7890',
    );
    expect(preferredHttpProxyAddress('https=localhost:8080'), 'localhost:8080');
  });

  test('normalizes URL and host:port to the startup endpoint format', () {
    expect(
      normalizeHttpProxyAddress(' http://127.0.0.1:7890/ '),
      '127.0.0.1:7890',
    );
    expect(normalizeHttpProxyAddress('localhost:8080'), 'localhost:8080');
    expect(
      normalizeHttpProxyAddress('HTTP://Proxy.Example:65535'),
      'proxy.example:65535',
    );
    expect(
      normalizeHttpProxyAddress('http://proxy.example:80'),
      'proxy.example:80',
    );
  });

  test('rejects links and formats the HTTP proxy consumers cannot use', () {
    for (final input in [
      '',
      'localhost',
      'localhost:0',
      'localhost:65536',
      'localhost:99999',
      'localhost:abc',
      'http://localhost',
      'http://localhost:7890/path',
      'http://localhost:7890?subscription=1',
      'http://localhost:7890#fragment',
      'http://user:pass@localhost:7890',
      'socks5://localhost:7890',
      'socks4://localhost:7890',
      'https://localhost:7890',
      'http://local host:7890',
      '[::1]:7890',
    ]) {
      expect(normalizeHttpProxyAddress(input), isNull, reason: input);
    }
  });
}
