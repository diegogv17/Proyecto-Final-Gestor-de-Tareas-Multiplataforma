import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/core/animations/page_transitions.dart';
import 'package:flutter_application_1/features/auth/presentation/auth_screen.dart';
import 'package:flutter_application_1/features/categories/presentation/categories_screen.dart';
import 'package:flutter_application_1/features/tasks/presentation/home_screen.dart';
import 'package:flutter_application_1/features/tasks/presentation/task_detail_screen.dart';
import 'package:flutter_application_1/features/tasks/presentation/task_form_screen.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';

abstract final class AppRoutes {
  static const auth = '/';
  static const home = '/home';
  static const taskCreate = '/tasks/create';
  static const taskEdit = '/tasks/:id/edit';
  static const taskDetail = '/tasks/:id';
  static const categories = '/categories';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.auth,
    refreshListenable: _AuthRefreshListenable(ref),
    redirect: (context, state) {
      final isLoggedIn = ref.read(authStateProvider) != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.auth;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.auth;
      if (isLoggedIn && isAuthRoute) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.auth,
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const AuthScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.taskCreate,
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const TaskFormScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.taskEdit,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return slideTransitionPage(
            key: state.pageKey,
            child: TaskFormScreen(taskId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.taskDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return slideTransitionPage(
            key: state.pageKey,
            child: TaskDetailScreen(taskId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.categories,
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const CategoriesScreen(),
        ),
      ),
    ],
  );
});

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this.ref) {
    ref.listen<UserModel?>(authStateProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
}
