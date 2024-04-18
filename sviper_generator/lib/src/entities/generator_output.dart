import 'dart:io';

class GeneratorOutput {
  final File file;
  final String code;
  final bool isBuildStepResult;

  GeneratorOutput(this.file, this.code, this.isBuildStepResult);
}
