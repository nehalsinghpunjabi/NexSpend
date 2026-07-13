import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedPersonaProvider = NotifierProvider<SelectedPersona, String?>(
  SelectedPersona.new,
);

class SelectedPersona extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? persona) => state = persona;
}
