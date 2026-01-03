enum SaveLocation { appDocuments, downloads, documents }

extension SaveLocationExtension on SaveLocation {
  String get displayName {
    switch (this) {
      case SaveLocation.appDocuments:
        return "App Documents";
      case SaveLocation.documents:
        return "Documents";
      case SaveLocation.downloads:
        return "Downloads";
    }
  }
}
