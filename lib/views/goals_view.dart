import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/goal_controller.dart';
import '../controllers/tag_controller.dart';
import '../models/goal_model.dart';

class GoalsView extends StatefulWidget {
  const GoalsView({super.key});

  @override
  State<GoalsView> createState() => _GoalsViewState();
}

class _GoalsViewState extends State<GoalsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<GoalController>(context, listen: false).findAll();
      Provider.of<TagController>(context, listen: false).findAll();
    });
  }

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '10');
    int selectedPeriod = 7;
    int? selectedTagId;

    showDialog(
      context: context,
      builder: (ctx) {
        final tagController = Provider.of<TagController>(ctx, listen: false);

        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Nova Meta'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Título da meta',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: targetCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade de tasks',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Período:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 7, label: Text('7 dias')),
                      ButtonSegment(value: 15, label: Text('15 dias')),
                      ButtonSegment(value: 30, label: Text('30 dias')),
                    ],
                    selected: {selectedPeriod},
                    onSelectionChanged: (v) =>
                        setDialogState(() => selectedPeriod = v.first),
                  ),
                  const SizedBox(height: 12),
                  const Text('Tag (opcional):',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int?>(
                    value: selectedTagId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Qualquer tag')),
                      ...tagController.tags.map(
                        (tag) => DropdownMenuItem(
                          value: tag.id,
                          child: Text(tag.name),
                        ),
                      ),
                    ],
                    onChanged: (v) =>
                        setDialogState(() => selectedTagId = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleCtrl.text.isEmpty) return;
                  final target = int.tryParse(targetCtrl.text) ?? 10;
                  final goalCtrl =
                      Provider.of<GoalController>(context, listen: false);
                  await goalCtrl.create(
                    titleCtrl.text,
                    target,
                    selectedPeriod,
                    selectedTagId,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Criar'),
              ),
            ],
          );
        });
      },
    );
  }

  Color _hexToColor(String hex) =>
      Color(int.parse(hex.replaceAll('#', '0xFF')));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metas')),
      body: Consumer<GoalController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flag_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text('Nenhuma meta criada'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showCreateDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Criar meta'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: controller.goals.length,
            itemBuilder: (_, i) {
              final goal = controller.goals[i];
              return _GoalCard(
                goal: goal,
                hexToColor: _hexToColor,
                onToggle: () => controller.toggleActive(goal),
                onDelete: () => controller.delete(goal.id!),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final Color Function(String) hexToColor;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _GoalCard({
    required this.goal,
    required this.hexToColor,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        ((goal.progressPercent ?? 0) / 100).clamp(0.0, 1.0);
    final achieved = goal.achieved ?? false;
    final tagColor = goal.tagColor != null
        ? hexToColor(goal.tagColor!)
        : Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: goal.active ? null : Colors.grey,
                    ),
                  ),
                ),
                if (achieved)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(Icons.emoji_events,
                        color: Colors.amber, size: 20),
                  ),
                Switch(
                  value: goal.active,
                  onChanged: (_) => onToggle(),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.schedule, size: 13, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${goal.periodDays} dias',
                  style:
                      const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (goal.tagName != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: tagColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      goal.tagName!,
                      style: TextStyle(
                          fontSize: 11,
                          color: tagColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: goal.active ? progress : 0,
                      minHeight: 8,
                      backgroundColor:
                          Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        achieved ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  goal.active
                      ? '${goal.currentCount ?? 0}/${goal.targetCount}'
                      : 'Pausada',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: goal.active
                        ? (achieved ? Colors.green : Colors.blue)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}