import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/ui/widgets/paged_search/paged_search_controller.dart';

typedef FollowPageFetcher = PagedFetcher<User>;

/// Match display names and handles, including pasted @handles.
bool matchesFollowSearch(String query, String name, String username) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return true;
  final handle = normalized.startsWith('@')
      ? normalized.substring(1)
      : normalized;
  return name.toLowerCase().contains(normalized) ||
      username.toLowerCase().contains(handle);
}

/// Follow lists on top of the shared paged search state machine.
class FollowSearchController extends PagedSearchController<User> {
  FollowSearchController({required super.fetchPage})
    : super(
        idOf: (user) => user.id,
        matches: (query, user) =>
            matchesFollowSearch(query, user.name, user.username),
      );

  // Static members are not inherited; keep the old access path working.
  static const maxProbeLimit = PagedSearchController.maxProbeLimit;
}
