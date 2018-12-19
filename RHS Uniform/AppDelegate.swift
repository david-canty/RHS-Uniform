//
//  AppDelegate.swift
//  RHS Uniform
//
//  Created by David Canty on 22/09/2017.
//  Copyright © 2017 ddijitall. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import AlamofireNetworkActivityIndicator
import Firebase
import Stripe
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let reachabilityManager = NetworkReachabilityManager(host: "localhost")
    var firebaseAuth: Auth?
    var authHandle: AuthStateDidChangeListenerHandle?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // First launch checks
        FirebaseApp.configure()
        firebaseAuth = Auth.auth()
        
        registerDefaultPreferences()
        
        if isFirstLaunch() {
            
            do {
                try firebaseAuth?.signOut()
            } catch {
                print("Error signing out of Firebase: \(error)")
            }
            
            KeychainController.deleteAppSecuredItems()
        }
        
        // Stripe
        STPPaymentConfiguration.shared().publishableKey = AppConfig.sharedInstance.stripePublishableKey()
        setStripeTheme()
        
        // Alamofire network activity indicator
        NetworkActivityIndicatorManager.shared.isEnabled = true
        NetworkActivityIndicatorManager.shared.startDelay = 0
        
        // Alamofire reachability manager
        reachabilityManager?.listener = { status in
            
            print("Network Status Changed: \(status)")
        }
        
        reachabilityManager?.startListening()
        
        // Show main view or sign in
        listenForAuthStateDidChange()
        
        if firebaseAuth?.currentUser != nil {
            
            APIPoll.sharedInstance.startPolling()
            showContainerViewController()
            
        } else {
            
            showSignInViewController()
        }
        
        return true
    }
    
    func isFirstLaunch() -> Bool {
        
        let defaults = UserDefaults.standard
        
        if defaults.bool(forKey: "isFirstLaunch") {
            
            defaults.set(false, forKey: "isFirstLaunch")
            return true
            
        } else {
            
            return false
        }
    }
    
    func listenForAuthStateDidChange() {
    
        authHandle = firebaseAuth?.addStateDidChangeListener { (auth, user) in
            
            print("Auth: \(auth), User:\(String(describing: user))")
        }
    }
    
    func registerDefaultPreferences() {
        
        let userDefaults = UserDefaults.standard
        if let defaultPreferencesFilePath = Bundle.main.path(forResource: "DefaultPreferences", ofType: "plist") {
            
            if let defaultPreferencesDict = NSDictionary(contentsOfFile: defaultPreferencesFilePath) as? Dictionary<String, AnyObject> {
                
                userDefaults.register(defaults: defaultPreferencesDict)
            }
        }
    }
    
    func showContainerViewController() {
        
        if let containerViewController = UIStoryboard.containerViewController() {
            
            containerViewController.managedObjectContext = self.persistentContainer.viewContext
            containerViewController.delegate = self
            self.window!.rootViewController = containerViewController
            
            UIView.transition(with: self.window!, duration: 0.25, options: UIView.AnimationOptions.transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    func showSignInViewController() {
        
        if let signInViewController = UIStoryboard.signInViewController() {
            
            signInViewController.delegate = self
            
            let navigationController = UINavigationController(rootViewController: signInViewController)
            navigationController.navigationBar.isHidden = true
            self.window?.rootViewController = navigationController
            
            UIView.transition(with: self.window!, duration: 0.25, options: UIView.AnimationOptions.transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    func setStripeTheme() {
        
        let theme = STPTheme.default()
        
        theme.font = UIFont(name: "Arial", size: 16.0)
        theme.emphasisFont = UIFont(name: "Arial-BoldMT", size: 16.0)
        theme.accentColor = UIColor(red: 203.0/255.0, green: 8.0/255.0, blue: 19.0/255.0, alpha: 1.0)
        theme.errorColor = UIColor.red
        theme.primaryForegroundColor = UIColor(red: 62.0/255.0, green: 60.0/255.0, blue: 146.0/255.0, alpha: 1.0)
        theme.secondaryForegroundColor = UIColor(red: 62.0/255.0, green: 60.0/255.0, blue: 146.0/255.0, alpha: 1.0)
        theme.primaryBackgroundColor = UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1.0)
        theme.secondaryBackgroundColor = UIColor.white
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        APIPoll.sharedInstance.stopPolling()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        if firebaseAuth?.currentUser != nil {
            APIPoll.sharedInstance.startPolling()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "RHS_Uniform")
        
//        let description = NSPersistentStoreDescription()
//        description.shouldInferMappingModelAutomatically = true
//        description.shouldMigrateStoreAutomatically = true
//        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // User Notifications
    func registerForPushNotifications() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] (granted, error) in
        
            print("User notification permission granted: \(granted)")
            
            guard granted else { return }
            self?.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            
            print("User notification settings: \(settings)")
            
            guard settings.authorizationStatus == .authorized else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Remote notification device token: \(token)")
        
        APIClient.sharedInstance.save(apnsDeviceToken: token) { (customer, error) in
            
            if let error = error as NSError? {
                
                print("Error saving APNS token: \(error)")
                
            } else {
                
                if let customer = customer {
                    
                    let customerId = customer["id"]
                    
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("Failed to register for remote notifications: \(error)")
    }
}

extension AppDelegate: ContainerViewControllerDelegate {
    
    func didSignOut() {
    
        do {
            
            try firebaseAuth?.signOut()
            
            APIPoll.sharedInstance.stopPolling()
            showSignInViewController()
            
        } catch let signOutError as NSError {
            
            print ("Error signing out: %@", signOutError)
        }
    }
}

extension AppDelegate: SignInViewControllerDelegate {
    
    func didSignIn() {
        
        APIPoll.sharedInstance.startPolling()
        registerForPushNotifications()
        showContainerViewController()
    }
}
