import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'services/background_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize background service
  BackgroundService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const GalleryScreen(),
    );
  }
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  // List of image asset paths
  // IMPORTANT: Add your actual images to assets/images/ directory
  static const List<String> _imagePaths = [
    'assets/images/nature_1.jpg',
    'assets/images/nature_2.jpg',
    'assets/images/city_1.jpg',
    'assets/images/city_2.jpg',
    'assets/images/abstract_1.jpg',
    'assets/images/abstract_2.jpg',
    'assets/images/landscape_1.jpg',
    'assets/images/landscape_2.jpg',
    'assets/images/architecture_1.jpg',
    'assets/images/architecture_2.jpg',
    'assets/images/sunset_1.jpg',
    'assets/images/sunset_2.jpg',
    'assets/images/mountain_1.jpg',
    'assets/images/mountain_2.jpg',
    'assets/images/ocean_1.jpg',
    'assets/images/ocean_2.jpg',
    'assets/images/forest_1.jpg',
    'assets/images/forest_2.jpg',
  ];

  void _openImageViewer(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ImageViewerScreen(
          images: _imagePaths,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: _imagePaths.length,
          itemBuilder: (context, index) {
            return _GalleryItem(
              imagePath: _imagePaths[index],
              onTap: () => _openImageViewer(index),
            );
          },
        ),
      ),
    );
  }
}

class _GalleryItem extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const _GalleryItem({
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Placeholder if image not found
              return Container(
                color: Colors.grey[800],
                child: const Icon(
                  Icons.image,
                  color: Colors.grey,
                  size: 40,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ImageViewerScreen extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  const _ImageViewerScreen({
    required this.images,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: AssetImage(images[index]),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 50,
                ),
              );
            },
          );
        },
        itemCount: images.length,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}

