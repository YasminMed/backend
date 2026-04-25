// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:skillora/firebase_options.dart';
import 'package:skillora/providers/auth_provider.dart';

void main() {
  testWidgets('Register User Script', (WidgetTester tester) async {
    // We don't need UI, just execute the logic
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    
    final authProvider = AuthProvider();
    final email = "dania.osama.2421_hpiq.ext@talabat.com";
    final password = "Password123!"; // Default temporary password
    
    print("Attempting to register user: \$email");
    
    final error = await authProvider.signUpWithEmailAndPassword(email, password);
    
    if (error == null) {
      print("Successfully registered \$email!");
    } else if (error == 'email-already-in-use') {
      print("User \$email is already registered.");
    } else {
      print("Failed to register: \$error");
    }
  });
}

