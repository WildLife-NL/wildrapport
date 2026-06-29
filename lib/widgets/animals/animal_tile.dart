import 'package:flutter/material.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_model.dart';

class AnimalTile extends StatefulWidget {
  final AnimalModel animal;
  final VoidCallback onTap;
  final bool isSelected;
  final int? selectionNumber;
  final bool isAlreadyInZone;

  const AnimalTile({
    super.key,
    required this.animal,
    required this.onTap,
    this.isSelected = false,
    this.selectionNumber,
    this.isAlreadyInZone = false,
  });

  @override
  State<AnimalTile> createState() => _AnimalTileState();
}

class _AnimalTileState extends State<AnimalTile> {
  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isAlreadyInZone
        ? const Color(0xFF8AA882)
        : widget.isSelected
            ? const Color(0xFF4CAF50)
            : const Color.fromARGB(64, 0, 0, 0);
    final borderWidth = widget.isAlreadyInZone || widget.isSelected ? 3.0 : 1.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: borderColor,
                  width: borderWidth,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(14),
                              topRight: Radius.circular(14),
                            ),
                            color: Color(0xFFE6DCCD),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 50,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Geen afbeelding',
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
                        if (widget.isAlreadyInZone)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.45),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(14),
                                topRight: Radius.circular(14),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    height: 1,
                    color: borderColor,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: widget.isAlreadyInZone
                          ? const Color(0xFFE8ECE6)
                          : widget.isSelected
                              ? const Color(0xFFF0F4ED)
                              : Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    child: Text(
                      widget.animal.animalName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: widget.isAlreadyInZone || widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: widget.isAlreadyInZone
                            ? const Color(0xFF5A6B55)
                            : widget.isSelected
                                ? const Color(0xFF2E7D32)
                                : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            if (widget.isAlreadyInZone)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'In zone',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (widget.isSelected &&
                widget.selectionNumber != null &&
                !widget.isAlreadyInZone)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${widget.selectionNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
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
        debugPrint(
          '[AnimalTile] Error loading image: ${widget.animal.animalImagePath}',
        );
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