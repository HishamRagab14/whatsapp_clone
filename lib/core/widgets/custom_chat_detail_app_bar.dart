import 'package:flutter/material.dart';

class CustomChatDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomChatDetailAppBar({
    super.key,
    required this.imageUrl,
    required this.name,
  });

  final String imageUrl;
  final String name;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: imageUrl.startsWith('http')
                ? NetworkImage(imageUrl)
                : AssetImage(imageUrl) as ImageProvider,
            onBackgroundImageError: (exception, stackTrace) {
              // في حالة فشل تحميل الصورة، استخدم الصورة الافتراضية
            },
          ),
          SizedBox(width: 20),
          Text(name),
        ],
      ),
      actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))],
    );
  }
}
