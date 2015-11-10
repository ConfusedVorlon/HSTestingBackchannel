
##Backchannel for UITesting.

[Snapshot][1] is awesome. 

Now it uses UI Testing.

UI Testing is massively better than UI Automation - but sometimes, you just want to cheat.

HSTestingBackchannel gives you a simple method to send messages from your UITesting tests directly to your running app in the form of notifications.

##Installation

Install with CocoaPods

    pod 'HSTestingBackchannel', '~> 0.0'

or download the class and add it to your project.  

##Usage

 1. use a prefix file and 

        #define SNAPSHOT true

	(We’re still hoping that snapshot will re-introduce [custom build arguments][2])

 2. In your App Delegate, install the
    helper

        #ifdef SNAPSHOT
			#import <HSTestingBackchannel/HSTestingBackchannel.h>
		#endif

        (and then in application:didFinishLaunchingWithOptions:)

        #ifdef SNAPSHOT
            [HSTestingBackchannel installReceiver];
        #endif

 3. Send notifications from your UITesting class


        [HSTestingBackchannel sendNotification:@"SnapshotTest"];

or

    [HSTestingBackchannel sendNotification:@"SnapshotTest"
                            withDictionary:@{@"key":@"value"}];

 5. Respond to notifications within your app

        #ifdef SNAPSHOT
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(doSomething:)
                                                         name:@"SnapshotTest" 
                                                       object:nil];    
        #endif


## Bonus -  Copy dummy files to the Simulator

Within a test method (or in setUp), call something like

	[HSTestingBackchannel installFilesFrom:@"..pathTo/fastlane/DummyImages" 
                                        to:HSTestingResources];



This will install the contents of DummyImages in the resources folder of your running app.
You can also install directly to the Documents directory in the app.

##How it works

HSTestingBackchannel installs a webserver in your main app (GCDWebServer). 

You simply send requests directly to that - and it recognises them and broadcasts NSNotifications

Note - this is not something you want in your shipping code, so you should comment out the pod and your prefix define before rebuilding and shipping.

  [1]: https://github.com/KrauseFx/snapshot
  [2]: https://github.com/fastlane/snapshot/issues/241