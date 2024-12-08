# Judica 📚

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Judica is an innovative legal-tech project aimed at simplifying access to legal information for different types of users. It incorporates a conversational chatbot that provides legal insights tailored to the needs of common citizens, advocates, and police officers.

# NOTE: Contents under this note is still in progress DO NOT REFER ANYTHING BELOW THIS LINE

# 📋 Prerequisites
  - Python 3.8+
  - pip
  - Firebase
  - Dependencies (listed in requirements.txt)

# 🔧 Installation

1. **Clone the Repository:**
    ```bash
    $ git clone https://github.com/yourusername/judica.git
    $ cd judica
    ```

2. **Install Dependencies:**
    ```bash
    $ pip install -r requirements.txt
    ```

3. **Set Up Database:**

    - Ensure `Firebase` is running on your system.
    - Update the `config.py` file with your `Firebase URI` and `database name`.

4. **Run the Application:**
    ```bash
    $ python app.py
    ```

## 📱 Screenshots

| Sign In                         | Register                       |
|---------------------------------|--------------------------------|
| ![Sign In](assets/screenshots/SignIn.jpg) | ![Register](assets/screenshots/Register.jpg) |

| Home Page                       | Student Circular               |
|---------------------------------|--------------------------------|
| ![Home Page](assets/screenshots/HomePage.jpg) | ![Student Circular](assets/screenshots/StudentCircular.jpg) |

| Profile                         | Stream & ChatBot               |
|---------------------------------|--------------------------------|
| ![Profile](assets/screenshots/Profile.jpg) | ![Stream & ChatBot](assets/screenshots/Stream&ChatBot.jpg) |

| Attendance Tracking             | Give Attendance                |
|---------------------------------|--------------------------------|
| ![Attendance Tracking](assets/screenshots/AttendanceTracking.jpg) | ![Give Attendance](assets/screenshots/GiveAttendance.jpg) |

## 🌟 Features

  1. 📝 **Legal Information Chatbot**
  * **Target Users:** Common citizens
  * *Capabilities:*
    * Provide easy-to-understand legal guidance.
    * Offer summaries of laws, legal rights, and procedural information.
  
  2. 💼 **Bail Reckoner (Advocates)**
  * *Functionality:*
    * Analyze an assortment of data as requested and determine the eligibility of that convicts bail.
    * Reference case laws and precedents dynamically.
  
  3. 🔎 **FIR Filing Assistance (Police Officers)**
  * *Functionality:*
    * Formulates FIRs using user inputs such as crime details, suspect information, and evidence descriptions.
    * Generates legally compliant PDFs for record-keeping and judicial use.

## 📘 Usage
### 👤 For Common Users
  * Interact with the chatbot by typing questions in natural language.
  * **Example:**
    * What are my rights as a tenant?
    * How can I file a consumer complaint?

### ⚖️ For Advocates
  * Access the Bail Reckoner feature by selecting the relevant mode in the chatbot interface.
  * Input details that are requested in the inputs.

### 👮 For Police Officers
  * Use the FIR Filing feature to draft FIRs.
  * Input details that are requested in the form.

## 🤝 Contributing
  
We welcome contributions to Judica! If you're interested in collaborating, please follow these steps:

  1. **Fork** the repository.
  2. **Create a new branch** for your feature or bug fix.
  3. **Make your changes** and ensure code quality.
  4. **Submit a pull request** for review.

For major changes, please open an issue to discuss what you would like to add or improve.

### Contact
For further queries, reach out to:

* Email: support@judica.com
* Website: Judica Official Site
