import 'package:flutter/material.dart';
import 'package:per_habit/features/habit/services/habit_service.dart';
import 'package:per_habit/features/room/services/room_service.dart';
import 'package:per_habit/features/habit/models/habit_model.dart';
import 'package:per_habit/features/room/models/room_model.dart';

class LugarDetalleScreen extends StatefulWidget {
  final Lugar lugar;
  final List<Lugar> lugares;
  final Function setState;
  final int selectedIndex;
  final Function(int) scrollToSelected;

  const LugarDetalleScreen({
    super.key,
    required this.lugar,
    required this.lugares,
    required this.setState,
    required this.selectedIndex,
    required this.scrollToSelected,
  });

  @override
  State<LugarDetalleScreen> createState() => _LugarDetalleScreenState();
}

class _LugarDetalleScreenState extends State<LugarDetalleScreen> {
  late List<MascotaHabito> _mascotas;
  final LugarService _lugarService = LugarService();
  final MascotaHabitoService _mascotaHabitoService = MascotaHabitoService();

  @override
  void initState() {
    super.initState();
    _mascotas = List.from(widget.lugar.mascotas);
  }

  void _addHabito() {
    _mascotaHabitoService.addHabito(
      context: context,
      mascotas: _mascotas,
      lugar: widget.lugar,
      setState: setState,
    );
  }

  void _updatePosition(MascotaHabito habito, Offset newPosition) {
    setState(() {
      habito.position = newPosition;
      widget.lugar.mascotas = _mascotas;
    });
  }

  void _editHabito(MascotaHabito habito) {
    _mascotaHabitoService.updateHabito(
      context: context,
      habito: habito,
      mascotas: _mascotas,
      lugar: widget.lugar,
      setState: setState,
    );
  }

  void _deleteHabito(MascotaHabito habito) {
    _mascotaHabitoService.deleteHabito(
      context: context,
      habito: habito,
      mascotas: _mascotas,
      lugar: widget.lugar,
      setState: setState,
    );
  }

  void _showHabitoDetails(MascotaHabito habito) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(habito.nombre),
          content: Text(
            '${habito.nombre} is a ${habito.petType.description} with ${habito.personality.description} who loves ${habito.mechanic.description}',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _editLugar() {
    _lugarService.updateLugar(
      context: context,
      lugar: widget.lugar,
      lugares: widget.lugares,
      setState: widget.setState,
      selectedIndex: widget.selectedIndex,
      scrollToSelected: widget.scrollToSelected,
    );
  }

  void _deleteLugar() {
    _lugarService.deleteLugar(
      context: context,
      lugar: widget.lugar,
      lugares: widget.lugares,
      setState: widget.setState,
      selectedIndex: widget.selectedIndex,
      scrollToSelected: widget.scrollToSelected,
    );
    Navigator.of(context).pop();
  }

  void _inviteMember() {
    _lugarService.addMember(
      context: context,
      lugar: widget.lugar,
      lugares: widget.lugares,
      setState: widget.setState,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lugar.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _inviteMember,
            tooltip: 'Invitar Miembro',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editLugar,
            tooltip: 'Editar Lugar',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteLugar,
            tooltip: 'Eliminar Lugar',
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.category_rounded, size: 100),
                const SizedBox(height: 20),
                Text('Detalles de "${widget.lugar.nombre}"'),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text('Añadir Hábito'),
                  onPressed: _addHabito,
                ),
                const SizedBox(height: 20),
                if (_mascotas.isEmpty)
                  const Text(
                    'Aquí se mostrarán las mascotas (hábitos) de este lugar.',
                  ),
              ],
            ),
          ),
          ..._mascotas.map((habito) {
            return Positioned(
              left: habito.position.dx,
              top: habito.position.dy,
              child: GestureDetector(
                onTap: () => _showHabitoDetails(habito),
                onPanUpdate: (details) {
                  _updatePosition(
                    habito,
                    Offset(
                      (habito.position.dx + details.delta.dx).clamp(
                        0,
                        MediaQuery.of(context).size.width - 150,
                      ),
                      (habito.position.dy + details.delta.dy).clamp(
                        0,
                        MediaQuery.of(context).size.height - 150,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        habito.nombre,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        habito.petType.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        habito.personality.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        habito.mechanic.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 16),
                            onPressed: () => _editHabito(habito),
                            tooltip: 'Editar Hábito',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 16),
                            onPressed: () => _deleteHabito(habito),
                            tooltip: 'Eliminar Hábito',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
