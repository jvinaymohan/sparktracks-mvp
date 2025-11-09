import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

/// Universal wizard scaffold for multi-step forms
/// Used by task creation, class creation, profile setup, etc.
class WizardScaffold extends StatelessWidget {
  final String title;
  final int currentStep;
  final int totalSteps;
  final String stepTitle;
  final String stepDescription;
  final Widget stepContent;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String nextButtonLabel;
  final bool isNextEnabled;
  final bool isLastStep;
  final bool showProgress;

  const WizardScaffold({
    Key? key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitle,
    required this.stepDescription,
    required this.stepContent,
    this.onBack,
    this.onNext,
    this.nextButtonLabel = 'Next',
    this.isNextEnabled = true,
    this.isLastStep = false,
    this.showProgress = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          if (showProgress) _buildProgressIndicator(),
          
          // Step content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step number
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Step $currentStep of $totalSteps',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Step title
                  Text(
                    stepTitle,
                    style: AppTheme.headline5.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Step description
                  Text(
                    stepDescription,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.neutral600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Step-specific content
                  stepContent,
                ],
              ),
            ),
          ),
          
          // Navigation buttons
          _buildNavigationButtons(context),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.neutral50,
        border: Border(
          bottom: BorderSide(color: AppTheme.neutral200, width: 1),
        ),
      ),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final stepNumber = index + 1;
          final isCompleted = stepNumber < currentStep;
          final isActive = stepNumber == currentStep;
          final isFuture = stepNumber > currentStep;

          return Expanded(
            child: Row(
              children: [
                // Step indicator
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.successColor
                        : isActive
                            ? AppTheme.primaryColor
                            : AppTheme.neutral300,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text(
                            stepNumber.toString(),
                            style: TextStyle(
                              color: isActive || isCompleted
                                  ? Colors.white
                                  : AppTheme.neutral600,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
                
                // Connecting line (if not last)
                if (index < totalSteps - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: isCompleted
                          ? AppTheme.successColor
                          : AppTheme.neutral300,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          if (onBack != null)
            TextButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          else
            const SizedBox.shrink(),
          
          // Next/Publish button
          ElevatedButton.icon(
            onPressed: isNextEnabled ? onNext : null,
            icon: Icon(isLastStep ? Icons.check_circle : Icons.arrow_forward),
            label: Text(isLastStep ? 'Publish' : nextButtonLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              disabledBackgroundColor: AppTheme.neutral300,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

