class CloudflareChallengeRequest {
  final Uri initialUri;
  final String triggerHost;
  final String? reason;

  const CloudflareChallengeRequest({
    required this.initialUri,
    required this.triggerHost,
    this.reason,
  });
}

class CloudflareChallengeResult {
  final bool verified;
  final String? userAgent;

  const CloudflareChallengeResult({required this.verified, this.userAgent});

  const CloudflareChallengeResult.cancelled()
    : verified = false,
      userAgent = null;
}
