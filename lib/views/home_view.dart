import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/task_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/tag_controller.dart';
import '../widgets/task_tile.dart';
import 'add_task_view.dart';
import 'login_view.dart';
import 'manage_tags_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<TaskController>(context, listen: false).findAll();
      Provider.of<TagController>(context, listen: false).findAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doable'),
        actions: [
          IconButton(
            icon: const Icon(Icons.label),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageTagsView()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthController>(context, listen: false).logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginView()),
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<TaskController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(child: Text(controller.errorMessage!));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar tarefa...',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              controller.search('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) => controller.search(value),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SegmentedButton<TaskFilter>(
                  segments: const [
                    ButtonSegment(
                      value: TaskFilter.all,
                      label: Text('Todas'),
                      icon: Icon(Icons.list),
                    ),
                    ButtonSegment(
                      value: TaskFilter.pending,
                      label: Text('Pendentes'),
                      icon: Icon(Icons.hourglass_empty),
                    ),
                    ButtonSegment(
                      value: TaskFilter.done,
                      label: Text('Concluídas'),
                      icon: Icon(Icons.check_circle),
                    ),
                  ],
                  selected: {controller.currentFilter},
                  onSelectionChanged: (value) =>
                      controller.setFilter(value.first),
                ),
              ),
              Consumer<TagController>(
                builder: (context, tagController, child) {
                  if (tagController.tags.isEmpty) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('Todas'),
                            selected: controller.selectedTagFilter.isEmpty,
                            onSelected: (_) => controller.clearTagFilter(),
                          ),
                          const SizedBox(width: 4),
                          ...tagController.tags.map((tag) {
                            final isSelected = controller.selectedTagFilter
                                .any((t) => t.id == tag.id);
                            final color = Color(
                                int.parse(tag.color.replaceAll('#', '0xFF')));
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: FilterChip(
                                label: Text(tag.name),
                                selected: isSelected,
                                backgroundColor: color.withOpacity(0.3),
                                selectedColor: color.withOpacity(0.7),
                                onSelected: (_) =>
                                    controller.setTagFilter(tag),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: controller.tasks.isEmpty
                    ? const Center(child: Text('Nenhuma tarefa encontrada!'))
                    : ListView.builder(
                        itemCount: controller.tasks.length,
                        itemBuilder: (context, index) {
                          final task = controller.tasks[index];
                          return TaskTile(
                            task: task,
                            onToggle: () => controller.toggleDone(task),
                            onDelete: () => controller.delete(task.id!),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTaskView()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}