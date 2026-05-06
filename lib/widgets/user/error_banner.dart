import 'package:flutter/material.dart';

class ErrorBanner extends StatelessWidget {
  final String? error;
  final VoidCallback? onRetry;
  final bool isOffline;

  const ErrorBanner({
    super.key,
    this.error,
    this.onRetry,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    if (error == null && !isOffline) {
      return const SizedBox.shrink();
    }

    final message = isOffline
        ? 'Offline — data mungkin tidak terbaru'
        : error ?? 'Terjadi kesalahan';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isOffline ? Colors.orange.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isOffline ? Colors.orange.shade200 : Colors.red.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isOffline ? Icons.cloud_off_outlined : Icons.error_outline,
              color: isOffline ? Colors.orange.shade700 : Colors.red.shade700,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isOffline ? Colors.orange.shade700 : Colors.red.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onRetry,
                child: Text(
                  'Coba lagi',
                  style: TextStyle(
                    color: isOffline ? Colors.orange.shade700 : Colors.red.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
