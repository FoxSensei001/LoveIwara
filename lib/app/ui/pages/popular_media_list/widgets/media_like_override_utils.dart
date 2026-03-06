bool shouldResetLikeOverride({
  required String oldId,
  required String newId,
  required bool? oldLiked,
  required bool? newLiked,
  required int? oldLikeCount,
  required int? newLikeCount,
}) {
  if (oldId != newId) return true;
  return oldLiked != newLiked || oldLikeCount != newLikeCount;
}
