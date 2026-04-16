import 'package:flutter/material.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_model.dart';

class AnimalTile extends StatefulWidget {
  final AnimalModel animal;
  final VoidCallback onTap;
  final bool isSelected;

  const AnimalTile({
    super.key,
    required this.animal,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<AnimalTile> createState() => _AnimalTileState();
}

class _AnimalTileState extends State<AnimalTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Card(
          elevation: widget.isSelected ? 4 : 3,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: widget.isSelected 
                  ? const Color(0xFF4CAF50)
                  : const Color.fromARGB(64, 0, 0, 0),
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          color: widget.isSelected ? const Color(0xFFF0F4ED) : Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image area - takes up most of the card
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                    color: const Color(0xFFE6DCCD),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                    child: SizedBox.expand(
                      child: widget.animal.animalImagePath != null
                          ? _buildImageWithFallback()
                          : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 50,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No image',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    ),
                  ),
                ),
              ),
              // Divider line
              Container(
                height: 1,
                color: widget.isSelected 
                    ? const Color(0xFF4CAF50)
                    : const Color.fromARGB(84, 0, 0, 0),
              ),
              // Name area - bottom section with white background
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.isSelected ? const Color(0xFFF0F4ED) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Text(
                  widget.animal.animalName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: widget.isSelected ? const Color(0xFF2E7D32) : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWithFallback() {
    return Image(
      image: AssetImage(widget.animal.animalImagePath!),
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('[AnimalTile] Error loading image: ${widget.animal.animalImagePath}');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image_outlined,
                size: 50,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                'Failed to load',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

