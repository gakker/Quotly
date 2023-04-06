//
//  PurchaseService.swift
//  Quotely
//
//  Created by Brilliant Gamez on 7/18/22.
//

import Foundation
import RevenueCat

class PurchaseService{
    static func purchase(productId: String?, successfulPurchase: @escaping(Error?,Bool) -> Void) {
        guard productId != nil else {
            return
        }
        
        //Perform Purchase
        Purchases.shared.getProducts([productId!]) { (products) in
            
            if !products.isEmpty{
                let skProduct = products[0]
                
                
                
                
                Purchases.shared.purchase(product: skProduct) { (transaction, purchaserInfo, error, userCanceled) in
                    successfulPurchase(error,userCanceled)
                }
            }
            
        }
    }
    
    static func getPackages(productId: String?, successfulPurchase: @escaping([Package],Double) -> Void) {
        guard productId != nil else {
            return
        }
        
        //Perform Purchase
        Purchases.shared.getOfferings { (offerings, error) in
            if let packages = offerings?.current?.availablePackages{
                var maxVal: Double = 0.0
                for item in packages{
                    let product = item.storeProduct
                    if product.subscriptionPeriod != nil{
                        var days : Int = 0
                        var unit : String = "\(product.subscriptionPeriod!.unit)"
                        
                        if unit == "day"{
                            days = product.subscriptionPeriod!.value
                        }else if unit == "week"{
                            days = product.subscriptionPeriod!.value * 7
                        }else if unit == "month"{
                            days = product.subscriptionPeriod!.value * 30
                        }else if unit == "year"{
                            days = product.subscriptionPeriod!.value * 365
                        }else {
                            days = 0
                        }
                        
                        let pricePerDay = product.price/Decimal(days)
                        
                        let doubeValue = pricePerDay.doubleValue
                        
                        if doubeValue > maxVal {
                            maxVal = doubeValue
                        }
                        
                    }
                    
                }
                
                if maxVal == 0 {
                    maxVal = 1.0
                }
                
                print("Max Value in PurchaseService: \(maxVal)")
                
                successfulPurchase(packages,maxVal)
                
                }
            
        }
    }
    
    
    static func getPremiumStatus(successfulPurchase: @escaping() -> Void) {
        //TODO: Make it dynamic
//        successfulPurchase()
        if UserDefaults.standard.isPremiumAccount{
            successfulPurchase()
        }
//        Purchases.shared.getCustomerInfo { (customerInfo, error) in
//            // access latest customerInf
//            if error == nil {
//                if customerInfo?.entitlements["premium"]?.isActive == true {
//                  // user has access to "your_entitlement_id"
//                    successfulPurchase()
//                }
//            }
//        }
    }
    
    
}
