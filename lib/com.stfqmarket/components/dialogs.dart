import 'package:flutter/material.dart';

class Dialogs {
  /// Loading dialog context, filled after showLoadingDialog was called
  BuildContext loadingDialogCtx;
  /// custom default loading dialog. fill loadingDialogContext after called
  Future<void> showLoadingDialog(BuildContext c) async {
    return showDialog<void>(
      context: c,
      barrierDismissible: false,
      builder: (BuildContext context) {
        loadingDialogCtx = context;
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12.0,),
                Text('Mohon tunggu...'),
              ],
            ),
          ),
        );
      },
    );
  }
}