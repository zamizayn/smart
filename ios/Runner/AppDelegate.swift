import UIKit
import Flutter
import GoogleMaps
import UserNotifications
import Firebase
//import FirebaseInstanceID
import FirebaseMessaging
import FirebaseCore


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate,MessagingDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self
          
          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
              options: authOptions,
              completionHandler: {_, _ in })
      } else {
          let settings: UIUserNotificationSettings =
              UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
      }
     
      application.registerForRemoteNotifications()
      FirebaseApp.configure()
      Messaging.messaging().delegate = self
      
      let notificationCenter = UNUserNotificationCenter.current()
      notificationCenter.delegate = self
      
    GeneratedPluginRegistrant.register(with: self)
      // TODO: Add your Google Maps API key
          GMSServices.provideAPIKey("AIzaSyCi4FtA5ORrzOi_6G9f0StH5HWPoW9cU_Y")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
