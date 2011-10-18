Thanks for downloading the TestFlight SDK 0.6! 

This document is also available on the web at https://www.testflightapp.com/sdk/doc

1. Why use the TestFlight SDK?
2. Considerations
3. How do I integrate the SDK into my project?
4. Using the Checkpoint API
5. Using the Feedback API
6. Upload your build
7. Questions API
8. View your results
9. Advanced Exception Handling

START


1. Why use the TestFlight SDK?

The TestFlight SDK allows you to track how beta testers are testing your application. Out of the box we track simple usage information, such as which tester is using your application, their device model/OS, how long they used the application, logs of their test session, and automatic recording of any crashes they encounter.

To get the most out of the SDK we have provided the Checkpoint API.

The Checkpoint API is used to help you track exactly how your testers are using your application. Curious about which users passed level 5 in your game, or posted their high score to Twitter, or found that obscure feature? With a single line of code you can find gather all this information. Wondering how many times your app has crashed? Wondering who your power testers are? We've got you covered. See more information on the Checkpoint API in section 4.

Alongside the Checkpoint API is the Questions interface. The Questions interface is managed on a per build basis on the TestFlight website. Find out more about the Questions Interface in section 6.

2. Considerations


Information gathered by the SDK is sent to the website in real time. When an application is put into the background (iOS 4.x) or terminated (iOS 3.x) we try to send the finalizing information for the session during the time allowed for finalizing the application. Should all of the data not get sent the remaining data will be sent the next time the application is launched. As such, to get the most out of the SDK we recommend your application support iOS 4.0 and higher.

This SDK can be run from both the iPhone Simulator and Device and has been tested using Xcode 4.0.

3. How do I integrate the SDK into my project?


1. Add the files to your project: Project -> Add to Project -> TestFlightSDK

    1. Copy items into destination folder (if needed): Checked
    2. Reference Type: Default
    3. Recursively create groups for added folders

2. Verify that libTestFlight.a has been added to the Link Binary With Libraries Build Phase for the targets you want to use the SDK with
    
    1. Select your Project in the Project Navigator
    2. Select the target you want to enable the SDK for
    3. Select the Build Phases tab
    4. Open the Link Binary With Libraries Phase
    5. If libTestFlight.a is not listed, drag and drop the library from your Project Navigator to the Link Binary With Libraries area
    6. Repeat Steps 2 - 5 until all targets you want to use the SDK with have the SDK linked

3. In your Application Delegate:

    1. Import TestFlight -> #import "TestFlight.h"
    NOTE: If you do not want to import TestFlight.h in every file you may add the above line into you pre-compiled header (<projectname>_Prefix.pch) file inside of the 

            #ifdef __OBJC__ section. 
        This will give you access to the SDK across all files.
    2. Get your Team Token which you can find at [http://testflightapp.com/dashboard/team/](http://testflightapp.com/dashboard/team/) select the team you are using then choose edit.
    3. Launch TestFlight with your Team Token, if you do not currently use an unhandled exception handler you can skip to step 4

            -(BOOL)application:(UIApplication *)application 
                    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
                [TestFlight takeOff:@"Insert your Team Token here"];
            }

    4. To report crashes to you we install our own uncaught exception handler. If you are not currently using an exception handler of your own then all you need to do is go to the next step. If you currently use an Exception Handler, or you use another framework that does please go to the section on advanced exception handling.

4. To enable the best crash reporting possible we recommend setting the following project build settings in Xcode to NO for all targets that you want to have live crash reporting for You can find build settings by opening the Project Navigator (default command + 1 or command + shift + j) then clicking on the project you are configuring (usually the first selection in the list) from there you can choose to either change the global project settings or settings on an individual project basis. All settings below are in the Deployment Section.

    1. Deployment Post Processing
    2. Strip Debug Symbols During Copy
    3. Strip Linked Product

4. Use the Checkpoint API to create important checkpoints throughout your application.

When a tester passes a level, or adds a new todo item, you can pass a checkpoint.  The checkpoint progress is used to provide insight into how your testers are testing your apps.  The passed checkpoints are also attached to crashes which can help when creating steps to replicate.

[TestFlight passCheckpoint:@"CHECKPOINT_NAME"];
Use passCheckpoint: to track when a user performs certain tasks in your application. This can be useful for making sure testers are hitting all parts of your application, as well as tracking which testers are being thorough.

5. Using the Feedback API

To launch unguided feedback call the openFeedbackView method. We recommend that you call this from a GUI element. 

    -(IBAction)launchFeedback {
        [TestFlight openFeedbackView];
    }

Once users have submitted feedback from inside of the application you can view it in the feedback area of your build page.

6. Upload your build.

After you have integrated the SDK into your application you need to upload your build to TestFlight. You can upload from your dashboard or or using the Upload API, full documentation here https://testflightapp.com/api/doc/ 

7. Add Questions to Checkpoints

In order to ask a question, you'll need to associate it with a checkpoint. Make sure your checkpoints are initialized by running your app and hitting them all yourself before you start adding questions.

There are three question types available: Yes/No, Multiple Choice, and Long Answer.

To create questions, visit your builds Questions page, and click on 'Add Question'. If you choose Multiple Choice, you'll need to enter a list of possible answers for your testers to choose from &mdash; otherwise, you'll only need to enter your question's, well, question. If your build has no questions, you can also choose to migrate questions from another build (because seriously &mdash; who wants to do all that typing again)?

After restarting your application on an approved device when you pass the checkpoint associated with your questions a Test Flight modal question form will appear on the screen asking the beta tester to answer your question.

After you upload a new build to TestFlight you will need to associate questions once again. However if your checkpoints and questions have remained the same you can choose "copy questions from an older build" and choose which build to copy the questions from.

8. View your results.

As testers install your build and start to test it you will see their session data on the web on the build report page for the build you've uploaded.

9. Advanced Exception Handling

An uncaught exception means that your application is in an unknown state and there is not much that you can do but try and exit gracefully. Our SDK does its best to get the data we collect in this situation to you while it is crashing but it is designed in such a way that the important act of saving the data occurs in as safe way a way as possible before trying to send anything. If you do use uncaught exception or signal handlers install your handlers before calling takeOff our SDK will then call your handler while ours is running. For example:

            /*
             My Apps Custom uncaught exception catcher, we do special stuff here, and TestFlight takes care of the rest
            **/
            void HandleExceptions(NSException *exception) {
                NSLog(@"This is where we save the application data during a exception");
                // Save application data on crash
            }
            /*
             My Apps Custom signal catcher, we do special stuff here, and TestFlight takes care of the rest
            **/
            void SignalHandler(int sig) {
                NSLog(@"This is where we save the application data during a signal");
                // Save application data on crash
            }

            -(BOOL)application:(UIApplication *)application 
                    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
                // installs HandleExceptions as the Uncaught Exception Handler
                NSSetUncaughtExceptionHandler(&HandleExceptions);
                // create the signal action structure 
                struct sigaction newSignalAction;
                // initialize the signal action structure
                memset(&newSignalAction, 0, sizeof(newSignalAction));
                // set SignalHandler as the handler in the signal action structure
                newSignalAction.sa_handler = &SignalHandler;
                // set SignalHandler as the handlers for SIGABRT, SIGILL and SIGBUS
                sigaction(SIGABRT, &newSignalAction, NULL);
                sigaction(SIGILL, &newSignalAction, NULL);
                sigaction(SIGBUS, &newSignalAction, NULL);
                // Call takeOff after install your own unhandled exception and signal handlers
                [TestFlight takeOff:@"Insert your Team Token here"];
                // continue with your application initialization
            }

You do not need to add the above code if your application does not use exception handling already.

END

Please contact us if you have any questions.

The TestFlight Team

w. http://www.testflightapp.com
e. beta@testflightapp.com
