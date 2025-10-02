import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/community_service.dart';
import 'package:path_provider/path_provider.dart';
import '../models/community_models.dart'; // <-- Import the correct model

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  static const primaryGreen = Color(0xFF4CAF50);
  static const lightGreen = Color(0xFFE8F5E9);
  static const mediumGreen = Color(0xFFA5D6A7);
  static const darkGreen = Color(0xFF2E7D32);

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _postController = TextEditingController();
  final CommunityService _communityService = CommunityService();
  File? _selectedImage;
  String? _selectedCategory;

  String? _selectedFilter; // Add this line for filter state
  List<CommunityPost> _allPosts = []; // Add this line to store all posts

  List<CommunityPost> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final posts = await _communityService.getPosts();
    setState(() {
      _allPosts = List<CommunityPost>.from(posts);
      _filterPosts(); // Apply any existing filter
    });
  }

  void _filterPosts() {
    setState(() {
      if (_selectedFilter == null || _selectedFilter == 'All Posts') {
        _posts = _allPosts;
      } else {
        _posts = _allPosts.where((post) => post.category == _selectedFilter).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Community', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: darkGreen,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _showCategoryFilter();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) => _buildPostCard(_posts[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePostDialog();
        },
        backgroundColor: const Color.fromARGB(255, 215, 255, 183),
        child: const Icon(Icons.add, color: Colors.black87),
      ),
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: mediumGreen,
                  child: Text(post.authorName[0], 
                    style: const TextStyle(color: darkGreen, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _getTimeAgo(post.timestamp),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(post.category),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    post.category,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            Text(post.content),
            if (post.imagePath != null && post.imagePath!.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(post.imagePath!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, 
                            color: Colors.grey[400],
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text('Image not available',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  Icons.thumb_up_outlined,
                  '${post.likes}',
                  post,
                  true
                ),
                _buildActionButton(
                  Icons.comment_outlined,
                  '${post.comments}',
                  post,
                  false
                ),
                _buildActionButton(
                  Icons.share_outlined,
                  'Share',
                  post,
                  false
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Success Story':
        return const Color(0xFF43A047);
      case 'Crop Health':
        return const Color(0xFFD32F2F);
      case 'Market Update':
        return const Color(0xFF1976D2);
      case 'Query':
        return const Color(0xFF7B1FA2);
      case 'Weather Alert':
        return const Color(0xFFEF6C00);
      default:
        return darkGreen;
    }
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    CommunityPost post,
    bool isLikeButton,
  ) {
    return InkWell(
      onTap: isLikeButton ? () async {
        await _communityService.updateLikes(post.id, post.likes + 1);
        await _loadPosts();
      } : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(int timestamp) {
    final postTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(postTime);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showCreatePostDialog() {
    _selectedImage = null;
    _postController.clear();
    _selectedCategory = null;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create Post',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'Success Story',
                    'Crop Health',
                    'Market Update',
                    'Query',
                    'Weather Alert',
                  ].map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  )).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _postController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Share your farming experience...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedImage != null)
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(() => _selectedImage = null),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Camera'),
                      onPressed: () => _pickImage(ImageSource.camera, setState),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      onPressed: () => _pickImage(ImageSource.gallery, setState),
                    ),
                    ElevatedButton(
                      onPressed: () => _createPost(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 215, 255, 183),
                      ),
                      child: const Text('Post', style: TextStyle(color: Colors.black87)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, StateSetter setState) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _createPost(BuildContext context) async {
    if (_postController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    String? imagePath;
    if (_selectedImage != null) {
      imagePath = await _communityService.saveImage(_selectedImage!);
    }

    final newPost = CommunityPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: 'Current User',
      content: _postController.text,
      imagePath: imagePath,
      timestamp: DateTime.now().millisecondsSinceEpoch, // store as int
      category: _selectedCategory!,
      // likes, comments, commentList can be omitted if default in model
    );

    await _communityService.addPost(newPost);
    await _loadPosts();

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post created successfully!')),
    );
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                'All Posts',
                'Success Story',
                'Crop Health',
                'Market Update',
                'Query',
                'Weather Alert',
              ].map((category) => FilterChip(
                label: Text(category),
                selected: _selectedFilter == category,
                onSelected: (selected) {
                  Navigator.pop(context);
                  setState(() {
                    _selectedFilter = selected ? category : null;
                    _filterPosts();
                  });
                },
                backgroundColor: lightGreen,
                selectedColor: mediumGreen,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
