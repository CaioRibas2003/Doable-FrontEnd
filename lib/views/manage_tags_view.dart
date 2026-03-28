import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/tag_controller.dart';

class ManageTagsView extends StatefulWidget {
  const ManageTagsView({super.key});

  @override
  State<ManageTagsView> createState() => _ManageTagsViewState();
}

class _ManageTagsViewState extends State<ManageTagsView> {
  final _nameController = TextEditingController();
  String _selectedColor = '#FF5733';

  final List<String> _colors = [
    '#FF5733', '#33FF57', '#3357FF', '#FF33A8',
    '#FFD700', '#00CED1', '#FF6347', '#8A2BE2',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<TagController>(context, listen: false).findAll());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceAll('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Tags'),
      ),
      body: Consumer<TagController>(
        builder: (context, controller, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da tag',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Cor:'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _colors.map((color) {
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _hexToColor(color),
                              shape: BoxShape.circle,
                              border: _selectedColor == color
                                  ? Border.all(color: Colors.black, width: 3)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_nameController.text.isEmpty) return;
                          await controller.create(
                            _nameController.text,
                            _selectedColor,
                          );
                          _nameController.clear();
                        },
                        child: const Text('Adicionar Tag'),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: controller.tags.isEmpty
                    ? const Center(child: Text('Nenhuma tag criada!'))
                    : ListView.builder(
                        itemCount: controller.tags.length,
                        itemBuilder: (context, index) {
                          final tag = controller.tags[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _hexToColor(tag.color),
                            ),
                            title: Text(tag.name),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => controller.delete(tag.id!),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}