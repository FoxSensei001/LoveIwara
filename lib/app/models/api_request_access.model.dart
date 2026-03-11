enum ApiRequestAccess { authRequired, publicOnly, optionalAuthShortWait }

extension ApiRequestAccessX on ApiRequestAccess {
  bool get requiresAuthentication => this == ApiRequestAccess.authRequired;

  bool get allowsAnonymousFallback =>
      this == ApiRequestAccess.optionalAuthShortWait;

  bool get sendsAuthenticationByDefault => this != ApiRequestAccess.publicOnly;
}
