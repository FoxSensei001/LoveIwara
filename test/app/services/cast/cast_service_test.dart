import 'dart:async';
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/cast/cast_service.dart';
import 'package:i_iwara/app/services/cast/chromecast/cast_channel.dart';
import 'package:i_iwara/app/services/cast/chromecast/chromecast_controller.dart';
import 'package:i_iwara/app/services/cast/dlna/dlna_controller.dart';
import 'package:i_iwara/app/services/cast/dlna/upnp_description.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/cast_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await LogUtils.init(isProduction: true, enablePersistence: false);
  });

  testWidgets(
    'stops an existing renderer session before replacing its media URI',
    (tester) async {
      await tester.pumpWidget(
        const AppToastHost(child: MaterialApp(home: SizedBox.shrink())),
      );
      final transport = _RecordingTransport();
      final service = CastService(dlnaTransport: transport);

      await service.castToDevice(
        _device(name: 'Test renderer'),
        'https://files.iwara.tv/video.mp4',
      );

      expect(transport.actions, ['Stop', 'SetAVTransportURI', 'Play']);
      expect(service.isConnected.value, isTrue);
      expect(service.connectedDeviceName.value, 'Test renderer');
      await _drainToasts(tester);
    },
  );

  group('parseUpnpRenderers', () {
    final location = Uri.parse('http://192.168.1.20:49152/description.xml');

    test('finds a renderer nested under deviceList', () {
      // 根设备只有 ContentDirectory，渲染器挂在子设备下（Sonos 等的结构）：
      // dlna_dart 只看第一个 serviceList，这台会被整台丢掉。
      const xml = '''<?xml version="1.0"?>
<root xmlns="urn:schemas-upnp-org:device-1-0">
  <device>
    <deviceType>urn:schemas-upnp-org:device:ZonePlayer:1</deviceType>
    <friendlyName>Living Room</friendlyName>
    <UDN>uuid:root</UDN>
    <serviceList>
      <service>
        <serviceType>urn:schemas-upnp-org:service:ContentDirectory:1</serviceType>
        <serviceId>urn:upnp-org:serviceId:ContentDirectory</serviceId>
        <controlURL>/cd/control</controlURL>
      </service>
    </serviceList>
    <deviceList>
      <device>
        <deviceType>urn:schemas-upnp-org:device:MediaRenderer:1</deviceType>
        <friendlyName>Living Room - Player</friendlyName>
        <modelName>Play:5</modelName>
        <UDN>uuid:renderer</UDN>
        <serviceList>
          <service>
            <serviceType>urn:schemas-upnp-org:service:AVTransport:2</serviceType>
            <serviceId>urn:upnp-org:serviceId:AVTransport</serviceId>
            <controlURL>MediaRenderer/AVTransport/Control</controlURL>
          </service>
        </serviceList>
      </device>
    </deviceList>
  </device>
</root>''';
      final renderers = parseUpnpRenderers(xml, location);
      expect(renderers, hasLength(1));
      final r = renderers.single;
      expect(r.id, 'uuid:renderer');
      expect(r.name, 'Living Room - Player');
      expect(
        r.avTransportControlUrl.toString(),
        'http://192.168.1.20:49152/MediaRenderer/AVTransport/Control',
      );
      expect(
        r.avTransportServiceType,
        'urn:schemas-upnp-org:service:AVTransport:2',
      );
    });

    test('honours URLBase and skips media servers', () {
      const xml = '''<root xmlns="urn:schemas-upnp-org:device-1-0">
  <URLBase>http://192.168.1.30:8080/base/</URLBase>
  <device>
    <friendlyName>NAS</friendlyName>
    <serviceList>
      <service>
        <serviceType>urn:schemas-upnp-org:service:ContentDirectory:1</serviceType>
        <serviceId>urn:upnp-org:serviceId:ContentDirectory</serviceId>
        <controlURL>/cd</controlURL>
      </service>
    </serviceList>
    <deviceList>
      <device>
        <friendlyName>TV</friendlyName>
        <serviceList>
          <service>
            <serviceType>urn:schemas-upnp-org:service:AVTransport:1</serviceType>
            <serviceId>urn:vendor:serviceId:Playback</serviceId>
            <controlURL>av/control</controlURL>
          </service>
        </serviceList>
      </device>
    </deviceList>
  </device>
</root>''';
      final renderers = parseUpnpRenderers(xml, location);
      expect(renderers.map((r) => r.name), ['TV']);
      expect(
        renderers.single.avTransportControlUrl.toString(),
        'http://192.168.1.30:8080/base/av/control',
      );
    });
  });

  test('cast message survives an encode/decode round trip', () {
    final bytes = encodeCastMessage(
      sourceId: 'sender-0',
      destinationId: 'receiver-0',
      namespace: CastChannel.nsReceiver,
      payloadUtf8: '{"type":"LAUNCH","appId":"CC1AD845","requestId":7}',
    );
    final decoded = decodeCastMessage(Uint8List.fromList(bytes))!;
    expect(decoded.sourceId, 'sender-0');
    expect(decoded.destinationId, 'receiver-0');
    expect(decoded.namespace, CastChannel.nsReceiver);
    expect(decoded.type, 'LAUNCH');
    expect(decoded.requestId, 7);
  });

  testWidgets('serializes stop and a subsequent cast', (tester) async {
    await tester.pumpWidget(
      const AppToastHost(child: MaterialApp(home: SizedBox.shrink())),
    );

    final first = _device(name: 'First renderer', id: 'uuid:first');
    final second = _device(name: 'Second renderer', id: 'uuid:second');
    final transport = _DelayedStopTransport(first);
    final service = CastService(dlnaTransport: transport);

    expect(
      await service.castToDevice(first, 'https://files.iwara.tv/first.mp4'),
      isTrue,
    );

    final stopFuture = service.stopCast();
    await transport.explicitStopStarted.future;
    final secondCastFuture = service.castToDevice(
      second,
      'https://files.iwara.tv/second.mp4',
    );

    await tester.pump();
    expect(
      transport.actions,
      isNot(contains('SetAVTransportURI:Second renderer')),
    );

    transport.releaseExplicitStop.complete();
    await stopFuture;
    expect(await secondCastFuture, isTrue);
    expect(service.isConnected.value, isTrue);
    expect(service.connectedDeviceName.value, 'Second renderer');
    await _drainToasts(tester);
  });

  testWidgets('continues casting when an idle renderer rejects Stop', (
    tester,
  ) async {
    await tester.pumpWidget(
      const AppToastHost(child: MaterialApp(home: SizedBox.shrink())),
    );
    final transport = _RecordingTransport(stopError: StateError('idle'));
    final service = CastService(dlnaTransport: transport);

    expect(
      await service.castToDevice(_device(), 'https://files.iwara.tv/video.mp4'),
      isTrue,
    );
    expect(transport.actions, ['Stop', 'SetAVTransportURI', 'Play']);
    expect(service.isConnected.value, isTrue);
    await _drainToasts(tester);
  });

  testWidgets('chromecast casts go through the cast transport', (tester) async {
    await tester.pumpWidget(
      const AppToastHost(child: MaterialApp(home: SizedBox.shrink())),
    );
    final chromecast = _RecordingChromecast();
    final service = CastService(
      dlnaTransport: _RecordingTransport(),
      chromecastTransport: chromecast,
    );
    const device = ChromecastDevice(
      id: 'cast:abc',
      name: 'Bedroom TV',
      address: '192.168.1.40',
    );

    expect(
      await service.castToDevice(device, 'https://files.iwara.tv/v.mp4'),
      isTrue,
    );
    await service.stopCast();
    expect(chromecast.actions, ['load:Bedroom TV', 'stop:session-1']);
    expect(service.isConnected.value, isFalse);
    await _drainToasts(tester);
  });

  testWidgets('shows the stop control after casting succeeds', (tester) async {
    final transport = _RecordingTransport();
    final service = _NoSearchCastService(dlnaTransport: transport);
    service.devices.add(_device(name: 'Living room TV'));

    await tester.pumpWidget(
      slang.TranslationProvider(
        child: AppToastHost(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: CastSheet(
                  videoUrl: 'https://files.iwara.tv/video.mp4',
                  castService: service,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Stop Casting'), findsNothing);
    await tester.tap(find.text('Living room TV'));
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(service.isConnected.value, isTrue);
    expect(
      find.widgetWithText(GlassTextActionButton, 'Stop Casting'),
      findsOneWidget,
    );
    await _drainToasts(tester);
  });
}

DlnaCastDevice _device({String name = 'Test device', String id = 'uuid:x'}) {
  return DlnaCastDevice(
    id: id,
    name: name,
    location: Uri.parse('http://192.0.2.1/desc.xml'),
    avTransportControlUrl: Uri.parse('http://192.0.2.1/control'),
    avTransportServiceType: 'urn:schemas-upnp-org:service:AVTransport:1',
  );
}

class _RecordingTransport implements DlnaTransport {
  _RecordingTransport({this.stopError});

  final Object? stopError;
  final actions = <String>[];

  @override
  Future<void> setUrl(
    DlnaCastDevice device,
    String url, {
    String? title,
  }) async {
    actions.add('SetAVTransportURI');
  }

  @override
  Future<void> play(DlnaCastDevice device) async {
    actions.add('Play');
  }

  @override
  Future<void> stop(DlnaCastDevice device) async {
    actions.add('Stop');
    if (stopError case final error?) throw error;
  }
}

class _RecordingChromecast implements ChromecastTransport {
  final actions = <String>[];

  @override
  Future<String> load(
    ChromecastDevice device,
    String url, {
    String? title,
  }) async {
    actions.add('load:${device.name}');
    return 'session-1';
  }

  @override
  Future<void> stop(ChromecastDevice device, String? sessionId) async {
    actions.add('stop:$sessionId');
  }
}

class _NoSearchCastService extends CastService {
  _NoSearchCastService({super.dlnaTransport});

  @override
  Future<void> startSearch({bool clearDevices = true}) async {}

  @override
  void stopSearch() {}
}

class _DelayedStopTransport implements DlnaTransport {
  _DelayedStopTransport(this.firstDevice);

  final DlnaCastDevice firstDevice;
  final actions = <String>[];
  final explicitStopStarted = Completer<void>();
  final releaseExplicitStop = Completer<void>();
  int _firstDeviceStopCount = 0;

  @override
  Future<void> setUrl(
    DlnaCastDevice device,
    String url, {
    String? title,
  }) async {
    actions.add('SetAVTransportURI:${device.name}');
  }

  @override
  Future<void> play(DlnaCastDevice device) async {
    actions.add('Play:${device.name}');
  }

  @override
  Future<void> stop(DlnaCastDevice device) async {
    actions.add('Stop:${device.name}');
    if (identical(device, firstDevice)) {
      _firstDeviceStopCount++;
      if (_firstDeviceStopCount == 2) {
        explicitStopStarted.complete();
        await releaseExplicitStop.future;
      }
    }
  }
}

/// 把 toast 排干净。
///
/// 提示会挂一条自动关闭的计时器，关闭之后还要再等一段退场动画才把 Overlay
/// 摘掉——两者都是 timer，留到测试结束就是「A Timer is still pending」。
Future<void> _drainToasts(WidgetTester tester) async {
  // 提示是在 post-frame 回调里才被塞进管理器的，不先走一帧就「关不掉还没登记
  // 的那条」。
  await tester.pump();
  dismissAppToasts();
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}
