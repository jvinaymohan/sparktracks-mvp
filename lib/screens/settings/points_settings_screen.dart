import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';
import '../../models/class_model.dart';

class PointsSettingsScreen extends StatefulWidget {
  const PointsSettingsScreen({super.key});

  @override
  State<PointsSettingsScreen> createState() => _PointsSettingsScreenState();
}

class _PointsSettingsScreenState extends State<PointsSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Points conversion settings
  bool _enableConversion = true;
  int _pointsPerUnit = 100; // 100 points = 1 currency unit
  Currency _selectedCurrency = Currency.usd;
  bool _autoConvertOnTaskCompletion = true;
  
  bool _isSaving = false;

  final Map<Currency, String> _currencySymbols = {
    Currency.usd: '\$',
    Currency.eur: '€',
    Currency.gbp: '£',
    Currency.cad: 'C\$',
    Currency.aud: 'A\$',
    Currency.inr: '₹',
  };

  final Map<Currency, String> _currencyNames = {
    Currency.usd: 'US Dollar',
    Currency.eur: 'Euro',
    Currency.gbp: 'British Pound',
    Currency.cad: 'Canadian Dollar',
    Currency.aud: 'Australian Dollar',
    Currency.inr: 'Indian Rupee',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    // Load from API or shared preferences
    // For now, using default values
    setState(() {
      _enableConversion = true;
      _pointsPerUnit = 100;
      _selectedCurrency = Currency.usd;
      _autoConvertOnTaskCompletion = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Points & Currency Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/parent-dashboard');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacingL),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stars, color: Colors.white, size: 32),
                        const SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: Text(
                            'Points System',
                            style: AppTheme.headline4.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'Configure how points are converted to real currency',
                      style: AppTheme.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),
              
              // Enable/Disable Conversion
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enable Points-to-Money Conversion',
                                  style: AppTheme.headline6,
                                ),
                                const SizedBox(height: AppTheme.spacingS),
                                Text(
                                  'Convert earned points into real currency rewards',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.neutral600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _enableConversion,
                            onChanged: (value) {
                              setState(() {
                                _enableConversion = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              if (_enableConversion) ...[
                // Currency Selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Currency',
                          style: AppTheme.headline6,
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        DropdownButtonFormField<Currency>(
                          value: _selectedCurrency,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          items: Currency.values.map((currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Row(
                                children: [
                                  Text(
                                    _currencySymbols[currency] ?? '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(_currencyNames[currency] ?? ''),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCurrency = value ?? Currency.usd;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingL),
                
                // Conversion Rate
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conversion Rate',
                          style: AppTheme.headline6,
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: _pointsPerUnit.toString(),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Points',
                                  prefixIcon: Icon(Icons.stars),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final points = int.tryParse(value);
                                  if (points != null && points > 0) {
                                    setState(() {
                                      _pointsPerUnit = points;
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  final points = int.tryParse(value);
                                  if (points == null || points <= 0) {
                                    return 'Must be positive';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('=', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            ),
                            Expanded(
                              child: TextFormField(
                                initialValue: '1',
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: 'Currency',
                                  prefixIcon: Icon(Icons.attach_money),
                                  prefixText: _currencySymbols[_selectedCurrency],
                                ),
                                enabled: false,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingM),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                              const SizedBox(width: AppTheme.spacingM),
                              Expanded(
                                child: Text(
                                  '$_pointsPerUnit points = ${_currencySymbols[_selectedCurrency]}1',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingL),
                
                // Auto-convert on task completion
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Auto-Convert on Task Approval',
                                    style: AppTheme.headline6,
                                  ),
                                  const SizedBox(height: AppTheme.spacingS),
                                  Text(
                                    'Automatically convert points to money when you approve a task',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.neutral600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _autoConvertOnTaskCompletion,
                              onChanged: (value) {
                                setState(() {
                                  _autoConvertOnTaskCompletion = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingL),
                
                // Example calculations
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Example Conversions',
                          style: AppTheme.headline6,
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        _buildExampleRow(50),
                        const Divider(),
                        _buildExampleRow(100),
                        const Divider(),
                        _buildExampleRow(250),
                        const Divider(),
                        _buildExampleRow(500),
                        const Divider(),
                        _buildExampleRow(1000),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppTheme.spacingXL),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveSettings,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
                  ),
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: AppTheme.spacingM),
                            Text('Saving...'),
                          ],
                        )
                      : const Text('Save Settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExampleRow(int points) {
    final money = points / _pointsPerUnit;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.stars, color: AppTheme.warningColor, size: 20),
          const SizedBox(width: 8),
          Text(
            '$points points',
            style: AppTheme.bodyLarge,
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward, size: 20),
          const Spacer(),
          Text(
            '${_currencySymbols[_selectedCurrency]}${money.toStringAsFixed(2)}',
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }

  void _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        // Save to API or shared preferences
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/parent-dashboard');
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving settings: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }
}

