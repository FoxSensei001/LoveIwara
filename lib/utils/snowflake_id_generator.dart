import 'dart:math';

/// 雪花算法ID生成器
/// 生成64位唯一ID，转换为字符串存储
class SnowflakeIdGenerator {
  static SnowflakeIdGenerator? _instance;
  
  // 起始时间戳 (2023-01-01 00:00:00)
  static const int _epoch = 1672531200000;
  
  // 各部分位数
  static const int _machineIdBits = 10;  // 机器ID位数
  static const int _sequenceBits = 12;   // 序列号位数
  
  // 各部分最大值
  static const int _maxMachineId = (1 << _machineIdBits) - 1;  // 1023
  static const int _maxSequence = (1 << _sequenceBits) - 1;    // 4095
  
  // 各部分偏移量
  static const int _sequenceShift = 0;
  static const int _machineIdShift = _sequenceBits;
  static const int _timestampShift = _sequenceBits + _machineIdBits;
  
  final int _machineId;
  int _sequence = 0;
  int _lastTimestamp = -1;
  
  SnowflakeIdGenerator._(this._machineId);
  
  /// 获取单例实例
  factory SnowflakeIdGenerator.getInstance({int? machineId}) {
    if (_instance == null) {
      // 如果没有提供machineId，则随机生成一个
      final finalMachineId = machineId ?? Random().nextInt(_maxMachineId + 1);
      _instance = SnowflakeIdGenerator._(finalMachineId);
    }
    return _instance!;
  }
  
  /// 生成下一个ID（返回字符串格式）
  String nextId() {
    final timestamp = _getCurrentTimestamp();
    
    if (timestamp < _lastTimestamp) {
      throw Exception('时钟回拨异常，无法生成ID');
    }
    
    if (timestamp == _lastTimestamp) {
      _sequence = (_sequence + 1) & _maxSequence;
      if (_sequence == 0) {
        // 序列号用完，等待下一毫秒
        return nextId();
      }
    } else {
      _sequence = 0;
    }
    
    _lastTimestamp = timestamp;
    
    // 组装ID
    final id = ((timestamp - _epoch) << _timestampShift) |
               (_machineId << _machineIdShift) |
               (_sequence << _sequenceShift);
    
    return id.toString();
  }
  
  /// 获取当前时间戳
  int _getCurrentTimestamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }
  
  /// 解析ID获取时间戳信息（用于调试）
  static DateTime parseTimestamp(String id) {
    final idNum = int.parse(id);
    final timestamp = ((idNum >> _timestampShift) + _epoch);
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  
  /// 解析ID获取机器ID（用于调试）
  static int parseMachineId(String id) {
    final idNum = int.parse(id);
    return (idNum >> _machineIdShift) & _maxMachineId;
  }
  
  /// 解析ID获取序列号（用于调试）
  static int parseSequence(String id) {
    final idNum = int.parse(id);
    return idNum & _maxSequence;
  }
}