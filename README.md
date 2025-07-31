# SAM__messenger
Sam-Messenger is an intelligent, real-time web messaging app built with Flutter Web, powered by Firebase for authentication and storage, and integrated with local LLMs (via Ollama + Gradio) to enable AI-driven conversations — all without relying on external APIs like OpenAI.


# 💬 Sam-Messenger

**Sam-Messenger** is a real-time web-based messaging application built using **Flutter Web**, integrated with **Firebase** for user authentication and database storage. It also features an optional **AI chatbot powered by local LLMs using Ollama and Gradio**, enabling private, intelligent conversations without relying on third-party APIs like OpenAI.

---

## 🚀 Features

- 🔐 **Firebase Authentication** (Email login)
- 💬 **One-on-one real-time messaging**
- 🧠 **AI chatbot** powered by Ollama + Gradio (no external API calls)
- 🌍 **Fully responsive web UI** built with Flutter
- 📁 **Firestore integration** for chat data storage
- 🧑‍💻 **Local LLM execution** with privacy and speed

---

## 🛠️ Tech Stack

- **Frontend**: Flutter Web (Dart)
- **Backend**: Firebase (Authentication + Firestore)
- **AI Integration**: Python + Gradio + Ollama (for LLM)
- **Deployment**: Gradio public URL for LLM | Firebase Hosting for Web

---

## 🌐 Live Demo

🔗 Gradio AI Chatbot: [Try it here](https://1dd78a9ce8bab3825a.gradio.live)

*(Frontend deployment link can be added here if available)*

---

## 📸 Screenshots

*(Add screenshots of your UI and chatbot here)*

---

## 📦 Folder Structure

sam-messenger/
├── lib/ # Flutter frontend code
├── gradio_backend/ # Python backend with Ollama + Gradio
├── assets/ # App assets (icons/images)
├── firebase.json # Firebase configuration
├── pubspec.yaml # Flutter dependencies
└── README.md # Project documentation

yaml
Copy
Edit

---

## 🔧 Setup Instructions

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/your-username/sam-messenger.git
cd sam-messenger
2️⃣ Run the Flutter Web App
bash
Copy
Edit
flutter pub get
flutter run -d chrome
3️⃣ Start the AI Backend (Ollama + Gradio)
Make sure Ollama is installed.

bash
Copy
Edit
cd gradio_backend
ollama run llama2  # Or any model you've downloaded
python app.py
✨ Project Highlights
AI without API keys – uses local models

Real-time updates via Firestore

Secure login system with Firebase Auth

Customizable architecture for future upgrades

📃 License
This project is licensed under the MIT License.

🤝 Contribute
Contributions are welcome! Feel free to fork the repo, open issues, or submit pull requests to improve the project.

🙌 Acknowledgements
Flutter & Dart Team

Firebase by Google

Ollama for local LLM support

Gradio for easy UI wrapper around Python functions

yaml
Copy
Edit

---

Let me know if you'd like to include badges (like GitHub stars, license, build status, etc.) or auto-generate one for each section.







Ask ChatGPT
