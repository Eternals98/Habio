import 'package:flutter/material.dart';

class CreateRoomDialog extends StatefulWidget {
  const CreateRoomDialog({super.key});

  /// Muestra el diálogo y retorna el nombre ingresado (o null si se cancela).
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const CreateRoomDialog(),
    );
  }

  @override
  State<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nombre del lugar'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: 'Ej: Estudio, Sala...'),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isNotEmpty) {
              Navigator.pop(context, name);
            }
          },
          child: const Text('Crear'),
        ),
      ],
    );
  }
}
