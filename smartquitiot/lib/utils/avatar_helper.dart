/// Helper function to format avatar URL
/// Adds &format=url parameter for ui-avatars.com URLs
String formatAvatarUrl(String? url) {
  if (url == null || url.isEmpty) {
    return '';
  }

  // Check if URL is from ui-avatars.com
  if (url.contains('ui-avatars.com')) {
    // Check if format=url already exists (with ? or &)
    if (url.contains('format=url')) {
      return url;
    }
    // Add &format=url to the URL
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}format=url';
  }

  // Return original URL if not from ui-avatars.com
  return url;
}

