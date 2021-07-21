import 'package:flutter/material.dart';

class DefaultInputDecoration extends InputDecoration {
  final String label;
  final bool isObscured, isPassword;
  final Function() onTap;

  DefaultInputDecoration({ this.label, this.onTap, this.isPassword=false, this.isObscured=false, });

  @override
  InputDecoration applyDefaults(InputDecorationTheme theme) {
    return InputDecoration(
      suffixIcon: isPassword
          ? Padding(
        padding: EdgeInsets.only(right: 12.0),
        child: InkWell(
          child: Icon(
            isObscured
                ? Icons.visibility_off
                : Icons.visibility,
            color: Colors.black,
          ),
          onTap: onTap,
        ),
      )
          : null,
      suffixIconConstraints: BoxConstraints(
        minWidth: 24,
        minHeight: 24,
      ),
      filled: true,
      fillColor: Colors.white,
      labelText: label,
      isCollapsed: true,
      contentPadding: EdgeInsets.all(12.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey.withOpacity(.20),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey.withOpacity(.20),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.blue.withOpacity(.70),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red.withOpacity(.75),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red.withOpacity(.75),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}

class CustomFormTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final Function(String val) validator;
  final bool obscured, readOnly;
  final TextInputType inputType;

  CustomFormTextField({Key key,
    @required this.label, @required this.controller, this.validator,
    this.obscured=false, this.readOnly=false, this.inputType=TextInputType.text,
  }) : super(key: key);

  @override
  _CustomFormTextFieldState createState() => _CustomFormTextFieldState();
}

class _CustomFormTextFieldState extends State<CustomFormTextField> {
  bool _passwordObscured;

  @override
  void initState() {
    _passwordObscured = widget.obscured;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: _passwordObscured,
          readOnly: widget.readOnly,
          keyboardType: widget.inputType,
          decoration: DefaultInputDecoration(
            label: widget.label,
            onTap: () => setState(() => _passwordObscured = !_passwordObscured),
            isPassword: widget.obscured,
            isObscured: _passwordObscured,
          ),
          validator: widget.validator,
        ),
        SizedBox(height: 24.0,),
      ],
    );
  }
}
