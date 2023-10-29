## <!-- My Notes is the Flutter/Dart app based on YouTube Tutorial "Free Flutter Course 35+ hours by Vandad Nahavandipoor-->

<a name="readme-top"></a>

<br />
<div align="center">

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- PROJECT LOGO -->
<br />

  <a href="https://github.com/jackharbon/flutter_mynotes">
    <img src="assets/icon/icon.png" alt="My Notes logo" width="300" height="300">
  </a>

<br />

<h1 align="center">MY NOTES</h1>

  <p align="center">
    My Notes is the Flutter/Dart app based on YouTube Tutorial
     <a href="https://www.youtube.com/playlist?list=PL6yRaaP0WPkVtoeNIGqILtRAgd3h2CNpT">Free Flutter Course 35+ hours</a> by Vandad Nahavandipoor.<br /> November 2023.
    <br />
    <br />
</div>
<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ul>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#app-description">App Description</a></li>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ul>
</details>
<br />
<br />

<!-- ABOUT THE PROJECT -->

# About The Project

## App Description

Learning Fluttter/Dart | App based on YT tutorial 'Free Flutter Course'.

## Built With

<div align="center">

| Coding                                           | Back-end                                  | Front-end                              |
| ------------------------------------------------ | ----------------------------------------- | -------------------------------------- |
| planning, version control, code editing          | database, authentication, environment     | framework and language                 |
| [![GitHub][github.com]][github-url]              | [![Node.js][nodejs.org]][nodejs-url]      | [![Flutter][flutter.dev]][flutter-url] |
| [![VSC][visualstudiocode]][visualstudiocode-url] | [![Firebase][firebase.com]][firebase-url] | [![Dart][dart.dev]][dart-url]          |

</div>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->

# Getting Started

Feel free to test the app for yourself (excluding commercial purposes).

## Prerequisites

To run the app you need a few pieces of software. The installation process will depend on your computer operating system (Linux, Mac OS, MS Windows), so I have included general instructions, for more detailed steps you need to read the software provider's instructions (docs) for the specific system. And also I DO NOT recommend using [WSL](https://learn.microsoft.com/en-us/windows/wsl/about) (Windows Subsystem for Linux), because of the problems with Android emulation, as WSL does not support GUI applications and SDK for Windows do not work with WSL.

Install necessary software:

- JavaScript runtime environment [Node.js](https://nodejs.org/en/).
- Source code editor like [Visual Studio Code](https://code.visualstudio.com/Download).
- Android SDK with emulator [Android Studio](https://developer.android.com/studio#downloads).
- You may want to install Android phone screen duplicator [scrcpy](https://github.com/Genymobile/scrcpy) (optional) and allow debugging in your phone.
- If you you use physical device to run application, switch off phone screen locking, activate developer options in the phone and check on `Stay awake`.
- You may want to install desktop version of [GitHub](https://desktop.github.com/) (optional).

## Install dependencies

Clone this Github repository and open it in your IDE (f.e. Visual Studio Code)

1. Change your app domain according to the format: `com.example.mynotes` (use you domain instead `com.example`), you can use find && replace IDE tool.

2. Clean dependencies files:

`flutter clean android`

3. Type those commands in the terminal:

```
flutter pub add cupertino_icons

flutter pub add firebase_core

flutter pub add firebase_auth

flutter pub add firebase_analytics

flutter pub add cloud_firestore

flutter pub add sqflite

flutter pub add path

flutter pub add path_provider

flutter pub add equatable

flutter pub add intl

flutter pub add bloc

flutter pub add flutter_bloc

flutter pub add flutter_launcher_icons

flutter pub add test

flutter pub add share_plus

```

(`share_plus` may be a cause of error duplicated Sdk)

You can also edit 'pubspec.yaml' and paste those dependencies (don't forget to include a current version - check on: [pub.dev](https://pub.dev/packages)).

3. Enable multidex support - modify `android/app/build.gradle`. See [StackOverflow](https://stackoverflow.com/questions/49886597/multidex-issue-with-flutter) for details.

```
android {
    defaultConfig {
        multiDexEnabled true
    }
}
```

```
dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
    implementation(platform("com.google.firebase:firebase-bom:32.4.0"))
    implementation("com.google.firebase:firebase-firestore-ktx")
}
```

## Install Firebase tools, create a Firestore database project and configure the project

Type 5 commands in a terminal:

```
curl -sL https://firebase.tools | bash
firebase login
firebase projects:list
dart pub global activate flutterfire_cli
flutterfire configure -> create project -> chose Android
firebase init -> choose Firebase and Cloud configuration
```

You can check file `lib/firebase_options`.

Help: [Add Firebase to your Flutter app](https://firebase.google.com/docs/flutter/setup?platform=android)

In the [Google Console](https://console.firebase.google.com/) go to Get Started -> Authentication -> Sign-up method -> Native providers -> Email/Password -> Enable.

## Add Cloud Firestore to your project

Go to [Firebase Console](https://console.firebase.google.com/)

Open `Firestore Database` from the left menu

Switch to the `Native` mode

Click `Start Collection` to start

Open the tab `Rules`, change permission read/write to `request.auth != null`

```
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Help:[Get started with Cloud Firestore](https://firebase.google.com/docs/firestore/quickstart#kotlin+ktx)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->

# Roadmap

- [ ] Login/register page
- [ ] Notes

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# License

App is under GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007.

See <a href="https://github.com/jackharbon/flutter_mynotes/blob/main/LICENSE">`LICENSE.txt` </a> for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->

# Contact

## Jacek Harbon

LinkedIn: [@jgharbon](https://www.linkedin.com/in/jgharbon/)

website: [harbon.uk](https://harbon.uk)

email: jacek@harbon.uk

Mastodon: [@jacekharbon](https://mastodon.social/@jacekharbon)

Project Link: [https://github.com/jackharbon/flutter_mynotes](https://github.com/jackharbon/flutter_mynotes)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->

# Acknowledgments

- [Node.js](https://nodejs.org/en/)
- [NPM.js](https://www.npmjs.com/)
- [Fluter](https://flutter.dev/)
- [Dart](https://dart.dev/guides/language/language-tour)
- [Dart Pad](https://www.dartpad.dev/?)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Android Studio](https://developer.android.com/studio)
- [Material Design](https://m3.material.io/)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/jackharbon/flutter_mynotes.svg?style=for-the-badge
[contributors-url]: https://github.com/jackharbon/flutter_mynotes/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/jackharbon/flutter_mynotes.svg?style=for-the-badge
[forks-url]: https://github.com/jackharbon/flutter_mynotes/network/members
[stars-shield]: https://img.shields.io/github/stars/jackharbon/flutter_mynotes.svg?style=for-the-badge
[stars-url]: https://github.com/jackharbon/flutter_mynotes/stargazers
[issues-shield]: https://img.shields.io/github/issues/jackharbon/flutter_mynotes.svg?style=for-the-badge
[issues-url]: https://github.com/jackharbon/flutter_mynotes/issues
[license-shield]: https://img.shields.io/github/license/jackharbon/flutter_mynotes.svg?style=for-the-badge
[license-url]: https://github.com/jackharbon/flutter_mynotes/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/jgharbon/
[product-screenshot]: images/screenshot.png
[github.com]: https://img.shields.io/badge/GitHub-000000?style=for-the-badge&logo=github&logoColor=white
[github-url]: https://github.com/
[flutter.dev]: https://img.shields.io/badge/flutter-1A1744?style=for-the-badge&logo=flutter&logoColor=45C9FA
[flutter-url]: https://flutter.dev
[dart.dev]: https://img.shields.io/badge/dart-838383?style=for-the-badge&logo=dart&logoColor=055A9D
[dart-url]: https://dart.dev
[firebase.com]: https://img.shields.io/badge/firebase-039BE6?style=for-the-badge&logo=firebase&logoColor=FFA611
[firebase-url]: https://firebase.com/
[nodejs.org]: https://img.shields.io/badge/node.js-7EBB00?style=for-the-badge&logo=nodedotjs&logoColor=313429
[nodejs-url]: https://nodejs.org/
[visualstudiocode]: https://img.shields.io/badge/visualstudio-3CA4EA?style=for-the-badge&logo=visualstudio&logoColor=white
[visualstudiocode-url]: https://code.visualstudio.com
