// lib/screens/suivi_medical/article_screen.dart

import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart';

class ArticleScreen extends StatelessWidget {
  final String title;
  final String imagePath;
  final List<Map<String, String>> content;

  const ArticleScreen({
    super.key,
    required this.title,
    required this.imagePath,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // COUCHE 1 : Le fond en dégradé
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),

          // COUCHE 2 : Le bloc de contenu "vitré"
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              child: Container(
                color: AppTheme.backgroundColor.withOpacity(0.95),
                child: Column(
                  children: [
                    // En-tête personnalisé
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 20, 16, 10),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    // Contenu principal
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(imagePath, fit: BoxFit.cover, height: 220, width: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 220,
                                color: Colors.grey.shade200,
                                child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: content.map((item) {
                                  final String? subtitle = item['subtitle'];
                                  final String? text = item['text'];
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 24.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (subtitle != null)
                                          Text(subtitle, style: Theme.of(context).textTheme.titleLarge),
                                        if (subtitle != null) const SizedBox(height: 8),
                                        if (text != null)
                                          Text(
                                            text,
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
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
        ],
      ),
    );
  }
}