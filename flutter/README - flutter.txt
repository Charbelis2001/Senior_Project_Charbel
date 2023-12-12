first of all we need to have flutter ready on vscode.
if you dont have that use the following link:https://www.youtube.com/watch?v=0SRvmcsRu2w

once flutter is ready on vscode, we open a workspace, then open a terminal by pressing terminal -> new terminal

in the terminal you run "flutter create project_name".
this will create a flutter project in the directory you are in.
then run "cd project_name". this will add \project_name to your directory in the terminal.

once the project is created you'll have many files, we only focus on a few files like pubspec.yaml where we will add dependencies as you can see in our report/provided code.
once you add the dependencies, run in the terminal "flutter pub get", which will downlaod the libraries of the specified dependencies. if you want to get the latest version you can search for it on pub.dev.

there is also in lib a file called main.dart which is the main file (it'll have boilerplate code first).
in lib, we also created 2 file for bluetooth and notification. we already got their libraries from the dependencies in pubspec.yaml.
the main, bluetooth and notification class are expalined in the report.


finally we navigate to AndroidManifest.xml, which can be found in android->app->src->main

here we add the required permissions as seen in our report / provided code.
we also need to add the meta-data inside activity as explained in report to enable notifications.

once this is done, to test it you need to connect a samsung phone to your laptop, we used Samsug A32 running android 12, but you should be able to use other devices as well.
before connecting the phone, make sure to turn developper mode on by tapping the build number of the phone in settings till it says developper mode on.
once developper mode is on, go back in settings and you will find developper options, in it there is a enable for usb debugging, you need to enable it.

once all this is done, connect your phone and run "flutter devices" which will show you all the connected devices. there should be windows, chrome, and edge, and your device.
if you dont see the device, it is either the cable you are using dosent send/recieve data and is only used for power, or you dont have android sdk on your pc.
to solve the second issue, download android studio, and in it download android sdk.

once done run "flutter devices" and you should be able to see your phone. Once you see your phone, run "flutter run" in the terminal, and it will either directly run in debugging mode the application, while also downloading it on your device, or it'll ask you on which device you want to run it and you should choose your phone.

it will take some time before the application run when it is the first time you run "flutter run", but the next time you update/change in the code, if it is still running in debug mode (connected to the pc, and you can see it in terminal) you can just restart the app from the terminal, and the updates will be applied. if not conneced, connect your phone again and just run "flutter run", and this time it will take only a few seconds.

finally, make sure the dependecies you are using are placed correctly with their versions in pubspec.yaml, make sure you add the permissions and the meta-data in androidmanifest.xml.

if you want to check any library you can find it in pub.dev website. in it there is also a readme for every library as well as a github repository where you can find examples/ ask if you have any issue.

this was also only for the BLE, since the code i used to test the serial bluetooth was from a pub.dev and i got the code from the example in its github repository.
the code for the ble is explained in the report.