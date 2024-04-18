import 'package:sviper_generator/src/extensions/string_extension.dart';

class GeneratorOptions {
  final String prefix;
  final String suffix;
  final String prefixBase;
  final String suffixBase;
  final String? routerClassName;
  final String? routerClassPath;
  final String? testFolder;

  final String input;
  final String output;
  final String view;
  final String state;
  final String presenter;
  final String interactor;
  final String router;
  final String contracts;
  final String module;
  final String configuration;

  GeneratorOptions(Map<String, dynamic> config)
      : prefix = config["interface_prefix"] as String? ?? "I",
        suffix = config["interface_suffix"] as String? ?? "",
        prefixBase = config["base_prefix"] as String? ?? "",
        suffixBase = config["base_suffix"] as String? ?? "Base",
        routerClassName = config["router_class_name"] as String?,
        routerClassPath = config["router_class_path"] as String?,
        testFolder = config["test_folder"] as String?,
        input = (config["name_input"] as String? ?? "Input").cap,
        output = (config["name_output"] as String? ?? "Output").cap,
        view = (config["name_view"] as String? ?? "View").cap,
        state = (config["name_model"] as String? ?? "State").cap,
        presenter = (config["name_presenter"] as String? ?? "Presenter").cap,
        interactor = (config["name_interactor"] as String? ?? "Interactor").cap,
        router = (config["name_router"] as String? ?? "Router").cap,
        contracts = (config["name_contracts"] as String? ?? "Contracts").cap,
        module = (config["name_module"] as String? ?? "").cap,
        configuration = "Configuration" {
    if (prefix.isEmpty && suffix.isEmpty) {
      throw Exception("Options 'interface_prefix' and 'interface_suffix' couldn't be empty together");
    }
    if (prefixBase.isEmpty && suffixBase.isEmpty) {
      throw Exception("Options 'base_prefix' and 'base_suffix' couldn't be empty together");
    }
    if (prefix == prefixBase && suffix == suffixBase) {
      throw Exception("Options 'base_prefix' and 'base_suffix' couldn't be equals to 'interface_prefix' and 'interface_suffix'");
    }
  }
}
