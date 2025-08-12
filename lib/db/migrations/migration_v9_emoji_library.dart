import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

class MigrationV9EmojiLibrary extends Migration {
  @override
  int get version => 9;

  @override
  String get description => "创建表情包库表";

  @override
  void up(CommonDatabase db) {
    // 创建表情包分组表
    db.execute('''
      CREATE TABLE EmojiGroups (
        group_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cover_url TEXT,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // 创建表情包图片表
    db.execute('''
      CREATE TABLE EmojiImages (
        image_id INTEGER PRIMARY KEY AUTOINCREMENT,
        group_id INTEGER NOT NULL,
        url TEXT NOT NULL,
        thumbnail_url TEXT,
        FOREIGN KEY (group_id) REFERENCES EmojiGroups(group_id) ON DELETE CASCADE
      );
    ''');

    // 插入默认的表情包分组
    db.execute('''
      INSERT INTO EmojiGroups (name, sort_order) VALUES ('senkosan', 1);
    ''');

    // 获取插入的senkosan分组ID
    final stmtSenko = db.prepare('SELECT last_insert_rowid() as group_id;');
    final resultSenko = stmtSenko.select([]);
    final senkoGroupId = resultSenko.first['group_id'] as int;
    stmtSenko.dispose();

    // 插入neko分组
    db.execute('''
      INSERT INTO EmojiGroups (name, sort_order) VALUES ('neko', 2);
    ''');

    // 获取插入的neko分组ID
    final stmt = db.prepare('SELECT last_insert_rowid() as group_id;');
    final result = stmt.select([]);
    final groupId = result.first['group_id'] as int;
    stmt.dispose();

    // senkosan表情包URL列表
    final senkoEmojiUrls = [
      "https://emoji.discadia.com/emojis/b0e07112-12f4-4ded-820c-f7ee92284e6e.PNG",
      "https://emoji.discadia.com/emojis/6a6f4dcc-bf8b-4490-8e3a-5262e9e80591.PNG",
      "https://emoji.discadia.com/emojis/6c1ffa2b-abc5-478d-a364-bccaf52c5998.PNG",
      "https://emoji.discadia.com/emojis/e47b3dd6-5c12-4281-8184-a2c0ab83fd0f.GIF",
      "https://emoji.discadia.com/emojis/bce78aa7-ef96-47a2-a218-d993af0b5e20.PNG",
      "https://emoji.discadia.com/emojis/24ae9097-6083-451c-81e4-5dbf8ab0f43e.GIF",
      "https://emoji.discadia.com/emojis/53d58547-7b25-4bba-badd-d2b6f4d89356.GIF",
      "https://emoji.discadia.com/emojis/36aa7fc4-d684-4623-9ef7-2a035d87b93e.PNG",
      "https://emoji.discadia.com/emojis/8bb54b74-d0f2-490a-9024-90baa470b839.PNG",
      "https://emoji.discadia.com/emojis/06be67cb-b821-4683-a5d4-d8f5e4d30068.PNG",
      "https://emoji.discadia.com/emojis/c8ada0c8-090a-4e5f-a9de-ffaa21413d38.GIF",
      "https://emoji.discadia.com/emojis/300c220b-c5ca-4714-bd44-5f22af4e2382.png",
      "https://emoji.discadia.com/emojis/9bfa9c86-3bc2-4015-90aa-3514b5710859.GIF",
      "https://emoji.discadia.com/emojis/1cb1b617-f7cc-400c-8e9a-843faf8d7aaf.PNG",
      "https://emoji.discadia.com/emojis/c45d895c-d59f-4019-af75-dc6089911544.GIF",
      "https://emoji.discadia.com/emojis/eeaba756-e3a3-436b-bec3-efcf8f2b389a.PNG",
      "https://emoji.discadia.com/emojis/bd8096f3-51b0-4eca-aa50-b95a12a4f13e.GIF",
      "https://emoji.discadia.com/emojis/1336f07e-74a3-4b0f-97a7-85ff4865e583.GIF",
      "https://emoji.discadia.com/emojis/83878ab9-de0a-4bcb-96ca-c97ae799d4f0.GIF",
      "https://emoji.discadia.com/emojis/82d42610-8090-4140-ba93-aee7233a670c.PNG",
      "https://emoji.discadia.com/emojis/ace19724-ed3a-48c0-9639-7dacb4a8e248.GIF",
      "https://emoji.discadia.com/emojis/aca3a914-80b3-4207-bce4-13a9acf5de12.GIF",
      "https://emoji.discadia.com/emojis/16ab841b-4291-438e-b3ba-cbbd9ae7c9ef.GIF",
      "https://emoji.discadia.com/emojis/bd3264bd-95aa-4e4c-a97e-006be98dd3c5.PNG",
      "https://emoji.discadia.com/emojis/058cb4cc-be8c-4b6f-974c-5decf11d7b62.PNG",
      "https://emoji.discadia.com/emojis/2034556f-7de9-46e5-9d7f-02f39ffa81e6.PNG",
      "https://emoji.discadia.com/emojis/59566abb-0d12-48ee-b96a-99ec2834f93e.PNG",
      "https://emoji.discadia.com/emojis/e6f271cd-9323-44b5-a42a-0067783aad78.PNG",
      "https://emoji.discadia.com/emojis/bd3264bd-95aa-4e4c-a97e-006be98dd3c5.PNG"
    ];

    // 批量插入senkosan表情包
    for (int i = 0; i < senkoEmojiUrls.length; i++) {
      db.execute('''
        INSERT INTO EmojiImages (group_id, url, thumbnail_url) 
        VALUES (?, ?, ?);
      ''', [senkoGroupId, senkoEmojiUrls[i], senkoEmojiUrls[i]]);
    }

    // 更新senkosan表情包分组的封面图为第一张图片
    if (senkoEmojiUrls.isNotEmpty) {
      db.execute('''
        UPDATE EmojiGroups 
        SET cover_url = ? 
        WHERE group_id = ?;
      ''', [senkoEmojiUrls.first, senkoGroupId]);
    }

    // 默认表情包URL列表
    final emojiUrls = [
      "https://linux.do/uploads/default/optimized/4X/5/9/f/59ffbc2c53dd2a07dc30d4368bd5c9e01ca57d80_2_490x500.jpeg",
      "https://linux.do/uploads/default/optimized/4X/5/d/9/5d932c05a642396335f632a370bd8d45463cf2e2_2_503x500.jpeg",
      "https://linux.do/uploads/default/optimized/4X/f/a/a/faa5afe1749312bc4a326feff0eca6fb39355300_2_518x499.jpeg",
      "https://linux.do/uploads/default/optimized/4X/5/5/2/552f13479e7bff2ce047d11ad821da4963c467f2_2_500x500.jpeg",
      "https://linux.do/uploads/default/optimized/4X/0/d/1/0d125de02c201128bf6a3f78ff9450e48a3e27de_2_532x500.jpeg",
      "https://linux.do/uploads/default/optimized/4X/2/3/f/23fac94d8858a23cbd49879f2b037a2be020c87e_2_500x500.jpeg",
      "https://linux.do/uploads/default/optimized/4X/3/1/a/31a38450e22d42f9d4b683b190a40b9a94727681_2_493x500.jpeg",
      "https://linux.do/uploads/default/optimized/4X/6/a/3/6a3619da1dbb63cc0420fbf1f6f2316b5503ab09_2_413x500.jpeg",
      "https://linux.do/uploads/default/optimized/4X/e/1/4/e1429fd845288aa4c75e30829efe4696a1f4b1f9_2_636x500.jpeg",
      "https://linux.do/uploads/default/optimized/4X/7/f/4/7f4d50105aefec0efa80c498179a7d0901b54a7a_2_564x500.jpeg",
      "https://linux.do/uploads/default/optimized/4X/8/a/b/8ab3b1fb6c7d990c9070e010f915fb237093f67f_2_490x500.jpeg",
      "https://linux.do/uploads/default/optimized/4X/2/9/c/29ce5a00273ba10ae9c1a8abf7a3b42abcccdd66_2_533x499.jpeg",
      "https://linux.do/uploads/default/optimized/4X/1/0/6/1063e1803fa965cd1604bda0e6d7705376f9963f_2_500x500.jpeg",
      "https://linux.do/uploads/default/optimized/4X/6/e/6/6e68786e64c4260746d02d2e308168b200185d7d_2_613x500.jpeg",
      "https://linux.do/uploads/default/optimized/4X/1/a/b/1ab685b8f2948689a917aa1c0d7ce9bfa2ec48bd_2_594x500.jpeg",
      "https://linux.do/uploads/default/optimized/4X/1/c/3/1c39b615e9ef831568ede182ecdec0e749bbd202_2_503x499.jpeg",
      "https://linux.do/uploads/default/optimized/4X/6/5/0/650110fc5845e915cf4aefec11e4a058f4aff731_2_500x500.png",
      "https://linux.do/uploads/default/optimized/4X/9/0/9/90957308d24a9c79257425ff0f8a14411b6aaad6_2_500x500.png",
      "https://linux.do/uploads/default/optimized/4X/8/1/9/81909951f915b3e969c93d433b9fd6935a431d9a_2_500x500.png",
      "https://linux.do/uploads/default/optimized/4X/2/5/6/256411726c9680d821da26ad699e7d2d574ab24c_2_500x500.png",
      "https://linux.do/uploads/default/optimized/4X/1/e/a/1eaf593a62462e72a4193f6c646f51898e85f53d_2_500x500.png",
      "https://linux.do/uploads/default/optimized/4X/5/7/b/57b21409decd4258dc93ce93cff40ef3b631de46_2_500x500.png",
      "https://linux.do/uploads/default/optimized/4X/9/8/9/989df0f7b3b9683974162f491a517305711e28ce_2_500x500.png",
      "https://linux.do/uploads/default/optimized/4X/b/8/5/b85433e17a79846cf2ec8a9458506ce6f48d25b2_2_500x500.png",
      "https://linux.do/uploads/default/optimized/4X/3/9/9/399d86225dadc703fabb1a8df48be5b36908320c_2_488x500.png",
      "https://linux.do/uploads/default/original/4X/1/d/5/1d58ac97d5e63b36083a5eadb67a3f3404f0b063.png",
      "https://linux.do/uploads/default/original/4X/c/3/b/c3bcb5be07dd54b84038568d6ae9762afb86c8f9.png",
      "https://linux.do/uploads/default/original/4X/8/f/e/8fe82a64472dc96eaf9b27dc86f0655fee325572.png",
      "https://linux.do/uploads/default/optimized/4X/3/f/6/3f6c5ed37cb8a5b4c06d1c9b1e8aab38ddfe9878_2_500x500.png",
      "https://linux.do/uploads/default/optimized/4X/8/2/2/8220d4c92b848b15d642dd22973bd0854d734aa9_2_500x500.png",
      "https://linux.do/uploads/default/optimized/4X/f/2/2/f228b317d9c333833ccf3a81fee705024a548963_2_500x500.png",
      "https://linux.do/uploads/default/optimized/4X/f/9/9/f99df315a1cdba0897bc6f4776ebdcc360ddf562_2_500x500.png",
      "https://linux.do/uploads/default/optimized/4X/a/e/5/ae56ca1c5ee8ab2c47104c54077efcedbbdc474e_2_500x500.png",
      "https://linux.do/uploads/default/optimized/4X/e/1/e/e1e37eca93601022f3efcd91cb477b88ee350e07_2_500x500.png",
      "https://linux.do/uploads/default/optimized/4X/7/8/0/78015ed5ccdc87e5769eb2d1af5cdaf466c1cb07_2_500x500.png",
      "https://linux.do/uploads/default/optimized/4X/2/f/4/2f453be9d3d69d459637f3cd824b6f9641b6f592_2_500x500.png",
      "https://linux.do/uploads/default/optimized/4X/2/4/c/24cac75d64461ba1d1b0c3c8560a1c10acb3f3ad_2_500x500.png",
      "https://linux.do/uploads/default/optimized/4X/3/d/2/3d245f6de7d3549174cef112560dec8ae3a768d7_2_500x500.png"
    ];

    // 批量插入默认表情包
    for (int i = 0; i < emojiUrls.length; i++) {
      db.execute('''
        INSERT INTO EmojiImages (group_id, url, thumbnail_url) 
        VALUES (?, ?, ?);
      ''', [groupId, emojiUrls[i], emojiUrls[i]]);
    }

    // 更新表情包分组的封面图为第一张图片
    if (emojiUrls.isNotEmpty) {
      db.execute('''
        UPDATE EmojiGroups 
        SET cover_url = ? 
        WHERE group_id = ?;
      ''', [emojiUrls.first, groupId]);
    }

    db.execute('PRAGMA user_version = 9;');
    LogUtils.i('已应用迁移v9：创建表情包库表并插入默认数据');
  }

  @override
  void down(CommonDatabase db) {
    db.execute('DROP TABLE IF EXISTS EmojiImages;');
    db.execute('DROP TABLE IF EXISTS EmojiGroups;');
    db.execute('PRAGMA user_version = 8;');
    LogUtils.i('已回滚迁移v9：删除表情包库表');
  }
}