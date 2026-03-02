# kemo.ai 🚀
**Built for the AMD Slingshot Hackathon**

## ⚠️ The Problem: The Execution Gap
Current AI models are incredibly smart, but they are trapped behind a chat interface. They act as instruction manuals, leaving you to manually execute complex terminal commands or UI steps. We lose countless hours to manual system setups and troubleshooting because AI cannot safely execute its own advice.

## 💡 The Solution & Impact
kemo.ai bridges the "execution gap" by shifting AI from a passive advisor to an active, secure executor.
* **Killing the Context Switch:** No more bouncing between a browser window and a command prompt to fix PATH variables or install dependencies.
* **Lowering the Barrier to Entry:** Deep OS control and troubleshooting are now accessible in plain English.
* **Next-Gen Automation:** Transforms AI into a secure local agent that automates your system workflow.

## 🛠️ Technology Stack
**Current MVP Stack:**
We needed to move fast for the hackathon, so we prioritized rapid development:
* **Frontend:** Flutter (built as a native desktop app for a smooth UI)
* **Backend:** Python with FastAPI
* **AI Engine:** Google GenAI SDK (translates natural language into system actions)
* **System Control:** Python libraries (`AppOpener`, `psutil`) to monitor the OS and execute tasks.

**Production Stack (Shifting to C++):**
Python is perfect for a rapid MVP, but it's not the long-term plan for deep OS control. To make kemo.ai a secure, low-latency system agent, we are shifting the core execution engine to **C++**. We will keep Python strictly as a lightweight wrapper for AI communication, but C++ will handle the bare-metal system interactions. You just can't rely on Python scripts forever if you want safe, high-performance, and native OS-level access.

## ⚙️ Getting Started (Local Setup)

### Prerequisites
* Flutter SDK
* Python 3.10+
* Google Gemini API Key

### 1. Backend Setup (FastAPI)
Navigate to the backend directory and install the required dependencies:
```bash
cd backend
pip install -r requirements.txt
```
Create a `.env` file in the backend directory and add your API key:
```env
GEMINI_API_KEY=your_api_key_here
```
Run the FastAPI server:
```bash
uvicorn main:app --reload
```

### 2. Frontend Setup (Flutter)
Open a new terminal, navigate to the frontend directory, and run the desktop app:
```bash
cd frontend
flutter pub get
flutter run -d windows 
```

---
*Disclaimer: kemo.ai interacts directly with your local operating system. This MVP is built for demonstration purposes during the AMD Slingshot Hackathon. Always review the actions the AI proposes before granting execution permissions.*
