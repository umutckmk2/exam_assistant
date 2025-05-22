# Exam Assistant App (YKS Asistan)

## Overview
Exam Assistant is a mobile application developed using Flutter to help students prepare for standardized exams, specifically focusing on the Turkish university entrance examination (YKS). The app provides a comprehensive suite of tools for exam preparation, progress tracking, and personalized learning.

## Aim
The primary aim of the Exam Assistant app is to provide a structured, organized, and efficient way for students to:
- Practice exam questions categorized by subjects and topics
- Track their progress and performance statistics
- Set and monitor daily study goals
- Access comprehensive lessons and learning materials
- Receive personalized feedback on their performance

## Key Features

### 1. Question Practice System
- Organized questions by subjects, topics, and subtopics
- Tracking of solved and unsolved questions
- Multiple-choice question format similar to actual exams
- Question explanations and answers

### 2. Personalized Learning Path
- Daily goals setting and tracking
- Performance statistics by subject and time period
- Ability to focus on weak areas identified through practice

### 3. Comprehensive Content Organization
- Structured categorization of educational content
- Topics and subtopics within each subject
- Lesson materials and references

### 4. Progress Tracking and Statistics
- Detailed performance analytics
- Visual charts showing correct vs. incorrect answers
- Time-based filtering (weekly, monthly, all-time)
- Subject-specific performance tracking

### 5. User Account Management
- User authentication and profile management
- Cloud storage of progress and statistics
- Synchronization across devices

### 6. Learning Resources
- Lesson materials organized by topics
- WebView integration for external resources
- Structured approach to comprehensive exam preparation

### 7. Monetization
- Google Mobile Ads integration for various ad formats
- Banner ads for non-intrusive revenue generation
- Interstitial ads at natural transition points

## Technology Stack
- **Frontend**: Flutter
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Data Storage**: Hive for local caching
- **Authentication**: Firebase Auth with Google Sign-in

## Target Audience
The app is designed for students preparing for competitive exams, with a specific focus on the Turkish university entrance examination system, but the architecture could be adapted for other standardized tests and educational contexts.

## Getting Started

### Prerequisites

- Flutter SDK
- Firebase project setup
- OpenAI API key

### Installation

1. Clone the repository
   ```
   git clone https://github.com/umutckmk2/kpss_ai_assistant.git
   ```

2. Install dependencies
   ```
   flutter pub get
   ```

3. Create a `.env` file in the root directory with your API keys:
   ```
   OPENAI_API_KEY=your_openai_api_key
   ```

4. Run the app
   ```
   flutter run
   ```

## License

This project is licensed under the MIT License
