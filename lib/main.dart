import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class CreditCardAutofillScreen extends StatefulWidget {
  @override
  _CreditCardAutofillScreenState createState() =>
      _CreditCardAutofillScreenState();
}

class _CreditCardAutofillScreenState extends State<CreditCardAutofillScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Credit Card Autofill'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: InactiveFocusScopeObserver(
            child: Column(
              children: [
                SizedBox(height: 200),
                Divider(),
                AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Card Number'),
                          autofillHints: [AutofillHints.creditCardNumber],
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter the card number';
                            } else if (value.length < 16) {
                              return 'Card number must be at least 16 digits';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          decoration:
                              InputDecoration(labelText: 'Cardholder Name'),
                          autofillHints: [AutofillHints.name],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter the cardholder name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Expiration Date (MM/YY)'),
                          autofillHints: [
                            AutofillHints.creditCardExpirationDate
                          ],
                          keyboardType: TextInputType.datetime,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter the expiration date';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'CVV'),
                          autofillHints: [AutofillHints.creditCardSecurityCode],
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter the CVV';
                            } else if (value.length < 3) {
                              return 'CVV must be at least 3 digits';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Call finishAutofillContext when you're done
                            TextInput.finishAutofillContext();
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Processing Data')),
                              );
                            } else {
                              print("Form validation failed");
                            }
                          },
                          child: Text('Submit'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CreditCardAutofillScreen(),
  ));
}

/// for flutter version before 3.24 this hack for return focus after resume app lifecycle
class InactiveFocusScopeObserver extends StatefulWidget {
  final Widget child;

  const InactiveFocusScopeObserver({
    super.key,
    required this.child,
  });

  @override
  State<InactiveFocusScopeObserver> createState() =>
      _InactiveFocusScopeObserverState();
}

class _InactiveFocusScopeObserverState
    extends State<InactiveFocusScopeObserver> {
  final FocusScopeNode _focusScope = FocusScopeNode();

  AppLifecycleListener? _listener;
  FocusNode? _lastFocusedNode;

  @override
  void initState() {
    _registerListener();

    super.initState();
  }

  @override
  Widget build(BuildContext context) => FocusScope(
        node: _focusScope,
        child: widget.child,
      );

  @override
  void dispose() {
    _listener?.dispose();
    _focusScope.dispose();

    super.dispose();
  }

  void _registerListener() {
    /// optional if you want this workaround for any platform and not just for android
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    _listener = AppLifecycleListener(
      onInactive: () {
        _lastFocusedNode = _focusScope.focusedChild;
      },
      onResume: () {
        _lastFocusedNode = null;
      },
    );

    _focusScope.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (_lastFocusedNode?.hasFocus == false) {
      _lastFocusedNode?.requestFocus();
      _lastFocusedNode = null;
    }
  }
}
