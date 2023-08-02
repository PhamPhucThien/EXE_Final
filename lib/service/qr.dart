
import 'dart:convert';

import 'package:flutter/material.dart';

class QR extends StatelessWidget {
  final String qrCodeDataURL;

  const QR({required this.qrCodeDataURL});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code'),
      ),
      body: Center(
        child: Image.memory(
          base64Decode(qrCodeDataURL.split(',').last),
        ),
      ),
    );
  }
}
