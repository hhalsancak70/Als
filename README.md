# Hobby - Hobi Paylaşım Uygulaması

<div align="center">
  <img src="Images/Hobi.png" alt="Hobby App Logo" width="200"/>
</div>

## 📝 Proje Hakkında | About the Project

**🇹🇷 Türkçe**

Hobby, kullanıcıların hobilerini paylaşabilecekleri, benzer ilgi alanlarına sahip kişilerle iletişim kurabilecekleri ve hobi ürünlerini alıp satabilecekleri kapsamlı bir mobil uygulamadır. Uygulama, Flutter kullanılarak geliştirilmiş olup, Firebase altyapısı ile desteklenmektedir.

**🇬🇧 English**

Hobby is a comprehensive mobile application where users can share their hobbies, connect with people who have similar interests, and buy/sell hobby-related products. The application is developed using Flutter and supported by Firebase infrastructure.

## 🚀 Özellikler | Features

**🇹🇷 Türkçe**

- **Kullanıcı Yönetimi**: Kayıt olma, giriş yapma ve profil yönetimi
- **Sosyal Paylaşım**: Hobi paylaşımları, bloglar ve yorumlar
- **Mesajlaşma**: Kullanıcılar arası özel mesajlaşma
- **Alışveriş**: Hobi ürünlerinin alım-satımı
- **Bildirimler**: Gerçek zamanlı bildirimler
- **Haber Akışı**: Hobilerle ilgili güncel haberler
- **Karanlık/Aydınlık Tema**: Kullanıcı tercihine göre tema seçimi

**🇬🇧 English**

- **User Management**: Registration, login, and profile management
- **Social Sharing**: Hobby posts, blogs, and comments
- **Messaging**: Private messaging between users
- **Shopping**: Buying and selling hobby products
- **Notifications**: Real-time notifications
- **News Feed**: Current news related to hobbies
- **Dark/Light Theme**: Theme selection according to user preference

## 🛠️ Teknolojiler | Technologies

**🇹🇷 Türkçe**

- **Flutter**: UI geliştirme
- **Firebase**: 
  - Authentication: Kullanıcı kimlik doğrulama
  - Firestore: Veritabanı
  - Storage: Dosya depolama
  - Messaging: Bildirimler
  - App Check: Güvenlik
- **Provider**: Durum yönetimi
- **Image Picker**: Görsel seçimi
- **Shared Preferences**: Yerel veri saklama
- **Flutter Local Notifications**: Yerel bildirimler

**🇬🇧 English**

- **Flutter**: UI development
- **Firebase**: 
  - Authentication: User authentication
  - Firestore: Database
  - Storage: File storage
  - Messaging: Notifications
  - App Check: Security
- **Provider**: State management
- **Image Picker**: Image selection
- **Shared Preferences**: Local data storage
- **Flutter Local Notifications**: Local notifications

## 📋 Gereksinimler | Requirements

**🇹🇷 Türkçe**

- Flutter SDK 3.5.4 veya üzeri
- Dart SDK 3.5.4 veya üzeri
- Firebase hesabı
- Android Studio / VS Code

**🇬🇧 English**

- Flutter SDK 3.5.4 or higher
- Dart SDK 3.5.4 or higher
- Firebase account
- Android Studio / VS Code

## 🔧 Kurulum | Installation

**🇹🇷 Türkçe**

1. Repoyu klonlayın:
   ```bash
   git clone https://github.com/hhalsancak70/hobby.git
   ```

2. Bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```

3. Firebase yapılandırmasını tamamlayın:
   - Firebase konsolunda yeni bir proje oluşturun
   - Android ve iOS uygulamalarını kaydedin
   - google-services.json ve GoogleService-Info.plist dosyalarını ilgili klasörlere yerleştirin

4. Uygulamayı çalıştırın:
   ```bash
   flutter run
   ```

**🇬🇧 English**

1. Clone the repository:
   ```bash
   git clone https://github.com/hhalsancak70/hobby.git
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Complete Firebase configuration:
   - Create a new project in Firebase console
   - Register Android and iOS applications
   - Place google-services.json and GoogleService-Info.plist files in the relevant folders

4. Run the application:
   ```bash
   flutter run
   ```

## 📁 Proje Yapısı | Project Structure

**🇹🇷 Türkçe**

```
lib/
├── main.dart                # Ana uygulama girişi
├── Screens/                 # Uygulama ekranları
│   ├── Intro.dart           # Giriş ekranı
│   ├── SignIn.dart          # Giriş yapma ekranı
│   ├── Register.dart        # Kayıt olma ekranı
│   ├── Home.dart            # Ana sayfa
│   ├── Profile.dart         # Profil sayfası
│   ├── Blogging.dart        # Blog sayfası
│   └── ...                  # Diğer ekranlar
├── Models/                  # Veri modelleri
│   ├── hobby_model.dart     # Hobi modeli
│   └── product_model.dart   # Ürün modeli
├── Model/                   # Uygulama modelleri
│   ├── theme_notifier.dart  # Tema yönetimi
│   └── ...                  # Diğer modeller
├── Services/                # Servisler
│   └── services.dart        # API servisleri
└── Widgets/                 # Yeniden kullanılabilir bileşenler
    └── hobby_selection_dialog.dart # Hobi seçim diyaloğu
```

**🇬🇧 English**

```
lib/
├── main.dart                # Main application entry
├── Screens/                 # Application screens
│   ├── Intro.dart           # Introduction screen
│   ├── SignIn.dart          # Sign in screen
│   ├── Register.dart        # Registration screen
│   ├── Home.dart            # Home page
│   ├── Profile.dart         # Profile page
│   ├── Blogging.dart        # Blog page
│   └── ...                  # Other screens
├── Models/                  # Data models
│   ├── hobby_model.dart     # Hobby model
│   └── product_model.dart   # Product model
├── Model/                   # Application models
│   ├── theme_notifier.dart  # Theme management
│   └── ...                  # Other models
├── Services/                # Services
│   └── services.dart        # API services
└── Widgets/                 # Reusable components
    └── hobby_selection_dialog.dart # Hobby selection dialog
```

## 📱 Ekran Görüntüleri | Screenshots

**🇹🇷 Türkçe**

*Screenshots dosyasına eklendi*

**🇬🇧 English**

*Screenshots file added*

## 🤝 Katkıda Bulunma | Contributing

**🇹🇷 Türkçe**

1. Projeyi fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some amazing feature'`)
4. Branch'inize push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

**🇬🇧 English**

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 Lisans | License

**🇹🇷 Türkçe**

Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır.

**🇬🇧 English**

This project is licensed under the [MIT License](LICENSE).

## 📞 İletişim | Contact

**🇹🇷 Türkçe**

Proje Sahibi - [@hhalsancak70](https://github.com/hhalsancak70) - alsancak0370@gmail.com and [@Erenakdogan](https://github.com/Erenakdogan) - erenakdogan11@outlook.com

Proje Linki: [https://github.com/hhalsancak70/als](https://github.com/hhalsancak70/Hobby)

**🇬🇧 English**

Project Owner - [@hhalsancak70](https://github.com/hhalsancak70) - alsancak0370@gmail.com and [@Erenakdogan](https://github.com/Erenakdogan) - erenakdogan11@outlook.com

Project Link: [https://github.com/hhalsancak70/als](https://github.com/hhalsancak70/Hobby)
