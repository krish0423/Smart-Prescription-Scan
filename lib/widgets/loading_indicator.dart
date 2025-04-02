import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;

  const LoadingIndicator({Key? key, this.message, this.color, this.size = 24.0})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final indicatorColor =
        color ??
        (Platform.isIOS
            ? CupertinoTheme.of(context).primaryColor
            : Theme.of(context).primaryColor);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Platform.isIOS
              ? CupertinoActivityIndicator(
                radius: size / 2,
                color: indicatorColor,
              )
              : SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
                ),
              ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                color:
                    Platform.isIOS
                        ? CupertinoTheme.of(context).textTheme.textStyle.color
                        : Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
