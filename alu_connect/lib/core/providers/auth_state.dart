import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

// Streams Supabase auth events – the router and UI listen to this
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// Convenience: is there a live session right now?
final isLoggedInProvider = Provider<bool>((ref) {
  final auth = ref.watch(authStateProvider);
  return auth.when(
    data: (state) => state.session != null,
    loading: () => Supabase.instance.client.auth.currentSession != null,
    error: (_, __) => false,
  );
});

// The current Supabase User (null when signed out)
final currentUserProvider = Provider<User?>((ref) {
  final auth = ref.watch(authStateProvider);
  return auth.when(
    data: (state) => state.session?.user,
    loading: () => Supabase.instance.client.auth.currentUser,
    error: (_, __) => null,
  );
});

// Full UserModel from the profiles table – Member 2 populates this
// Once Member 2 wires up the profile fetch, replace the AsyncValue.data stub
final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final data = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle();

  if (data == null) return null;
  return UserModel.fromJson(data);
});
