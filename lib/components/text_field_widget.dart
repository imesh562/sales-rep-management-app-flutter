import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  final int maxLines;
  final String label;
  final String text;
  final ValueChanged<String> onChanged;
  final IconData icon;
  const TextFieldWidget({
    Key? key,
    this.maxLines = 1,
    required this.label,
    required this.text,
    required this.onChanged,
    required this.icon,
  }) : super(key: key);

  @override
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: mediaData.size.height * 0.025,
            fontFamily: 'Exo2',
            color: Color(0xFF158E85),
          ),
        ),
        SizedBox(
          height: mediaData.size.height * 0.005,
        ),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: widget.label == 'Full Name'
              ? (value) {
                  if (value!.isEmpty) {
                    return "Name is required";
                  } else if (value.length < 3) {
                    return "Name should have at least 3 characters.";
                  } else {
                    return null;
                  }
                }
              : (value) {
                  bool mobileValid =
                      RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)').hasMatch(value!);
                  if (value.isEmpty) {
                    return "Mobile Number is required";
                  } else if (!mobileValid) {
                    return "Please enter a valid mobile number";
                  } else {
                    return null;
                  }
                },
          keyboardType: widget.label == 'Full Name'
              ? TextInputType.name
              : TextInputType.phone,
          maxLength: widget.label == 'Full Name' ? 24 : 10,
          style: TextStyle(
            fontFamily: 'Exo2',
            fontSize: 18.0,
            color: Color(0xFF158E85),
          ),
          controller: controller,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            counterText: "",
            suffixIcon: Icon(
              widget.icon,
              color: Color(0xFF158E85),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
