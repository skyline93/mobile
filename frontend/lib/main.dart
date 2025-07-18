// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gbox/data/repositories/video_repository.dart';
import 'package:gbox/data/services/api_services.dart';
import 'package:gbox/ui/video/view_model/video_view_model.dart';
import 'package:gbox/ui/video/widgets/home_screen.dart';

/// The main entry point for the application.
void main() {
  // runApp inflates the given widget and attaches it to the screen.
  runApp(const VideoPlatformApp());
}

/// The root widget of the application.
///
/// This widget is responsible for setting up the dependency injection using
/// `MultiProvider`, which makes services and view models available to the
/// entire widget tree. It also configures the top-level `MaterialApp`.
class VideoPlatformApp extends StatelessWidget {
  const VideoPlatformApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MultiProvider is used to provide multiple objects down the widget tree.
    // This is the core of our dependency injection setup.
    return MultiProvider(
      providers: [
        // --- DATA LAYER PROVIDERS ---
        // These providers are responsible for data fetching and handling.

        // 1. ApiService: A singleton service that handles raw HTTP communication.
        // It has no dependencies, so we use a simple `Provider`.
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),

        // 2. VideoRepository: Depends on ApiService to fetch data.
        // `ProxyProvider` is used here to create an instance of VideoRepository
        // whenever its dependency (ApiService) is available.
        ProxyProvider<ApiService, VideoRepository>(
          update: (_, apiService, __) => VideoRepository(apiService),
        ),

        // --- UI LAYER (VIEW_MODEL) PROVIDERS ---
        // These providers manage the state and business logic for the UI.

        // 3. VideoViewModel: A `ChangeNotifier` that depends on VideoRepository.
        // It orchestrates data fetching for the UI and holds the UI state.
        // `ChangeNotifierProxyProvider` rebuilds the ViewModel if its dependency changes
        // and also makes it available for UI widgets to listen to.
        ChangeNotifierProxyProvider<VideoRepository, VideoViewModel>(
          create: (context) => VideoViewModel(context.read<VideoRepository>()),
          update: (_, videoRepository, previousViewModel) =>
              VideoViewModel(videoRepository),
        ),
      ],
      // The `MaterialApp` widget is the root of our UI.
      child: MaterialApp(
        title: 'Video Platform MVP',
        debugShowCheckedModeBanner:
            false, // Hides the debug banner in development
        theme: ThemeData(
          // Define a consistent color scheme for the app.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,

          // Define a theme for the AppBar for consistency.
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            elevation: 4,
          ),

          // Define a theme for the FloatingActionButton.
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
        ),
        // The `HomeScreen` is the initial screen of our application.
        home: const HomeScreen(),
      ),
    );
  }
}
