import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/video_source.model.dart';
import 'package:i_iwara/utils/common_utils.dart';

void main() {
  test('sortVideoSourcesByQuality orders source first, preview last', () {
    final sources = [
      VideoSource(id: '1', name: '360'),
      VideoSource(id: '2', name: 'Preview'),
      VideoSource(id: '3', name: 'Source'),
      VideoSource(id: '4', name: '720'),
      VideoSource(id: '5', name: '540'),
    ];
    final sorted = CommonUtils.sortVideoSourcesByQuality(sources);
    expect(sorted.map((s) => s.name).toList(), [
      'Source',
      '720',
      '540',
      '360',
      'Preview',
    ]);
  });

  test('sortVideoSourcesByQuality keeps unknown qualities stable at the end', () {
    final sources = [
      VideoSource(id: '1', name: 'weird'),
      VideoSource(id: '2', name: 'Source'),
      VideoSource(id: '3', name: 'another'),
    ];
    final sorted = CommonUtils.sortVideoSourcesByQuality(sources);
    expect(sorted.map((s) => s.name).toList(), ['Source', 'weird', 'another']);
  });
}
