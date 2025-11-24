# linear_regression_model
Mission
The mission is to develop and evaluate machine learning models to predict student exam scores based on various academic and socio-economic factors.

Data Description
This dataset, sourced from Kaggle (lainguyn123/student-performance-factors), contains information about factors influencing student performance. The primary file used in this analysis is StudentPerformanceFactors.csv. It includes features such as hours studied, attendance, parental involvement, access to resources, and other relevant attributes, with the goal of predicting the Exam_Score.

Problem
 The core problem addresses predicting student exam scores. This is based on various academic and socio-economic factors. Ultimately, we aim to provide insights for improving educational outcomes.

 ## A publicly available API endpoint
 https://linear-regression-model-5-yrya.onrender.com

 ## A publicly available API endpoint to the Swagger UI
    https://linear-regression-model-5-yrya.onrender.com/docs

## A link to the YouTube video demo.
   https://www.youtube.com/watch?v=o5paSz0Awk0
   
## Clear instructions on how to run your mobile app. 
Below is a brief description on how to successfully run my simulator.
Open app folder:
cd "summative/FlutterApp/ml_app"

Install packages:
flutter pub get

Start an emulator / simulator:

Android: flutter emulators --launch <emulator-id>
iOS: open -a Simulator

Android emulator: http://10.0.2.2:8001
iOS simulator: http://127.0.0.1:8001
Run the app:
flutter run (or flutter run -d <device-id>)
So that is just basically it, but for me personally I use ios simulator of the device name 'iphone 16 Plus'.

So after the application runs, we then start the server in the terminal with the command below
This would activates the Python virtual environment in .venv
source API/.venv/bin/activate

And this would start the server.
uvicorn API.main:app --reload --port 8001

After that you can now go on with the predict your exam score either on the test mode using the SWAGGER UI or on the your simulator/emulator.