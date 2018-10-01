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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var apiPoll: APIPoll?
    let reachabilityManager = NetworkReachabilityManager(host: "localhost")
    var firebaseAuth: Auth?
    var authHandle: AuthStateDidChangeListenerHandle?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        registerDefaultPreferences()
        
        FirebaseApp.configure()
        firebaseAuth = Auth.auth()
        listenForAuthStateDidChange()
        
        if firebaseAuth?.currentUser != nil {

            apiPoll = APIPoll()
            apiPoll?.startPolling()
            showContainerViewController()

        } else {

            showSignInViewController()
        }
        
        // Alamofire network activity indicator
        NetworkActivityIndicatorManager.shared.isEnabled = true
        NetworkActivityIndicatorManager.shared.startDelay = 0
        
        // Alamofire reachability manager
        reachabilityManager?.listener = { status in
            
            print("Network Status Changed: \(status)")
        }
        
        reachabilityManager?.startListening()
        
        return true
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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        apiPoll?.stopPolling()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        apiPoll?.startPolling()
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
    
}

extension AppDelegate: ContainerViewControllerDelegate {
    
    func didSignOut() {
    
        do {
            
            try firebaseAuth?.signOut()
            
            apiPoll?.stopPolling()
            apiPoll = nil
            showSignInViewController()
            
        } catch let signOutError as NSError {
            
            print ("Error signing out: %@", signOutError)
        }
    }
}

extension AppDelegate: SignInViewControllerDelegate {
    
    func didSignIn() {
        
        apiPoll = APIPoll()
        apiPoll?.startPolling()
        showContainerViewController()
    }
}
