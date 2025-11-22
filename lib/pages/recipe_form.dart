import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/recipe_service.dart';
import '../services/storage_service.dart';

// --- COLORS ---
const Color _colorCreamBackground = Color(0xFFFFEDBF);
const Color _colorCardBeige = Color(0xFFFFCD74);
const Color _colorAccent = Color(0xFF9B2948);
const Color _colorInputText = Color(0xFF6A5A69);

class RecipeForm extends StatefulWidget {
  final String currentUsername;
  final Map<String, dynamic>? initialData; // null for create
  final Future<void> Function(Map<String, dynamic> data) onSubmit;
  final bool isEdit;

  const RecipeForm({
    required this.currentUsername,
    required this.onSubmit,
    this.initialData,
    this.isEdit = false,
    super.key,
  });

  @override
  State<RecipeForm> createState() => _RecipeFormState();
}

class _RecipeFormState extends State<RecipeForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _categoryController;
  late TextEditingController _ingredientsController;
  late TextEditingController _stepsController;

  File? _imageFile;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  final StorageService _storageService = StorageService();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.initialData?['title'] ?? '');
    _descController =
        TextEditingController(text: widget.initialData?['description'] ?? '');
    _categoryController =
        TextEditingController(text: widget.initialData?['category'] ?? '');
    _ingredientsController = TextEditingController(
        text: widget.initialData?['ingredients']?.join('\n') ?? '');
    _stepsController = TextEditingController(
        text: widget.initialData?['steps']?.join('\n') ?? '');
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() => _imageBytes = bytes);
      } else {
        setState(() => _imageFile = File(picked.path));
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    String imageUrl = widget.initialData?['imageUrl'] ?? '';

    try {
      if (_imageBytes != null) {
        imageUrl =
        await _storageService.uploadBytes(_imageBytes!, widget.currentUsername);
      } else if (_imageFile != null) {
        imageUrl =
        await _storageService.uploadImage(_imageFile!, widget.currentUsername);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image upload failed: $e")),
      );
      setState(() => loading = false);
      return;
    }

    final data = {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'category': _categoryController.text.trim(),
      'ingredients': _ingredientsController.text.trim().split('\n'),
      'steps': _stepsController.text.trim().split('\n'),
      'imageUrl': imageUrl,
      'owner': widget.currentUsername,
      'createdAt': widget.initialData?['createdAt'] ?? DateTime.now(),
    };

    await widget.onSubmit(data);

    if (mounted) Navigator.pop(context);
  }

  Widget _buildInputField(
      {required TextEditingController controller,
        required String labelText,
        int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: _colorInputText),
        validator: (v) => v!.isEmpty ? 'Please enter $labelText' : null,
        decoration: InputDecoration(
          labelText: labelText,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: _colorInputText.withOpacity(0.4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: _colorInputText.withOpacity(0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: _colorAccent, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: kIsWeb
                  ? Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _imageBytes != null
                    ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                    : (widget.initialData?['imageUrl'] != null &&
                    widget.initialData!['imageUrl'] != '')
                    ? Image.network(widget.initialData!['imageUrl'],
                    fit: BoxFit.cover)
                    : const Icon(Icons.add_a_photo,
                    size: 50, color: Colors.white),
              )
                  : _imageFile != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(_imageFile!,
                    height: 180, width: double.infinity, fit: BoxFit.cover),
              )
                  : (widget.initialData?['imageUrl'] != null &&
                  widget.initialData!['imageUrl'] != '')
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(widget.initialData!['imageUrl'],
                    height: 180, width: double.infinity, fit: BoxFit.cover),
              )
                  : Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.add_a_photo,
                    size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            _buildInputField(controller: _titleController, labelText: "Title"),
            _buildInputField(controller: _descController, labelText: "Description"),
            _buildInputField(controller: _categoryController, labelText: "Category"),
            _buildInputField(
                controller: _ingredientsController,
                labelText: "Ingredients (one per line)",
                maxLines: 3),
            _buildInputField(
                controller: _stepsController,
                labelText: "Steps (one per line)",
                maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: loading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _colorAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 6,
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  widget.isEdit ? "Update Recipe" : "Save Recipe",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
