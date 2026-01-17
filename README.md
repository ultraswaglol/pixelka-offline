# Pixelka Offline 

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Gemma](https://img.shields.io/badge/Model-Gemma_2b-orange)
![Local Inference](https://img.shields.io/badge/AI-On--Device-green)

[ 🇬🇧 English ](#-english) | [ 🇷🇺 Русский ](#-russian)

---

<a name="english"></a>
## 🇬🇧 English

**Pixelka Offline** is a secure, private AI chat application that runs entirely on your device. It utilizes the **Google Gemma 2b** model (via `flutter_gemma`) to provide LLM capabilities without requiring an internet connection for inference.

###  Key Features

*   ** Fully Offline:** Chats and AI generation happen locally. No data leaves your device.
*   ** On-Device Inference:** Powered by MediaPipe and GPU acceleration.
*   ** Model Management:** Download and manage LLM weights directly within the app.
*   ** Chat History:** Persistent chat history using **Hive** database.
*   ** Optimized:** Supports background downloading and prevents sleep during model loading.

###  Tech Stack

*   **Framework:** Flutter.
*   **AI Engine:** `flutter_gemma` (MediaPipe GenAI).
*   **Database:** Hive (NoSQL).
*   **State Management:** Provider.
*   **Downloads:** `flutter_downloader` with background support.

###  Getting Started

1.  **Clone the repo:**
    ```bash
    git clone https://github.com/YOUR_USERNAME/pixelka-offline.git
    ```
2.  **Setup Environment:**
    Create a `.env` file based on `.env.example`.
    ```properties
    INTERSTITIAL_AD_ID=your_id
    APP_OPEN_AD_ID=your_id
    HF_TOKEN=optional_token
    ```
3.  **Run:**
    *Note: This app requires a physical device with GPU support (Android/iOS).*
    ```bash
    flutter run --release
    ```

---

<a name="russian"></a>
## 🇷🇺 Русский

**Pixelka Offline** — это безопасный и приватный AI-чат, работающий полностью на вашем устройстве. Приложение использует модель **Google Gemma 2b** (через `flutter_gemma`), что позволяет общаться с нейросетью без интернета.

###  Возможности

*   ** Полный оффлайн:** Генерация текста происходит на телефоне. Ваши данные никуда не отправляются.
*   ** Локальная модель:** Использует GPU телефона для ускорения работы нейросети.
*   ** Менеджер моделей:** Загрузка весов модели (около 1.5 - 2 ГБ) прямо в приложении.
*   ** История чатов:** Сохранение переписок с помощью базы данных **Hive**.
*   ** Оптимизация:** Фоновая загрузка моделей и предотвращение засыпания экрана при инициализации.

###  Стек технологий

*   **Flutter** (Dart).
*   **AI:** `flutter_gemma` (обертка над MediaPipe GenAI).
*   **База данных:** Hive.
*   **State Management:** Provider.

###  Запуск

1.  **Клонируйте репозиторий.**
2.  **Настройте `.env`:** Создайте файл с ключами (см. `.env.example`).
3.  **Запуск:**
    *Приложение требует реальное устройство с GPU. На эмуляторе может работать медленно или не работать вовсе.*
    ```bash
    flutter run --release
    ```


    ###  Download / Скачать

You can download the latest APK from the Releases page.
Скачать последнюю версию APK можно на странице релизов.

[![Download APK](https://img.shields.io/badge/Download-APK-blue?style=for-the-badge&logo=android)](https://github.com/ultraswaglol/pixelka-offline/releases/latest)
