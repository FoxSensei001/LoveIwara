import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/desktop_external_player.dart';

void main() {
  group('DesktopPlayerLauncher.buildArguments', () {
    test('默认模板 = 把输入当唯一参数', () {
      expect(
        DesktopPlayerLauncher.buildArguments(
          DesktopPlayerEntry.defaultArgumentTemplate,
          r'D:\Videos\a.mp4',
        ),
        [r'D:\Videos\a.mp4'],
      );
    });

    test('占位符可以嵌在参数中间', () {
      expect(
        DesktopPlayerLauncher.buildArguments(
          '--vr --url={input}',
          'https://cdn.example.com/a.mp4',
        ),
        ['--vr', '--url=https://cdn.example.com/a.mp4'],
      );
    });

    test('双引号内的空格不切分', () {
      expect(
        DesktopPlayerLauncher.buildArguments('--title "My Video" {input}', '/a.mp4'),
        ['--title', 'My Video', '/a.mp4'],
      );
    });

    test('模板里漏写占位符时把输入补在最后', () {
      // 用户少写一个 {input} 不该让播放器空手启动。
      expect(
        DesktopPlayerLauncher.buildArguments('--fullscreen', '/a.mp4'),
        ['--fullscreen', '/a.mp4'],
      );
    });

    test('路径里的空格和中文原样保留（不做 shell 转义）', () {
      expect(
        DesktopPlayerLauncher.buildArguments(
          DesktopPlayerEntry.defaultArgumentTemplate,
          r'C:\我的 视频\a b.mp4',
        ),
        [r'C:\我的 视频\a b.mp4'],
      );
    });
  });

  group('DesktopPlayerStore 编解码', () {
    test('往返不丢字段', () {
      const entries = [
        DesktopPlayerEntry(
          id: 'a',
          name: 'HereSphere',
          executablePath: r'D:\Steam\steamapps\common\HereSphere\HereSphere.exe',
          argumentTemplate: '--url={input}',
          autoDetected: true,
        ),
      ];

      final decoded = DesktopPlayerStore.decode(
        DesktopPlayerStore.encode(entries),
      );

      expect(decoded, entries);
      expect(decoded.single.autoDetected, isTrue);
      expect(decoded.single.argumentTemplate, '--url={input}');
    });

    test('坏数据按空列表处理，不抛异常', () {
      expect(DesktopPlayerStore.decode(''), isEmpty);
      expect(DesktopPlayerStore.decode('not json'), isEmpty);
      expect(DesktopPlayerStore.decode('{"a":1}'), isEmpty);
      // 缺可执行文件路径的条目被丢掉，其余保留
      expect(
        DesktopPlayerStore.decode(
          '[{"id":"a","name":"X"},'
          '{"id":"b","name":"Y","executablePath":"/usr/bin/mpv"}]',
        ).single.id,
        'b',
      );
    });
  });

  group('DesktopPlayerProbe.parseSteamLibraryPaths', () {
    test('抠出所有库根目录并还原反斜杠转义', () {
      // 多盘用户的 Steam 库不在主目录，只认 Program Files 会把他们全漏掉。
      const vdf = '''
"libraryfolders"
{
	"0"
	{
		"path"		"C:\\\\Program Files (x86)\\\\Steam"
		"label"		""
	}
	"1"
	{
		"path"		"D:\\\\SteamLibrary"
	}
}
''';

      expect(DesktopPlayerProbe.parseSteamLibraryPaths(vdf), [
        r'C:\Program Files (x86)\Steam',
        r'D:\SteamLibrary',
      ]);
    });

    test('空内容不炸', () {
      expect(DesktopPlayerProbe.parseSteamLibraryPaths(''), isEmpty);
    });
  });
}
