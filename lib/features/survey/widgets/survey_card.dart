import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/survey_model.dart';

class SurveyCard extends StatelessWidget {
  final SurveyModel survey;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onGenerateInvoice;
  final VoidCallback? onPrint;
  final Future<String?> Function()? onGetInvoicePath;

  const SurveyCard({
    super.key,
    required this.survey,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onGenerateInvoice,
    this.onPrint,
    this.onGetInvoicePath,
  });

  @override
  Widget build(BuildContext context) {
    final hasInvoice = survey.invoiceUrl != null && survey.invoiceUrl!.isNotEmpty;
    final statusColor = _getStatusColor(survey.status);
    final isPaid = survey.pendingPayment <= 0;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tappable area for card details (excludes action buttons)
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          survey.applicantName.isNotEmpty 
                              ? survey.applicantName[0].toUpperCase()
                              : 'S',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              survey.applicantName,
                              style: Theme.of(context).textTheme.titleLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    survey.villageName,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          survey.status.displayName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Info Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          'Survey No.',
                          survey.surveyNumber,
                          Icons.numbers_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          'Mobile',
                          survey.mobileNumber,
                          Icons.phone_outlined,
                          onTap: () => _makePhoneCall(survey.mobileNumber),
                        ),
                      ),
                    ],
                  ),
                  
                  if (survey.surveyDate != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            context,
                            'Date',
                            '${survey.surveyDate!.day}/${survey.surveyDate!.month}/${survey.surveyDate!.year}',
                            Icons.calendar_today_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoItem(
                            context,
                            'Type',
                            survey.surveyType.displayName,
                            Icons.business_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Payment Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPaid ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isPaid ? AppColors.success : AppColors.warning,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPaid ? Icons.check_circle : Icons.pending_actions,
                          color: isPaid ? AppColors.success : AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isPaid ? 'Fully Paid' : 'Pending Payment',
                            style: TextStyle(
                              color: isPaid ? AppColors.success : AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          isPaid ? '₹${survey.totalPayment.toStringAsFixed(0)}' : '₹${survey.pendingPayment.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: isPaid ? AppColors.success : AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Action Buttons - Outside of InkWell to prevent gesture conflicts
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onGenerateInvoice,
                    icon: Icon(
                      hasInvoice ? Icons.receipt_long : Icons.receipt_outlined,
                      size: 16,
                    ),
                    label: Text(hasInvoice ? 'View' : 'Invoice'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    final child = Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: onTap != null ? AppColors.primary : null,
                  decoration: onTap != null ? TextDecoration.underline : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: child,
      );
    }
    return child;
  }

  Color _getStatusColor(SurveyStatus status) {
    switch (status) {
      case SurveyStatus.working:
        return AppColors.primary;
      case SurveyStatus.waiting:
        return AppColors.warning;
      case SurveyStatus.done:
        return AppColors.success;
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}