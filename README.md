# Mobile Performance Management with Dynatrace
In this repository you'll find everything you need for the hands-on training session at Dynatrace Perform Conference 2018 in Las Vegas.

# Prerequisites
The following prerequisites should be prepared before the training. 
- Laptop (with admin permissions and internet access)
- Git (to clone the code samples from GitHub)
- Android Studio (please make sure that you can launch an app from Android Studio in an emulator - e.g. Android Emulator, Genymotion or Visual Studio Emulator for Android - and that the emulator has internet access)
- npm (will be installed by installing NodeJS)
- Ionic and other tools: `npm install -g ionic corsproxy grunt-cli`

See [00-Prerequisites.pdf](https://github.com/Dynatrace/mobile-hotday-2018/raw/master/doc/00-Prerequisites.pdf) for a detailed description of the setup process. 

# Lesson 1 - The Dynatrace demo environment
In this lesson we will get familiar with the Dynatrace environment that we will be using throughout the training. The environment is filled with data from the easyTravel demo app. Below are the credentials that you can use. Please log in to the system and review the data.

|Dynatrace|https://cnz35449.sprint.dynatracelabs.com|
|---|---|
|Username|u3879401@mvrht.net|
|Password|MobileHOT2018|

|easyTravel UI|http://ec2-35-168-8-170.compute-1.amazonaws.com:8079|
|---|---|
|Username|maria|
|Password|maria|
  
Please go through the following steps.
- Open easyTravel website and book a new travel
- Log in to Dynatrace
- View the environment in smartscape
- View the web application


# Lesson 2 - Auto-instrumentation in Android Studio
In this lesson we will work with a native Android app that is using web services from the easyTravel demo app. We will go through the following steps.
- Check out and configure easytravel-android
- Auto instrument the mobile app
- Crash reporting

See [02-Android-Auto-Instrumentation.pdf](https://github.com/Dynatrace/mobile-hotday-2018/raw/master/doc/02-Android-Auto-Instrumentation.pdf) for a detailed walkthrough.

# Lesson 3 - Enhance the Android instrumentation
Manual instrumentation is a great way to enhance the instrumentation and gain deeper insights into the app. In this lesson we will dig deeper into the application code and do some coding. We will go through the following steps.
- Identify user
- Custom user actions
- Reporting errors

See [03-Manual-Instrumentation.pdf](https://github.com/Dynatrace/mobile-hotday-2018/raw/master/doc/03-Manual-Instrumentation.pdf) for a detailed walkthrough.

# Lesson 4 - Connect the Android app to AppMon
In this bonus lesson we will make all necessary changes to the Android app from our previous lessons to report the data to an AppMon instance instead of Dynatrace. The credentials are listed below.

|AppMon Web UI|https://ec2-52-11-154-200.us-west-2.compute.amazonaws.com:9911|
|---|---|
|Username|u3879401@mvrht.net|
|Password|MobileHOT2018|

|easyTravel UI|http://ec2-52-11-154-200.us-west-2.compute.amazonaws.com:8079|
|---|---|
|Username|maria|
|Password|maria|

You will go through the following steps.
- Change the easyTravel backend URL to another easyTravel instance
- Change the app module's build.gradle to report data to AppMon
- Generate some data and analyze it in AppMon

See [04-Using-AppMon.pdf](https://github.com/Dynatrace/mobile-hotday-2018/raw/master/doc/04-Using-AppMon.pdf) for a detailed walkthrough.

# Lesson 5 - Auto instrumentation in Xcode
In this bonus lesson we will go through the auto instrumentation process of an iOS app with Xcode.
- Import the iOS demo app in Xcode and run it in the emulator
- Use CocoaPods to insert the mobile agent

See [05-iOS-Instrumentation.pdf](https://github.com/Dynatrace/mobile-hotday-2018/raw/master/doc/05-iOS-Instrumentation.pdf) for a detailed walkthrough.

# Lesson 6 - Instrumenting an Ionic app
We will now work with another flavor of easyTravel for mobile, a hybrid easyTravel app built with Ionic/Cordova. We will go through the following steps.
- Get familiar with the Ionic CLI and run the app in the emulator
- Use the Dynatrace Cordova plugin to instrument the app 
- Analyze the data in Dyntrace

See [06-Hybrid-Instrumentation.pdf](https://github.com/Dynatrace/mobile-hotday-2018/raw/master/doc/06-Hybrid-Instrumentation.pdf) for a detailed walkthrough.
