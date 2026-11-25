import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/frame_interp/frame_interp_component.dart';
import 'package:path/path.dart' as p;

/// 组件清单的校验。
///
/// 清单里的名字会被拼成路径、交给系统当原生库加载，所以它不能把加载指到组件
/// 目录外面去——哪怕组件是随包带的，也不该靠「清单一定没问题」来保证这一点。
void main() {
  late Directory workDir;

  setUp(() async {
    workDir = await Directory.systemTemp.createTemp('frame_interp_component_');
  });

  tearDown(() async {
    await workDir.delete(recursive: true);
  });

  group('清单', () {
    Future<Directory> componentDir(String manifest) async {
      final dir = Directory(p.join(workDir.path, 'c'));
      await Directory(p.join(dir.path, 'models', 'm')).create(recursive: true);
      await File(p.join(dir.path, 'manifest.json')).writeAsString(manifest);
      await File(p.join(dir.path, 'engine.dll')).writeAsString('');
      await File(p.join(dir.path, 'dep.dll')).writeAsString('');
      await File(
        p.join(dir.path, 'models', 'm', 'flownet.bin'),
      ).writeAsString('');
      return dir;
    }

    final platform = FrameInterpComponent.platformKey;

    test('没有清单 = 这份安装里没带组件', () async {
      final result = await FrameInterpComponent.readManifest(workDir);
      expect(result.status, FrameInterpComponentStatus.unsupported);
    });

    test('库名带路径的清单不认：不能被它指去加载目录外的文件', () async {
      final dir = await componentDir(
        '{"abi": 1, "platform": "$platform", "library": "engine.dll", '
        '"preload": ["../evil.dll"], "model": "models/m"}',
      );
      final result = await FrameInterpComponent.readManifest(dir);
      expect(result.status, FrameInterpComponentStatus.incompatible);
      expect(result.spec, isNull);
    });

    test('ABI 版本对不上的清单不认', () async {
      final dir = await componentDir(
        '{"abi": 999, "platform": "$platform", "library": "engine.dll", '
        '"preload": ["dep.dll"], "model": "models/m"}',
      );
      final result = await FrameInterpComponent.readManifest(dir);
      expect(result.status, FrameInterpComponentStatus.incompatible);
    });

    // 安卓 / 苹果的摆法：库在一处（原生库目录 / framework），清单和模型在别处。
    test('分开摆的组件：库按库目录找，模型按模型根目录找', () async {
      final libDir = Directory(p.join(workDir.path, 'lib'));
      final modelRoot = Directory(p.join(workDir.path, 'support'));
      await Directory(p.join(modelRoot.path, 'models', 'm')).create(
        recursive: true,
      );
      await libDir.create();
      await File(p.join(libDir.path, 'engine.so')).writeAsString('');
      await File(p.join(libDir.path, 'dep.so')).writeAsString('');
      await File(
        p.join(modelRoot.path, 'models', 'm', 'flownet.bin'),
      ).writeAsString('');
      final manifest = File(p.join(libDir.path, 'libfi_manifest.so'));
      await manifest.writeAsString(
        '{"abi": 1, "platform": "$platform", "library": "engine.so", '
        '"preload": ["dep.so"], "model": "models/m"}',
      );
      final result = await FrameInterpComponent.readLayout(
        FrameInterpComponentLayout(
          manifest: manifest,
          libraryDirectory: libDir,
          modelRoot: modelRoot,
        ),
      );
      expect(result.status, FrameInterpComponentStatus.ready);
      expect(p.equals(result.spec!.directory, libDir.path), isTrue);
      expect(
        p.equals(
          result.spec!.modelDirectory,
          p.join(modelRoot.path, 'models', 'm'),
        ),
        isTrue,
      );
    }, skip: platform == null ? '这个平台没有组件' : false);

    test('清单里的模型路径越出模型根目录：不认', () async {
      final dir = await componentDir(
        '{"abi": 1, "platform": "$platform", "library": "engine.dll", '
        '"preload": ["dep.dll"], "model": "../outside"}',
      );
      final result = await FrameInterpComponent.readManifest(dir);
      expect(result.status, FrameInterpComponentStatus.incompatible);
    });

    test('齐全的清单：给出加载顺序和模型目录', () async {
      final dir = await componentDir(
        '{"abi": 1, "platform": "$platform", "library": "engine.dll", '
        '"preload": ["dep.dll"], "model": "models/m"}',
      );
      final result = await FrameInterpComponent.readManifest(dir);
      expect(result.status, FrameInterpComponentStatus.ready);
      expect(result.spec!.preload, ['dep.dll']);
      expect(result.spec!.library, 'engine.dll');
      expect(
        p.equals(result.spec!.modelDirectory, p.join(dir.path, 'models', 'm')),
        isTrue,
      );
    }, skip: platform == null ? '这个平台没有组件' : false);
  });
}
