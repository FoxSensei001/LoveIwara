import 'dart:async';

import 'package:dlna_dart/dlna.dart';
import 'package:dlna_dart/xmlParser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/dlna_cast_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/dlna_cast_sheet.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';

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

      final device = DLNADevice(
        DeviceInfo(
          'http://192.0.2.1',
          'urn:schemas-upnp-org:device:MediaRenderer:1',
          'Test renderer',
          [
            {
              'serviceId': 'urn:upnp-org:serviceId:AVTransport',
              'controlURL': '/control',
            },
          ],
        ),
      );
      final service = DlnaCastService(transport: transport);

      await service.castToDevice(device, 'https://files.iwara.tv/video.mp4');

      expect(transport.actions, ['Stop', 'SetAVTransportURI', 'Play']);
      expect(service.isConnected.value, isTrue);
      expect(service.connectedDeviceName.value, 'Test renderer');
      await _drainToasts(tester);
    },
  );

  test('only devices with an AVTransport control endpoint are castable', () {
    final renderer = _device(
      deviceType: 'urn:schemas-upnp-org:device:MediaRenderer:1',
      services: [
        {
          'serviceType': 'urn:schemas-upnp-org:service:AVTransport:1',
          'serviceId': 'urn:upnp-org:serviceId:AVTransport',
          'controlURL': '/control',
        },
      ],
    );
    final mediaServer = _device(
      deviceType: 'urn:schemas-upnp-org:device:MediaServer:1',
      services: [
        {
          'serviceType': 'urn:schemas-upnp-org:service:ContentDirectory:1',
          'serviceId': 'urn:upnp-org:serviceId:ContentDirectory',
          'controlURL': '/content',
        },
      ],
    );
    final serviceTypeOnly = _device(
      deviceType: 'urn:schemas-upnp-org:device:MediaRenderer:1',
      services: [
        {
          'serviceType': 'urn:schemas-upnp-org:service:AVTransport:1',
          'serviceId': 'urn:vendor:serviceId:Playback',
          'controlURL': '/control',
        },
      ],
    );

    expect(DlnaCastService.isCastCapableDevice(renderer), isTrue);
    expect(DlnaCastService.isCastCapableDevice(mediaServer), isFalse);
    expect(DlnaCastService.isCastCapableDevice(serviceTypeOnly), isFalse);
  });

  testWidgets('serializes stop and a subsequent cast', (tester) async {
    await tester.pumpWidget(
      const AppToastHost(child: MaterialApp(home: SizedBox.shrink())),
    );

    final first = _device(
      friendlyName: 'First renderer',
      deviceType: 'urn:schemas-upnp-org:device:MediaRenderer:1',
      services: [_avTransportService],
    );
    final second = _device(
      friendlyName: 'Second renderer',
      deviceType: 'urn:schemas-upnp-org:device:MediaRenderer:1',
      services: [_avTransportService],
    );
    final transport = _DelayedStopTransport(first);
    final service = DlnaCastService(transport: transport);

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
    final service = DlnaCastService(transport: transport);
    final device = _device(
      deviceType: 'urn:schemas-upnp-org:device:MediaRenderer:1',
      services: [_avTransportService],
    );

    expect(
      await service.castToDevice(device, 'https://files.iwara.tv/video.mp4'),
      isTrue,
    );
    expect(transport.actions, ['Stop', 'SetAVTransportURI', 'Play']);
    expect(service.isConnected.value, isTrue);
    await _drainToasts(tester);
  });

  testWidgets('shows the stop control after casting succeeds', (tester) async {
    final transport = _RecordingTransport();
    final service = _NoSearchDlnaCastService(transport: transport);
    final device = _device(
      friendlyName: 'Living room TV',
      deviceType: 'urn:schemas-upnp-org:device:MediaRenderer:1',
      services: [_avTransportService],
    );
    service.devices.add(device);

    await tester.pumpWidget(
      AppToastHost(
        child: MaterialApp(
          home: Scaffold(
            body: DlnaCastSheet(
              videoUrl: 'https://files.iwara.tv/video.mp4',
              dlnaController: service,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(TextButton), findsNothing);
    await tester.tap(find.text('Living room TV'));
    await tester.pump();
    await tester.pump();

    expect(service.isConnected.value, isTrue);
    expect(find.byType(TextButton), findsOneWidget);
    await _drainToasts(tester);
  });
}

const _avTransportService = {
  'serviceType': 'urn:schemas-upnp-org:service:AVTransport:1',
  'serviceId': 'urn:upnp-org:serviceId:AVTransport',
  'controlURL': '/control',
};

DLNADevice _device({
  String friendlyName = 'Test device',
  required String deviceType,
  required List services,
}) {
  return DLNADevice(
    DeviceInfo('http://192.0.2.1', deviceType, friendlyName, services),
  );
}

class _RecordingTransport implements DlnaDeviceTransport {
  _RecordingTransport({this.stopError});

  final Object? stopError;
  final actions = <String>[];

  @override
  Future<void> setUrl(DLNADevice device, String videoUrl) async {
    actions.add('SetAVTransportURI');
  }

  @override
  Future<void> play(DLNADevice device) async {
    actions.add('Play');
  }

  @override
  Future<void> stop(DLNADevice device) async {
    actions.add('Stop');
    if (stopError case final error?) throw error;
  }
}

class _NoSearchDlnaCastService extends DlnaCastService {
  _NoSearchDlnaCastService({required super.transport});

  @override
  Future<void> startSearch() async {}

  @override
  void stopSearch() {}
}

class _DelayedStopTransport implements DlnaDeviceTransport {
  _DelayedStopTransport(this.firstDevice);

  final DLNADevice firstDevice;
  final actions = <String>[];
  final explicitStopStarted = Completer<void>();
  final releaseExplicitStop = Completer<void>();
  int _firstDeviceStopCount = 0;

  @override
  Future<void> setUrl(DLNADevice device, String videoUrl) async {
    actions.add('SetAVTransportURI:${device.info.friendlyName}');
  }

  @override
  Future<void> play(DLNADevice device) async {
    actions.add('Play:${device.info.friendlyName}');
  }

  @override
  Future<void> stop(DLNADevice device) async {
    actions.add('Stop:${device.info.friendlyName}');
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
