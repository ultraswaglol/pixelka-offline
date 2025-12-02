import 'package:flutter_gemma/flutter_gemma.dart';

class ModelDefinition {
  final String modelUrl;
  final String modelFilename;
  final String displayName;
  final ModelType modelType;
  ModelDefinition({
    required this.modelUrl,
    required this.modelFilename,
    required this.displayName,
    this.modelType = ModelType.gemmaIt,
  });
}
