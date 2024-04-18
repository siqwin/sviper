import 'package:code_builder/code_builder.dart';

extension CBTypeReferenceExtension on TypeReference {
  TypeReference unbound() {
    return rebuild(
      (t) => t
        ..bound = null
        ..types.map((st) => st is TypeReference ? st.unbound() : st),
    );
  }

  TypeReference removeUrl() {
    return rebuild((t) => t..url = null);
  }
}
