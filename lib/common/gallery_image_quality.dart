// Normalizes persisted gallery image quality values.
//
// Only the lowercase strings 'standard' and 'original' are considered valid.
// Any unknown / null / non-string input falls back to 'standard'.

const String galleryImageQualityStandard = 'standard';
const String galleryImageQualityOriginal = 'original';

String normalizeGalleryImageQuality(dynamic raw) {
  if (raw is String) {
    if (raw == galleryImageQualityOriginal) {
      return galleryImageQualityOriginal;
    }
    if (raw == galleryImageQualityStandard) {
      return galleryImageQualityStandard;
    }
  }

  return galleryImageQualityStandard;
}
