import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grief12/models/sermon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class SermonVideoScreen extends StatefulWidget {
  final Sermon sermon;

  const SermonVideoScreen({super.key, required this.sermon});

  @override
  State<SermonVideoScreen> createState() => _SermonVideoScreenState();
}

class _SermonVideoScreenState extends State<SermonVideoScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _isBuffering = false;
  static const String _positionKey = 'video_position_';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Create VideoPlayerController based on video URL type
      if (widget.sermon.videoUrl.startsWith('http')) {
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(widget.sermon.videoUrl),
          httpHeaders: {
            'Range': 'bytes=0-', // Enable range requests for better buffering
          },
        );
      } else if (widget.sermon.videoUrl.startsWith('assets/')) {
        _videoPlayerController = VideoPlayerController.asset(widget.sermon.videoUrl);
      } else {
        _videoPlayerController = VideoPlayerController.file(File(widget.sermon.videoUrl));
      }

      await _videoPlayerController!.initialize();

      // Create ChewieController with optimized settings
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        placeholder: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1E88E5),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          );
        },
      );

      // Restore saved position
      final prefs = await SharedPreferences.getInstance();
      final savedPosition = prefs.getInt(_positionKey + widget.sermon.id) ?? 0;
      if (savedPosition > 0) {
        await _videoPlayerController!.seekTo(Duration(milliseconds: savedPosition));
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // Listen to position changes and save them
      _videoPlayerController!.addListener(_saveVideoPosition);

      // Listen to buffering state
      _videoPlayerController!.addListener(() {
        final isBuffering = _videoPlayerController!.value.isBuffering;
        if (mounted && _isBuffering != isBuffering) {
          setState(() {
            _isBuffering = isBuffering;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveVideoPosition() async {
    try {
      if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized) {
        final position = _videoPlayerController!.value.position.inMilliseconds;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_positionKey + widget.sermon.id, position);
      }
    } catch (e) {
      print('Error saving video position: $e');
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(_saveVideoPosition);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sermon',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              Container(
                height: 250,
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1E88E5),
                  ),
                ),
              )
            else if (_chewieController != null)
              Stack(
                children: [
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Chewie(controller: _chewieController!),
                  ),
                  if (_isBuffering)
                    Container(
                      height: 250,
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ),
                ],
              )
            else
              Container(
                height: 250,
                color: Colors.white,
                child: const Center(
                  child: Text(
                    'Error loading video',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.sermon.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.userTie, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            widget.sermon.preacher,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.calendarAlt, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              widget.sermon.date,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(FontAwesomeIcons.clock, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.sermon.duration.inMinutes} min',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.sermon.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}