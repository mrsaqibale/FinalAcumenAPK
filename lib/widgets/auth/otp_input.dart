import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPInput extends StatefulWidget {
  final Function(String) onCompleted;
  final int length;

  const OTPInput({
    super.key,
    required this.onCompleted,
    this.length = 4,
  });

  @override
  State<OTPInput> createState() => _OTPInputState();
}

class _OTPInputState extends State<OTPInput> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  String _otp = '';

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
    
    // Auto-focus when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 0,
          width: 0,
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(widget.length),
            ],
            onChanged: (value) {
              setState(() {
                _otp = value;
              });
              if (value.length == widget.length) {
                widget.onCompleted(value);
              }
            },
          ),
        ),
        
        GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(_focusNode),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              widget.length,
              (index) => Column(
                children: [
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      index < _otp.length ? _otp[index] : '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 40,
                    height: 3,
                    color: index < _otp.length ? AppTheme.primaryColor : Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
} 
