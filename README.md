# 📚 ClassLink

ClassLink is a mobile-based student–teacher communication and academic resource sharing platform designed to improve how universities manage course materials, announcements, and communication.

The system organizes academic content by department, year, and semester while enabling structured messaging, Q&A discussions, and searchable learning resources.

---

## 🚀 Features

### 👨‍🎓 Student Features
- Auto-enrolled courses based on year & semester
- Elective course selection
- View announcements per course
- Access and download learning materials
- Participate in Q&A forums
- Direct messaging with teachers
- Search academic resources across all courses

### 👨‍🏫 Teacher Features
- Post course announcements
- Upload and manage course materials
- Answer student questions in Q&A
- Send direct messages to students

### 🔔 System Features
- Role-based access (Student / Teacher)
- Course-based content organization
- Searchable resource library
- Notification system for updates and replies

---

## 🧠 System Concept

ClassLink is built around a structured academic model:
Year → Semester → Department → Course → Content

- Core courses are automatically assigned based on student year & semester
- Elective courses can be manually selected by students
- All materials are searchable but organized by course structure

---

## 🏗️ Tech Stack

- Flutter (Mobile App)
- Dart
- Bloc (State Management)
- Clean Architecture
- Firebase / REST API 
- Socket.IO (for real-time messaging)

---

## 📱 App Structure
lib/
├── core/
│   ├── error/
│   ├── network/
│   ├── utils/
│   ├── constants/
│   ├── theme/
│   └── usecases/

├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/

│   ├── courses/
│   │   └── (same structure)

│   ├── messaging/
│   │   └── (same structure)

│   ├── announcements/
│   │   └── (same structure)

│   ├── materials/
│   │   └── (same structure)

├── shared/
│   ├── widgets/
│   ├── models/
│   └── services/

└── main.dart


---

## 🎯 Goal of the Project

To eliminate fragmented communication tools (Telegram, Email, etc.) and provide a unified, structured academic platform that improves collaboration between students and teachers.

---

## 👨‍💻 Development Status

🚧 Project is currently under development as part of a university software engineering final project.

---

## 📌 Future Improvements

- Offline mode support
- AI-based study assistance
- Smart notifications
- Advanced analytics for academic performance
- File version tracking system

---

## 👥 Team

Developed by a 3rd year Software Engineering team as part of a Multi-Platform Software Development course project.

---

## 📄 License

This project is for academic purposes.