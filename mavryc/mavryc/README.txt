//   _____ _   ____   ___       ___  ______
//  /  ___| | / /\ \ / / |     / _ \ | ___ \
//  \ `--.| |/ /  \ V /| |    / /_\ \| |_/ /
//   `--. \    \   \ / | |    |  _  ||    /
//  /\__/ / |\  \  | | | |____| | | || |\ \
//  \____/\_| \_/  \_/ \_____/\_| |_/\_| \_|
//

README

--
Note @ Sept 14 2017
SKYLAR is a beta-demo version application build with Xcode 8.3.3 in Swift 3, with a few cocoapods (see podfile) included for support functions such as Alamofire for networking, others for object mapping, json support, etc.

Xcode 9 & Swift 4 & iPhone X
I recommend shifting to Xcode 9 and converting to swift 4, which should be a fairly painless and simple task. Taking advantage of Swift 4 will allow us to depend on the codeable protocol to handle most of our json parsing, rather than having to rely on one (possibly more) of the cocoapods (which we can then eliminate from out podfile and throw away those files) - always a good thing.

Mapbox
We are using the 3rd party Mapbox in order to facilitate maximum visual styling of the map experience.

Google Places API
We use this to facilitate city search autocomplete on our airport dropdown list. It would be desirable for production-quality to use a custom service that will give us back results based on business logic residing on the server, which will allow us to have more intelligent destinations listed based on a given client's fleet/abilites, etc. The current Google Places API key is my own and should be replaced with a key belonging to Skylar's owner

Building the app on a simulator
This should just work

Building the app on a device using fastlane and hockeyapp
There are three parts to building the app for distribution using fastlane - first installing fastlane, second running fastlane match to install the development team profile giving you signing permissions, three running the fastlane script to build the distribution version of the app, this is called "fastlane adhoc" (or whatever the name of the distribution is).

The command line instructions will be placed alone on a line and tabbed in to visiually hilight the command.

1. follow the instructions to install fastlane tools on your machine. https://docs.fastlane.tools/getting-started/ios/setup/

        xcode-select --install

    //note: this next command only is for if you're using homebrew (if not look at the instructions on the link just above):

        brew cask install fastlane

    //note: now with fastlane installed, initialize it:

        fastlane init


NOTE:
When you follow the instructions below, you will refer to the passphrase.
The passphrase to access the github repo for the 'fastlane match' team signing certs: ukkomatch
Process for getting fastlane match installed and working: (please contact me at 480-236-3651 if there is a problem using match)


2. Go to: https://github.com/Mavryc-Technologies/fastlane-mavryc-certs - follow instructions
// summary:
// Download the zip file. Then double click on the install script (or run it in a terminal window).
// navigate to project folder in Terminal and run:

        fastlane match development

    // input any passwords if asked -- pass for iosteam@lavamonster.io and also passphrase for match git repo is 'ukkomatch'

3. From the command prompt type:

        fastlane adhoc

    //note:  this will build an app file that you will then drag to hockeyapp on the screen where you specify to add a version of the app.

--

/////////////////
Noteworhty files:

AppStyle.swift - This class should be referenced by code that assigns colors and style elements.

skylar.xcassets - this file contains the images for the application

Resources - this grouping contains the sound, image, and info plist assets

Networking.swift & FetchFlightsClient - this is a good example of the structure for calling web service APIs.

Trip.swift, TripCoordinator.swift, and FlightInfo.swift support the data model for flights and trips. As the model is finalized, I would assume these files will morph probably into one and simplified.

AircraftServicesViewModel.swift - provides simplified data model access to screen dealing with selection of aircraft service - I believe this will need to be refined as the data model on the server is refined.

ConfirmDetailsViewModel.swift - convenience data provider for the Trip confirmation screen

features - this folder grouping contains all the files for the various screens

slideout menu - this grouping is self explanitory

joystick - this grouping contains joystick support files. Note that joystick functionality is turned is off at the moment.

login and billing groups contain those respective components

---

/////////////////
Storyboards:

Main.storyboard - this contains the bulk of the primary interface screens for the app

Profile.storyboard - contains profile screen
SlideoutMenu.storyboard - contains slideout menu base screen

Mapbox.storyboard - contains map

Authentication.storyboard - contains auth landing screen, login screen, and signup screen

Billing.storyboard - contains billing screen

---

/////////////////

