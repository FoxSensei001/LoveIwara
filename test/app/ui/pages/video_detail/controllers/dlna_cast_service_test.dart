import 'dart:async';

import 'package:dlna_dart/dlna.dart';
import 'package:dlna_dart/xmlParser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/dlna_cast_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/dlna_cast_sheet.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await LogUtils.init(isProduction: true, enablePersistence: false);
  });

  testWidgets(
    'stops an existing renderer session before replacing its media URI',
    (tester) async {
      await tester.pumpWidget(
        const OKToast(child: MaterialApp(home: SizedBox.shrink())),
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
      await tester.pump(const Duration(seconds: 5));
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
      const OKToast(child: MaterialApp(home: SizedBox.shrink())),
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
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('continues casting when an idle renderer rejects Stop', (
    tester,
  ) async {
    await tester.pumpWidget(
      const OKToast(child: MaterialApp(home: SizedBox.shrink())),
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
    await tester.pump(const Duration(seconds: 5));
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
      OKToast(
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
    await tester.pump(const Duration(seconds: 5));
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
