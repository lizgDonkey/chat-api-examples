import 'package:flutter/material.dart';

class InputTextWidget extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final void Function(String)? onChange;

  const InputTextWidget({
    this.hintText,
    this.controller,
    this.keyboardType,
    this.onChange,
    this.maxLines = 1,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
      ),
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: 1,
      onChanged: onChange,
    );
  }
}

class Button extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;

  const Button({
    required this.title,
    this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blue),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
          ),
        ));
  }
}

class TextScrollView extends StatelessWidget {
  final ScrollController? controller;

  const TextScrollView({
    this.controller,
    this.textList,
    Key? key,
  }) : super(key: key);

  final List<String>? textList;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      itemBuilder: (_, index) {
        return Text(textList![index]);
      },
      itemCount: textList?.length ?? 0,
    );
  }
}
