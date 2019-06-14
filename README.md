
# Backchannel for UITesting.

[Snapshot][1] is awesome. 

Now it uses UI Testing.

UI Testing is massively better than UI Automation - but sometimes, you just want to cheat.

HSTestingBackchannel gives you a simple method to send messages from your UITesting tests directly to your running app in the form of notifications.

## Installation

Install with CocoaPods

    pod 'HSTestingBackchannel', :configuration => ['Debug']

## Usage

 1. set an 'Active Compilation Condition' in your swift project to define SNAPSHOT

![Compilation](https://raw.githubusercontent.com/ConfusedVorlon/HSTestingBackchannel/master/images/compilation.jpg)

 2. In your App Delegate, install the
    helper

        #if SNAPSHOT
			import HSTestingBackchannel
        #endif

        (and then in application(_:didFinishLaunchingWithOptions:))

        #ifdef SNAPSHOT
            HSTestingBackchannel.installReceiver
        #endif

 3. Send notifications from your UITesting class


        HSTestingBackchannel.sendNotification("SnapshotTest")

or

        HSTestingBackchannel.sendNotification("SnapshotTest",with: ["aKey":"aValue"])

 5. Respond to notifications within your app

        #if SNAPSHOT
                NotificationCenter.default.addObserver(forName:NSNotification.Name.init("SnapshotTest"),
                object: nil,
                queue: .main) { (_) in
                    //Do Something
                }  
        #endif


## Bonus -  Copy dummy files to the Simulator

Within a test method (or in setUp), call something like

	HSTestingBackchannel.installFiles(from:"..pathTo/fastlane/DummyImages",
                                        to:HSTestingResources];


This will install the contents of DummyImages in the resources folder of your running app.
You can also install directly to the Documents directory in the app.

## Multiple Simultaneous Simulators

By default, Fastlane now runs multiple simulators simultaneously. This means you need to make sure that the server for each simulator is running on a different test.

Use the setup method to do the following

        let app = XCUIApplication()
        
        HSTestingBackchannel.port = UInt.random(in: 8000 ... 60000)
        app.launchArguments.append(contentsOf:["-HSTestingBackchannelPort","\(HSTestingBackchannel.port)"])
        
        Snapshot.setupSnapshot(app, waitForAnimations: true)
        
        app.launch()

## How it works

HSTestingBackchannel installs a webserver in your main app (GCDWebServer). 

You simply send requests directly to that - and it recognises them and broadcasts NSNotifications


  [1]: https://github.com/KrauseFx/snapshot
  [2]: https://github.com/fastlane/snapshot/issues/241
