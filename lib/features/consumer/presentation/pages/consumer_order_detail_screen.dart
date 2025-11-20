import 'package:deluxe/shared/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ConsumerOrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const ConsumerOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: 'R');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Order #${order.id.substring(0, 8)}'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            _StatusHeader(order: order),

            const SizedBox(height: 16),

            // Order Information Card
            _InfoCard(
              title: 'Order Information',
              children: [
                _InfoRow(
                  label: 'Order ID',
                  value: '#${order.id.substring(0, 8)}',
                ),
                _InfoRow(
                  label: 'Dispensary',
                  value: order.dispensaryName,
                ),
                _InfoRow(
                  label: 'Order Date',
                  value: DateFormat('MMMM dd, yyyy').format(order.createdAt),
                ),
                _InfoRow(
                  label: 'Order Time',
                  value: DateFormat('hh:mm a').format(order.createdAt),
                ),
                _InfoRow(
                  label: 'Status',
                  value: order.status,
                  valueColor: _getStatusColor(order.status),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Order Items
            _InfoCard(
              title: 'Order Items (${order.items.length})',
              children: [
                ...order.items.map((product) => _ProductItem(
                      product: product,
                      currencyFormat: currencyFormat,
                    )),
              ],
            ),

            const SizedBox(height: 16),

            // Order Summary
            _InfoCard(
              title: 'Order Summary',
              children: [
                _InfoRow(
                  label: 'Subtotal',
                  value: 'R${order.totalPrice.toStringAsFixed(2)}',
                ),
                _InfoRow(
                  label: 'Delivery Fee',
                  value: 'R0.00',
                  valueColor: Colors.grey[600],
                ),
                const Divider(height: 24),
                _InfoRow(
                  label: 'Total',
                  value: 'R${order.totalPrice.toStringAsFixed(2)}',
                  labelStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  valueStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Order Timeline
            _OrderTimeline(order: order),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'declined':
        return Colors.red;
      case 'ready for pickup':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class _StatusHeader extends StatelessWidget {
  final OrderModel order;

  const _StatusHeader({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(order.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor,
            statusColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(order.status),
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            order.status,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getStatusMessage(order.status),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'declined':
        return Colors.red;
      case 'ready for pickup':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'accepted':
        return Icons.check_circle;
      case 'declined':
        return Icons.cancel;
      case 'ready for pickup':
        return Icons.inventory_2;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }

  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Your order is being reviewed by the dispensary';
      case 'accepted':
        return 'Your order has been accepted and is being prepared';
      case 'declined':
        return 'Unfortunately, your order was declined';
      case 'ready for pickup':
        return 'Your order is ready! Visit the dispensary to pick it up';
      case 'completed':
        return 'Order completed. Thank you for your purchase!';
      default:
        return 'Order status: $status';
    }
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: labelStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          Text(
            value,
            style: valueStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProductItem extends StatelessWidget {
  final dynamic product;
  final NumberFormat currencyFormat;

  const _ProductItem({
    required this.product,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: product.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: theme.primaryColor.withOpacity(0.1),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: theme.primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.eco,
                        color: theme.primaryColor.withOpacity(0.5),
                      ),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: theme.primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.eco,
                      color: theme.primaryColor.withOpacity(0.5),
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.type,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${product.quantity} × R${product.price.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Line Total
          Text(
            'R${(product.price * product.quantity).toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  final OrderModel order;

  const _OrderTimeline({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final steps = [
      _TimelineStep('Order Placed', Icons.shopping_cart, true),
      _TimelineStep(
          'Accepted', Icons.check_circle, _isStepCompleted('accepted')),
      _TimelineStep('Ready for Pickup', Icons.inventory_2,
          _isStepCompleted('ready for pickup')),
      _TimelineStep('Completed', Icons.done_all, _isStepCompleted('completed')),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Timeline',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == steps.length - 1;

            return _TimelineItem(
              step: step,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  bool _isStepCompleted(String stepStatus) {
    final currentStatus = order.status.toLowerCase();
    final statusOrder = [
      'pending',
      'accepted',
      'ready for pickup',
      'completed'
    ];

    final currentIndex = statusOrder.indexOf(currentStatus);
    final stepIndex = statusOrder.indexOf(stepStatus);

    return currentIndex >= stepIndex;
  }
}

class _TimelineStep {
  final String title;
  final IconData icon;
  final bool isCompleted;

  _TimelineStep(this.title, this.icon, this.isCompleted);
}

class _TimelineItem extends StatelessWidget {
  final _TimelineStep step;
  final bool isLast;

  const _TimelineItem({
    required this.step,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = step.isCompleted ? theme.primaryColor : Colors.grey;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: step.isCompleted
                    ? theme.primaryColor
                    : Colors.grey.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                step.icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: step.isCompleted
                    ? theme.primaryColor
                    : Colors.grey.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              step.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight:
                    step.isCompleted ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
