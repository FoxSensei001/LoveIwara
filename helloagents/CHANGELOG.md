# Changelog

All notable changes to this project are documented in this file.

## [Unreleased]

### Fixed
- Network proxy disable path now forces direct connection by default:
  - `MyHttpOverrides` now sets `findProxy` to `DIRECT` when custom proxy is not enabled.
  - `HttpClientFactory` now sets `findProxy` to `DIRECT` when no custom proxy is configured.
- Startup initialization now explicitly clears shared proxy state when proxy is disabled or unsupported:
  - Added `HttpClientFactory.instance.setProxy(null)` in non-proxy startup branches.

### Added
- Added proxy behavior unit tests for `HttpClientFactory`:
  - disabled proxy => `DIRECT`
  - enabled proxy => `PROXY host:port; DIRECT`
  - invalid proxy url => fallback to `DIRECT`
