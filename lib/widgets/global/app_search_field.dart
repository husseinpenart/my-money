import 'package:flutter/material.dart';

class AppSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onCleared;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final bool isLoading;
  final Color accentColor;

  const AppSearchField({
    super.key,
    required this.onChanged,
    this.controller,
    this.hintText = 'جستجو...',
    this.onCleared,
    this.onSubmitted,
    this.autofocus = true,
    this.isLoading = false,
    this.accentColor = const Color.fromARGB(255, 83, 109, 255),
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        textInputAction: TextInputAction.search,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: const TextStyle(fontFamily: 'sans', fontSize: 14),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(fontFamily: 'sans', color: Colors.grey.shade400),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: widget.isLoading
              ? Padding(
                  padding: const EdgeInsets.all(14),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.accentColor,
                    ),
                  ),
                )
              : Icon(Icons.search, color: widget.accentColor),
          suffixIcon: hasText
              ? IconButton(
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                    widget.onCleared?.call();
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: widget.accentColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}
