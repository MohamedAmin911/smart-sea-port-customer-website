import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

class PaymobPaymentDialog extends StatefulWidget {
  final String paymentUrl;
  final Function(bool) onCompletion;

  const PaymobPaymentDialog({
    Key? key,
    required this.paymentUrl,
    required this.onCompletion,
  }) : super(key: key);

  @override
  State<PaymobPaymentDialog> createState() => _PaymobPaymentDialogState();
}

class _PaymobPaymentDialogState extends State<PaymobPaymentDialog> {
  late final html.IFrameElement _iframeElement;
  late final StreamSubscription<html.Event> _messageSubscription;
  late String _viewId; // Store the view ID

  @override
  void initState() {
    super.initState();
    _viewId = 'paymob-iframe-${DateTime.now().millisecondsSinceEpoch}';
    _initializeIframe();
    _setupMessageListener();
  }

  void _initializeIframe() {
    _iframeElement = html.IFrameElement()
      ..src = widget.paymentUrl
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow = 'payment';

    // Register the view before building
    ui.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) => _iframeElement,
    );
  }

  void _setupMessageListener() {
    _messageSubscription = html.window.onMessage.listen((event) {
      if (event.origin != Uri.parse(widget.paymentUrl).origin) return;

      final url = event.data.toString();
      debugPrint('Payment URL changed: $url');

      if (url.contains('success=true')) {
        widget.onCompletion(true);
        Get.back();
      } else if (url.contains('failed=true') || url.contains('canceled=true')) {
        widget.onCompletion(false);
        Get.back();
      }
    });
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    _iframeElement.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: SizedBox(
        width: Get.width * 0.9,
        height: Get.height * 0.8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      widget.onCompletion(false);
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: HtmlElementView(
                viewType: _viewId, // Use the stored view ID
                key: UniqueKey(), // Important for widget rebuilds
              ),
            ),
          ],
        ),
      ),
    );
  }
}
