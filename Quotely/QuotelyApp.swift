//
//  QuotelyApp.swift
//  Quotely
//
//  Created by Brilliant Gamez on 7/15/22.
//

import SwiftUI
import RevenueCat
import AppLovinSDK
import FirebaseCore
import FirebaseMessaging
import Adjust
import AdSupport

//class AppDelegate: NSObject, UIApplicationDelegate {
//  func application(_ application: UIApplication,
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//    FirebaseApp.configure()
//
//    return true
//  }
//}

extension UserDefaults {
    
    var welcomeScreenShown: Bool {
        get{
            return (UserDefaults.standard.value(forKey: "welcomeScreenShown") as? Bool) ?? false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "welcomeScreenShown")
        }
    }
    
    var isPremiumAccount: Bool {
        get{
            return (UserDefaults.standard.value(forKey: "premiumAccount") as? Bool) ?? false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "premiumAccount")
        }
    }
}

@main
struct QuotelyApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var mWelcomeScreenShown: Bool
    var mIsPremium: Bool
    let notificationManager = NotificationManager()
    
    
    init(){
        
        mWelcomeScreenShown = UserDefaults.standard.welcomeScreenShown
        mIsPremium = UserDefaults.standard.isPremiumAccount
        delegate.notificationManager = notificationManager
//        FirebaseApp.configure()
        //Initilaization of MAX
        // Please make sure to set the mediation provider value to "max" to ensure proper functionality
        ALSdk.shared()!.mediationProvider = "max"
        ALSdk.shared()!.initializeSdk { (configuration: ALSdkConfiguration) in
        }
        
        //Initialization of ReveunueCat
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "REVENUE_CAT")
        Purchases.shared.collectDeviceIdentifiers()
        
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            // access latest customerInf
            if error == nil {
                if customerInfo?.entitlements["premium"]?.isActive == true {
                  // user has access to "your_entitlement_id"
                    UserDefaults.standard.isPremiumAccount = true
//                    Global.isPremium = true
                }
            }
        }
        
    
        
        //Initialization of Adjust
        let yourAppToken = AdjustTokens.appToken

        //TODO: Change this to production when going to live
        let environment = ADJEnvironmentProduction
        let adjustConfig = ADJConfig(
            appToken: yourAppToken,
            environment: environment,allowSuppressLogLevel: true)

        Adjust.appDidLaunch(adjustConfig)
        
        if let adjustId = Adjust.adid(){
            print("adjustId: \(adjustId)")
            Purchases.shared.setAdjustID(adjustId)
        }
        
//        Adjust.requestTrackingAuthorization() { status in
////            shouldShowNextScreen=true;
//            switch status {
//            case 0:
//                print("ATTrackingManagerAuthorizationStatusNotDetermined case")
//                // ATTrackingManagerAuthorizationStatusNotDetermined case
//                break
//            case 1:
//                print("ATTrackingManagerAuthorizationStatusRestricted")
//                    // ATTrackingManagerAuthorizationStatusNotDetermined case
//                    break
//            case 2:
//                print("ATTrackingManagerAuthorizationStatusDenied")
//                    // ATTrackingManagerAuthorizationStatusNotDetermined case
//                    break
//            case 3:
//                print("ATTrackingManagerAuthorizationStatusAuthorized")
//                    // ATTrackingManagerAuthorizationStatusNotDetermined case
//                    break
//            default:
//                print("ATTrackingManagerAuthorization Some other errors")
//                break
//
//            }
//
//        }
    }
    
    @State var linkActive = false

    @State var widgetQuote: QuoteModel?
    @Environment(\.scenePhase) var scenePhase
    
    
    //TODO: Change it to userdefaults
    var body: some Scene {
        WindowGroup {
            ZStack{
//                PaymentView(goBack: false).navigationBarHidden(true).statusBarHidden()
                if linkActive{
//                    HomeView(widgetQuote: widgetQuote)
//                    NavigationView{
//                        ZStack{
//                            NavigationLink(destination: , isActive: $linkActive) {
//                                AppColor.colorBlack
//                            }
//                        }.navigationBarHidden(true).statusBarHidden(true).background(AppColor.colorBlack)
//                    }
                    HomeView(widgetQuote: widgetQuote).navigationBarHidden(true).statusBarHidden()
                }
                else{
                    if mWelcomeScreenShown{
                        if mIsPremium{
                            HomeView()
                        }else{
                            PaymentIntroView()
                        }

                    }else{
                        WelcomeView(goBack: false).onAppear(perform: {
                            UserDefaults.standard.welcomeScreenShown = true
                        })
                    }
                }
            }
            .environmentObject(notificationManager)
            .onReceive(notificationManager.$recievedNotificationFromChatID) {
                guard let notificationSelection = $0 else  { return }
                print("NotificationInQuotelyApp: \(notificationSelection)")
                openQuote(quote: notificationSelection, author: "")// navigates to page InboxMessagesView
            }
            .onOpenURL { url in
                guard url.scheme == "widget-deeplink" else { return }
                print("Opened From Widget")
                print(url)
                let quote : String = url.valueOf("quote") ?? ""
                let author : String = url.valueOf("author") ?? ""
                openQuote(quote: quote, author: author)
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    print("QuotelyApp: Active")
                } else if newPhase == .inactive {
                    print("QuotelyApp: Inactive")
                    linkActive = false
                } else if newPhase == .background {
                    print("QuotelyApp: Background")
//                    linkActive = false
                }else{
                    print("QuotelyApp: \(newPhase)")
                }
            }
            
            
        }
    }
    
    func openQuote(quote: String, author: String){
        widgetQuote = QuoteModel(_id: "1234", name: quote, author: author, isliked: false)
        Task {
            await waitAwhile()
        }
    }
    
    func waitAwhile() async {
        do {
            sleep(1)
            linkActive = true
        }
        
    }
    
}

extension URL {
    func valueOf(_ queryParameterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParameterName })?.value
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    weak var notificationManager: NotificationManager?
    let gcmMessageIDKey = "gcm.message_id"
    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//            let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
//            let annotation = options[UIApplication.OpenURLOptionsKey.annotation]
//        print("APPDELEGATE: URL is Openend")
//            return true
//        }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        UIScrollView.appearance().bounces = false

        Messaging.messaging().delegate = self

        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions){
                success, error in
                if error != nil {
                    print("No Error")
                }else{
                    print("Error \(error)")
                }
            }
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        getCategories()
        getThemes()
        
        
        return true
    }
    
    func getCategories(){
        print("Getting Categories")
        guard let url = URL(string: Global.urlGetCategories)
        else {
            fatalError("Missing URL")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }

            guard let response = response as? HTTPURLResponse
            else {
                return
                
            }

            
            if response.statusCode == 200 {
                
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        let response = try JSONDecoder().decode(CategoriesResponse.self, from: data)
                        if(response.status){
                            print("Got Categories")
                            LocalDBHelper.writeData(data,fileName: Global.catJsonFileName)
                            AppUtils.saveImages(categoreis: response.data,index: 0, cachedHeler: ImageCachedHelper())
                            self.getForYou()
//                            catResponse = response
//                            getForYou()
                        }
//                        if(response.data.count != 0){
//                            selectedCat = response.categories[0]._id
//                        }
//                        mWallpaperCatModel = response
//                        isLoading = false
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            }else{
                print("Got the error: \(response.statusCode)")
            }
        }

        dataTask.resume()
    }
    
    func getThemes(){
        print("Getting Themes")
//        isLoading = true
        
        guard let url = URL(string: Global.urlGetThemes)
        else {
            fatalError("Missing URL")
        }
    

        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        


        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }

            guard let response = response as? HTTPURLResponse
            else {
                return
            }

            
            if response.statusCode == 200 {
                
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        let response = try JSONDecoder().decode(ThemesResponse.self, from: data)
                        if(response.status){
                            print("Themes Response")
                            print(response)
                            LocalDBHelper.writeData(data,fileName: Global.themesJsonFileName)
                            AppUtils.saveThemeImages(themes: response.data,index: 0, cachedHeler: ImageCachedHelper())
                            
                        }
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            }else{
                print("Got the error: \(response.statusCode)")
            }
        }

        dataTask.resume()
    }
    
    func getForYou(){
        
        //TODO: Make the device id dynamic
        let json: [String: Any] = ["device_id": "abcd"]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        guard let url = URL(string: Global.urlGetForU)
        else {
            fatalError("Missing URL")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // insert json data to the request
        urlRequest.httpBody = jsonData

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }

            guard let response = response as? HTTPURLResponse
            else {
                return
            }

            
            if response.statusCode == 200 {
                
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        let response = try JSONDecoder().decode(ForYouResponse.self, from: data)
                        if(response.status){
                            print("Got Categories")
                            LocalDBHelper.writeData(data, fileName: Global.forYouJsonFileName)
                            AppUtils.saveImages(categoreis: response.Popular,index: 0, cachedHeler: ImageCachedHelper())
                        }
//                        if(response.data.count != 0){
//                            selectedCat = response.categories[0]._id
//                        }
//                        mWallpaperCatModel = response
//                        isLoading = false
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            }else{
                print("Got the error: \(response.statusCode)")
                print(response)
            }
        }

        dataTask.resume()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      print(userInfo)


      completionHandler(UIBackgroundFetchResult.newData)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {

      let deviceToken:[String: String] = ["token": fcmToken ?? ""]
        print("Device token: ", deviceToken)
//        Global.firebase_id = fcmToken ?? ""
    
        print("Saving tokens")
        
        guard let url = URL(string: Global.urlSaveTokens)
        else {
            fatalError("Missing URL")
        }
    

        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        
        let parameters: [String: Any] = [
            "device_id": Global.device_id,
            "firebase_id": fcmToken ?? ""
        ]
        do {
            // convert parameters to Data and assign dictionary to httpBody of request
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
          } catch let error {
            print(error.localizedDescription)
            return
          }

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }

            guard let response = response as? HTTPURLResponse
            else {
                return
            }

            
            if response.statusCode == 200 {
                
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        let response = try JSONDecoder().decode(GeneralResponse.self, from: data)
                        if(response.status){
                            print("saved the value")
//                            remindersReponse = response
//                            quotesResponse = response
//                            isLoading = false
                        }
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            }else{
                print("Got the error: \(response.statusCode)")
            }
        }

        dataTask.resume()
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
      
    

    if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
    }

//    print(userInfo)

//      print(userInfo)
      
//      if let aps = userInfo["aps"] as? NSDictionary {
//          if let alert = aps["alert"] as? NSDictionary {
//              if let message = alert["body"] as? NSString {
//                  if let title = alert["title"] as? NSString{
//                      if title == Global.appName{
//                          completionHandler([[.banner, .badge, .sound]])
//                      }else{
//                          print("Title is: \(title)")
//                          print("body is: \(message)")
//                          @AppStorage("rememberItem", store: UserDefaults(suiteName: "group.com.kaizem.motivation")) var primaryItemData: Data = Data()
//                          guard let rememberItem = try? JSONDecoder().decode(AppliedWidgetModel.self, from: primaryItemData) else {
//                              print("Unable to decode primary item")
//                              return
//                          }
//                          let finalWidget = AppliedWidgetModel(id: 1, name: "\(Global.appName) Widget", quote: message as String, data: rememberItem., authorName: title as String)
//                          let newPrimaray = PrimaryWidget(primaryItem: finalWidget)
//                          newPrimaray.storeItem()
//                      }
//                  }
//                  else{
//                      print("Title is not found")
//                      completionHandler([[.banner, .badge, .sound]])
//                  }
//              }else{
//                  print("Message is not got")
//                  completionHandler([[.banner, .badge, .sound]])
//              }
//          } else if let alert = aps["alert"] as? NSString {
//              print("alert is String")
//              completionHandler([[.banner, .badge, .sound]])
//          }else{
//              print("Alert is not got")
//              completionHandler([[.banner, .badge, .sound]])
//          }
//      } else{
//          print("Aps is not got")
//          completionHandler([[.banner, .badge, .sound]])
//      }
    
    completionHandler([[.banner, .badge, .sound]])
  }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for Apple Remote Notifications")
            Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register")
    }


  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo

    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID from userNotificationCenter didReceive: \(messageID)")
    }

      print(userInfo)

            print(userInfo)
            
            if let aps = userInfo["aps"] as? NSDictionary {
                if let alert = aps["alert"] as? NSDictionary {
                    if let message = alert["body"] as? NSString {
                        notificationManager?.recievedNotificationFromChatID = message as String
                    }
                } else if let alert = aps["alert"] as? NSString {
                    notificationManager?.recievedNotificationFromChatID = alert as String
                }
            }
      
      notificationManager?.pageToNavigationTo = 1

    //TODO: UnComment This
    completionHandler()
  }
}
