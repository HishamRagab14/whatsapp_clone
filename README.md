# WhatsApp Clone 📱

A modern WhatsApp clone built with Flutter and Firebase, featuring real-time messaging, voice messages, image sharing, stories, and push notifications.

## 📱 Demo

![WhatsApp Clone Demo](assets/demo.gif)

### Screenshots

| Authentication | Chats List | Chat Detail |
|----------------|------------|-------------|
| ![Login](assets/screenshots/login.png) | ![Chats](assets/screenshots/chats.png) | ![Chat](assets/screenshots/chat_detail.png) |

| Stories | Users | Settings |
|---------|-------|----------|
| ![Stories](assets/screenshots/stories.png) | ![Users](assets/screenshots/users.png) | ![Settings](assets/screenshots/settings.png) |

## ✨ Features

- 🔐 **Phone Authentication** - Secure login with OTP verification
- 💬 **Real-time Messaging** - Instant message delivery
- 🎤 **Voice Messages** - Record and send voice messages
- 📸 **Image Sharing** - Send photos in conversations
- 📱 **Stories** - Create and view 24-hour stories
- 🔔 **Push Notifications** - Get notified for new messages and stories
- 👥 **User Management** - Search and manage user profiles
- 🔍 **Search** - Search conversations and users

## 🚀 Quick Start

1. **Clone & Install**
   ```bash
   git clone https://github.com/hishamragab14/whatsapp_clone.git
   cd whatsapp_clone
   flutter pub get
   ```

2. **Firebase Setup**
   - Create Firebase project
   - Enable Authentication, Firestore, Storage, Cloud Messaging
   - Add configuration files

3. **Run**
   ```bash
   flutter run
   ```

## 🛠️ Tech Stack

- **Flutter** - UI Framework
- **Firebase** - Backend (Auth, Firestore, Storage, FCM)
- **GetX** - State Management
- **Dart** - Programming Language

## 🐛 Common Issues

- **"Unknown User"**: Update user data in Firebase
- **Profile Pictures**: Check `profileImageUrl` field
- **Voice Messages**: Allow microphone access
- **Notifications**: Check Firebase Cloud Messaging setup

## 📞 Support

- 📧 Email: your.email@example.com
- 🐛 Issues: [GitHub Issues](https://github.com/hishamragab14/whatsapp_clone/issues)

## 📝 License

MIT License - see [LICENSE](LICENSE) file.

---

⭐ **Star this repository if you found it helpful!**

Made with ❤️ by [Hisham Ragab]
