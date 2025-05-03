class AGiXTWhisperModel {
  String name;

  static List<String> models = [
    'tiny',
    'base',
    'small',
    'medium',
    'large',
  ];

  AGiXTWhisperModel(this.name);

  // This class has been simplified since we no longer use WhisperModel
  // from whisper_ggml package
  get model => name;
  
  // Speech recognition accuracy level mapping
  get accuracyLevel {
    switch (name) {
      case 'tiny':
        return 0.2; // Low accuracy
      case 'base':
        return 0.4; // Basic accuracy
      case 'small':
        return 0.6; // Medium accuracy
      case 'medium':
        return 0.8; // Good accuracy
      case 'large':
        return 1.0; // Highest accuracy
      default:
        return 0.4; // Default to base
    }
  }
}
