import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/config/app_config.dart';
import '../../../data/models/survey_model.dart';
import '../../../data/repositories/survey_repository.dart';
import '../../../providers/survey_provider.dart';
import '../../../providers/invoice_provider.dart';

class InvoiceScreen extends ConsumerStatefulWidget {
  final String surveyId;

  const InvoiceScreen({
    super.key,
    required this.surveyId,
  });

  @override
  ConsumerState<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends ConsumerState<InvoiceScreen> {
  SurveyModel? _survey;
  bool _isLoadingSurvey = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadSurvey();
  }

  Future<void> _loadSurvey() async {
    setState(() {
      _isLoadingSurvey = true;
      _loadError = null;
    });

    try {
      SurveyModel? survey;
      
      // Use demo data or repository based on mode
      if (AppConfig.useDemoMode) {
        survey = DemoSurveyData.getSurveyById(widget.surveyId);
      } else {
        final repository = ref.read(surveyRepositoryProvider);
        if (repository != null) {
          survey = await repository.getSurveyById(widget.surveyId);
        } else {
          survey = DemoSurveyData.getSurveyById(widget.surveyId);
        }
      }
      
      setState(() {
        _survey = survey;
        _isLoadingSurvey = false;
      });
    } catch (e) {
      setState(() {
        _loadError = e.toString();
        _isLoadingSurvey = false;
      });
    }
  }

  Future<void> _handleGenerateInvoice() async {
    if (_survey == null) return;
    await ref.read(invoiceProvider.notifier).generateInvoice(_survey!);
  }

  Future<void> _handleDownloadInvoice() async {
    if (_survey == null || _survey!.id == null) return;
    // Use saveInvoiceLocally method which saves the PDF to local storage
    await ref.read(invoiceProvider.notifier).saveInvoiceLocally(_survey!.id!);
  }

  Future<void> _handleShareInvoice() async {
    if (_survey == null || _survey!.id == null) return;
    // Get shareable file path and share it
    final filePath = await ref.read(invoiceProvider.notifier).getShareableFilePath(_survey!.id!);
    if (filePath != null) {
      await Share.shareXFiles([XFile(filePath)], text: 'Invoice for Survey ${_survey!.surveyNumber}');
    }
  }

  Future<void> _handleUploadInvoice() async {
    if (_survey == null || _survey!.id == null) return;
    // uploadInvoice takes only surveyId
    await ref.read(invoiceProvider.notifier).uploadInvoice(_survey!.id!);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final invoiceState = ref.watch(invoiceProvider);

    // Listen for state changes
    ref.listen<InvoiceState>(invoiceProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(invoiceProvider.notifier).clearError();
      }
      
      // Check for successful download (localFilePath set and not loading)
      if (previous?.localFilePath == null && next.localFilePath != null && !next.isDownloading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.invoiceDownloaded),
            backgroundColor: AppColors.success,
          ),
        );
      }
      
      // Check for successful upload (downloadUrl set and not uploading)
      if (previous?.downloadUrl == null && next.downloadUrl != null && !next.isUploading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.invoiceUploaded),
            backgroundColor: AppColors.success,
          ),
        );
        // Refresh survey list to show updated invoice URL
        ref.read(surveyListProvider.notifier).refresh();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.invoice),
      ),
      body: _buildBody(loc, invoiceState),
    );
  }

  Widget _buildBody(AppLocalizations loc, InvoiceState invoiceState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoadingSurvey) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              loc.errorLoadingSurvey,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadSurvey,
              icon: const Icon(Icons.refresh),
              label: Text(loc.retry),
            ),
          ],
        ),
      );
    }

    if (_survey == null) {
      return Center(
        child: Text(loc.surveyNotFound),
      );
    }

    if (_survey!.status != SurveyStatus.done) {
      return _buildNotDoneState(loc, isDark);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Survey Summary Card
          _buildSurveyCard(loc, isDark),
          const SizedBox(height: 24),

          // Invoice Status
          if (invoiceState.pdfBytes != null)
            _buildInvoiceReadyCard(loc, invoiceState, isDark)
          else
            _buildGenerateCard(loc, invoiceState, isDark),

          const SizedBox(height: 24),

          // Action Buttons
          if (invoiceState.pdfBytes != null) ...[
            _buildActionButtons(loc, invoiceState, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildNotDoneState(AppLocalizations loc, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hourglass_empty_outlined,
                size: 64,
                color: isDark ? AppColors.darkStatusWaiting : AppColors.warning,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              loc.invoiceNotAvailable,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              loc.surveyMustBeDone,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(_survey!.status, isDark).withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${loc.currentStatus}: ${_survey!.status.displayName}',
                style: TextStyle(
                  color: _getStatusColor(_survey!.status, isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(SurveyStatus status, bool isDark) {
    switch (status) {
      case SurveyStatus.working:
        return isDark ? AppColors.darkStatusWorking : AppColors.info;
      case SurveyStatus.waiting:
        return isDark ? AppColors.darkStatusWaiting : AppColors.warning;
      case SurveyStatus.done:
        return isDark ? AppColors.darkStatusDone : AppColors.success;
    }
  }

  Widget _buildSurveyCard(AppLocalizations loc, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  loc.surveyDetails,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Divider(height: 24, color: isDark ? AppColors.darkDivider : AppColors.divider),
            _buildDetailRow(loc.surveyNumber, _survey!.surveyNumber, isDark),
            _buildDetailRow(loc.applicantName, _survey!.applicantName, isDark),
            _buildDetailRow(loc.villageName, _survey!.villageName, isDark),
            _buildDetailRow(loc.totalPayment, '₹${_survey!.totalPayment.toStringAsFixed(2)}', isDark),
            _buildDetailRow(loc.receivedPayment, '₹${_survey!.receivedPayment.toStringAsFixed(2)}', isDark),
            _buildDetailRow(loc.pendingPayment, '₹${_survey!.pendingPayment.toStringAsFixed(2)}', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateCard(AppLocalizations loc, InvoiceState invoiceState, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              loc.generateInvoice,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              loc.generateInvoiceDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: invoiceState.isGenerating ? null : _handleGenerateInvoice,
                icon: invoiceState.isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.receipt_long),
                label: Text(invoiceState.isGenerating ? loc.generating : loc.generateInvoice),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceReadyCard(AppLocalizations loc, InvoiceState invoiceState, bool isDark) {
    final successColor = isDark ? AppColors.darkStatusDone : AppColors.success;
    
    return Card(
      color: AppColors.success.withValues(alpha: isDark ? 0.15 : 0.1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: isDark ? 0.3 : 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 48,
                color: successColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              loc.invoiceReady,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: successColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              loc.invoiceReadyDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations loc, InvoiceState invoiceState, bool isDark) {
    final successColor = isDark ? AppColors.darkStatusDone : AppColors.success;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Download Button
        ElevatedButton.icon(
          onPressed: invoiceState.isDownloading ? null : _handleDownloadInvoice,
          icon: invoiceState.isDownloading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
          label: Text(invoiceState.isDownloading ? loc.downloading : loc.downloadInvoice),
        ),
        const SizedBox(height: 12),

        // Share Button
        OutlinedButton.icon(
          onPressed: invoiceState.isLoading ? null : _handleShareInvoice,
          icon: const Icon(Icons.share),
          label: Text(loc.shareInvoice),
        ),
        const SizedBox(height: 12),

        // Upload Button
        // OutlinedButton.icon(
        //   onPressed: invoiceState.isUploading ? null : _handleUploadInvoice,
        //   icon: invoiceState.isUploading
        //       ? const SizedBox(
        //           width: 20,
        //           height: 20,
        //           child: CircularProgressIndicator(strokeWidth: 2),
        //         )
        //       : const Icon(Icons.cloud_upload_outlined),
        //   label: Text(invoiceState.isUploading ? loc.uploading : loc.uploadInvoice),
        // ),

        // Show uploaded URL if available
        if (invoiceState.downloadUrl != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: successColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_done, color: successColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    loc.invoiceUploaded,
                    style: TextStyle(
                      color: successColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Regenerate Button
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: invoiceState.isGenerating ? null : () {
            ref.read(invoiceProvider.notifier).reset();
          },
          icon: const Icon(Icons.refresh),
          label: Text(loc.regenerateInvoice),
        ),
      ],
    );
  }
}
