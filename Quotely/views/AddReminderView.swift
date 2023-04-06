//
//  AddReminderView.swift
//  Quotely
//
//  Created by Brilliant Gamez on 8/12/22.
//

import SwiftUI
import AlertToast

struct AddReminderView: View {
    
    @EnvironmentObject private var eventStore: EventStore
    
    @State var showsDatePicker = false
    
    @State var selectedCat = ""
    @State var showAlert = false
    @State var showDialoge = false
    
    @State var selectedCategories: [CategoryModel] = []
    
    @State var number = 2
    @State var saving = false
    @State var sound = false
    @State var showToast = false
    @State var toastText = "Something Went Wrong"
    @State var isStart = true
    
    @State var maxActiveNumber = 2
    
    @State var loadingAdd = false
    
    
    @ObservedObject var adHelper = RewardedAdHelper()
    
    @State var catResponse: CategoriesResponse?
    @State var forYouResponse: ForYouResponse?
    
    
    
    
//    @State var startsAt = "09:00"
//    @State var endsAt = "22:00"
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var alreadyLoaded = false
    
    @State private var wakeUp = Date.now
    
    @State private var startDate = Date.now
    
    @State private var endDate : Date = Calendar.current.date(byAdding: .hour, value: 2, to: Date.now) ?? Date.now
    
    private var days = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    @State private var selectedDays: [String] = ["","","","","","",""]
    
    
    @State var isPremium = false
    
    
    var body: some View {
        GeometryReader{
            geometry in
            ZStack{
                VStack{
                        Spacer().frame(height: geometry.size.height*0.1)
                        VStack(alignment: .leading){
                            Spacer().frame(height: 5)
                            HStack{
                                Button {
                                    self.presentationMode.wrappedValue.dismiss()
                                } label: {
                                    Text(AppStrings.back).foregroundColor(AppColor.colorWhite)
                                }

                                Spacer()
                                
                                Button {
                                    addReminder()
        //                            self.presentationMode.wrappedValue.dismiss()
                                } label: {
                                    if saving{
                                        ProgressView()
                                    }else{
                                        Text(AppStrings.done).foregroundColor(AppColor.colorWhite)
                                    }
                                }.disabled(saving)
            

                            }.padding([.vertical],geometry.size.width*0.025)
                            
                            Text(AppStrings.addReminder).foregroundColor(AppColor.colorWhite).font(.system(size: 24)).padding([.horizontal],geometry.size.width*0.025)
                            
                    
                            

                            
                            ScrollView{
                                VStack{
                                    NavigationLink {
                                        CategoriesView(selectedCategories: $selectedCategories, showFvrt: false).navigationBarHidden(true).statusBar(hidden: true)
                                    } label: {
                                        HStack{
                                            Text(AppStrings.typeOfQuotes).font(.system(size: 18)).foregroundColor(AppColor.skyBlue)
                                            Spacer()
                                            HStack{
                                                Text(selectedCategories.isEmpty ? AppStrings.general : selectedCategories[0].category_name).font(.system(size: 16)).foregroundColor(AppColor.colorWhite)
                                                Spacer().frame(width: 10)
                                                Image( "arrow_forward").resizable().frame(width: 7, height: 12).foregroundColor(AppColor.colorWhite)
                                            }
                                        }.frame(height: geometry.size.height*0.03).padding().padding([.vertical
                                                                                                     ],8).background(AppColor.lightGrey2).cornerRadius(15)
                                    }.disabled(saving)

                                    
                                    HStack{
//                                        HStack(alignment: .bottom, spacing: 0){
//                                            Text(AppStrings.howMany).font(.system(size: 18)).foregroundColor(AppColor.skyBlue).padding(0)
//                                            Text(" (per day)").font(.system(size: 12)).foregroundColor(AppColor.skyBlue).padding(0)
//                                            Spacer()
//                                        }.padding(0)
//                                        VStack{
//                                            Text(AppStrings.howMany).font(.system(size: 18)).multilineTextAlignment(.leading).foregroundColor(AppColor.skyBlue).padding(0)
//                                            Text("(per day)").font(.system(size: 12)).multilineTextAlignment(.leading).foregroundColor(AppColor.skyBlue).padding(0)
//                                        }
                                        
                                        Text(AppStrings.howMany).font(.system(size: 18)).multilineTextAlignment(.leading).foregroundColor(AppColor.skyBlue).padding(0)
                                        Spacer()
                                        HStack{
                                            Button {
                                                if number>1{
                                                    number-=1
                                                }
                                            } label: {
                                                ZStack{
                                                    Image(systemName: "minus").resizable().frame(width: 21, height: 2).foregroundColor(AppColor.skyBlue)
                                                }.frame(width: 40, height: 40).background(AppColor.lightGrey3).cornerRadius(10)
                                            }.disabled(saving)

                                            
                                            Spacer()
                                            Text("\(number)x").font(.system(size: 18)).foregroundColor(AppColor.colorWhite)
                                            Spacer()
                                            Button {
                                                if number<Global.maxFrequency{
//                                                    number+=1
                                                    if isPremium || number<maxActiveNumber{
                                                        number+=1
                                    
                                                    }else{
                                                        showDialoge = true
                                                    }
                                                }
                                            } label: {
                                                ZStack{
                                                    Image(systemName: "plus").resizable().frame(width: 21, height: 21).foregroundColor(AppColor.skyBlue)
                                                }.frame(width: 40, height: 40).background(AppColor.lightGrey3).cornerRadius(10)
                                            }.disabled(saving)

                                        }.frame(width: geometry.size.width*0.4)
                                    }.frame(height: geometry.size.height*0.03).padding().padding([.vertical
                                                                                                 ],10).background(AppColor.lightGrey2).cornerRadius(15)
                                    
        //                            DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                                    
                                    HStack{
                                        Text(AppStrings.startsAt).font(.system(size: 18)).foregroundColor(AppColor.skyBlue)
                                        Spacer()
                                        HStack{
                                            Button {
                                                print("Date Picker is opened")
                                                startDate = Calendar.current.date(byAdding: .minute, value: -60, to: startDate) ?? Date.now
                                                
                                            } label: {
                                                ZStack{
                                                    Image(systemName: "minus").resizable().frame(width: 21, height: 2).foregroundColor(AppColor.skyBlue)
                                                }.frame(width: 40, height: 40).background(AppColor.lightGrey3).cornerRadius(10)
                                            }.disabled(saving)

                                            
                                            Spacer()
                                            Button {
                                                isStart = true
                                                showsDatePicker = true
                                            } label: {
                                                Text(AppUtils.get24HourTime(date: startDate)).font(.system(size: 18)).foregroundColor(AppColor.colorWhite)
                                            }.disabled(saving)

                                            Spacer()
                                            Button {
                                                startDate = Calendar.current.date(byAdding: .minute, value: 60, to: startDate) ?? Date.now
                                            } label: {
                                                ZStack{
                                                    Image(systemName: "plus").resizable().frame(width: 21, height: 21).foregroundColor(AppColor.skyBlue)
                                                }.frame(width: 40, height: 40).background(AppColor.lightGrey3).cornerRadius(10)
                                            }.disabled(saving)

                                        }.frame(width: geometry.size.width*0.4)
                                    }.frame(height: geometry.size.height*0.03).padding().padding([.vertical
                                                                                                 ],10).background(AppColor.lightGrey2).cornerRadius(15)
                                    
                                    HStack{
                                        Text(AppStrings.endAt).font(.system(size: 18)).foregroundColor(AppColor.skyBlue)
                                        Spacer()
                                        HStack{
                                            Button {
                                                endDate = Calendar.current.date(byAdding: .minute, value: -60, to: endDate) ?? Date.now
                                            } label: {
                                                ZStack{
                                                    Image(systemName: "minus").resizable().frame(width: 21, height: 2).foregroundColor(AppColor.skyBlue)
                                                }.frame(width: 40, height: 40).background(AppColor.lightGrey3).cornerRadius(10)
                                            }.disabled(saving)

                                            
                                            Spacer()
                                            Button {
                                                isStart=false
                                                showsDatePicker = true
                                            } label: {
                                                Text(AppUtils.get24HourTime(date: endDate)).font(.system(size: 18)).foregroundColor(AppColor.colorWhite)
                                            }.disabled(saving)

                                            Spacer()
                                            Button {
                                                endDate = Calendar.current.date(byAdding: .minute, value: 60, to: endDate) ?? Date.now
                                            } label: {
                                                ZStack{
                                                    Image(systemName: "plus").resizable().frame(width: 21, height: 21).foregroundColor(AppColor.skyBlue)
                                                }.frame(width: 40, height: 40).background(AppColor.lightGrey3).cornerRadius(10)
                                            }.disabled(saving)

                                        }.frame(width: geometry.size.width*0.4)
                                    }.frame(height: geometry.size.height*0.03).padding().padding([.vertical
                                                                                                 ],10).background(AppColor.lightGrey2).cornerRadius(15)
                                    
                                    VStack(alignment:.leading){
                                        
                                        Text(AppStrings.repeatString).font(.system(size: 18)).foregroundColor(AppColor.skyBlue)
                                        Spacer().frame(height: 20)
                                        ScrollView(.horizontal,showsIndicators: false){
                                            HStack{
                                                ForEach(Array(days.enumerated()),id: \.offset){
                                                    index , day in
                                                    Button {
                                                        if selectedDays[index] == days[index]{
                                                            selectedDays[index] = ""
                                                        }else{
                                                            selectedDays[index] = days[index]
                                                        }
                                                        
                                                    } label: {
                                                        ZStack{
                                                            Text(day).font(.system(size: 14)).foregroundColor(AppColor.colorWhite)
                                                        }.frame(width: 40, height: 40).background(selectedDays[index] == days[index] ? AppColor.blue : AppColor.lightGrey3).cornerRadius(40)
                                                    }.disabled(saving)

                                                }
                                            }
                                        }
                                    }.padding().padding([.vertical
                                                                                                 ],10).background(AppColor.lightGrey2).cornerRadius(15)
                                    
//                                    HStack{
//                                        Text(AppStrings.sound).font(.system(size: 18)).foregroundColor(AppColor.skyBlue)
//                                        Spacer()
//                                        Button {
//                                            sound.toggle()
//                                        } label: {
//                                            Toggle("",isOn: $sound).tint(AppColor.blue)
//
//                                        }.disabled(saving)
//
//                                    }.frame(height: geometry.size.height*0.03).padding().padding([.vertical
//                                                                                                 ],10).background(AppColor.lightGrey2).cornerRadius(15)
                                    
                                }.padding().background(AppColor.lightGrey).cornerRadius(10,corners: .allCorners)
                            }
                            
                            Spacer()
                            if showsDatePicker {
                                MyTimePicker(date: isStart ? $startDate : $endDate, show: $showsDatePicker)
                                            }
                        }.padding([.vertical]).padding([.horizontal],10).background(AppColor.grey).cornerRadius(20, corners: [.topLeft, .topRight])
                        
                        
                }
                if showDialoge {
                    Rectangle().frame(width: geometry.size.width, height: geometry.size.height).foregroundColor(Color.black.opacity(0.8))
                    
                    VStack{
                        HStack(alignment: .top){
                            Spacer().frame(width: 20)
                            Spacer()
                            Text("Get more frequency\nfor your reminder").font(.system(size: 24)).foregroundColor(AppColor.colorWhite).multilineTextAlignment(.center)
                            Spacer()
                            Button(action: {
                                showDialoge = false
                                print("Close Button is Clicked")
                                        }, label: {
                                            Image( "close").foregroundColor(Color.white).padding(8)
                                        }).background(Color.white.opacity(0.2)).cornerRadius(25)

                        }
                        
                        Spacer().frame(height: 30)
                        
                        Button {
                            adHelper.createRewardedAd()
                            loadingAdd = true
                        } label: {
                            HStack{
                                ZStack{
                                    Image("video").resizable().frame(width: 26,height: 20).foregroundColor(AppColor.colorWhite).padding()
                                }.frame(width: 50, height: 50).background(Color.white.opacity(0.2)).cornerRadius(100)
                                
                                VStack(alignment: .leading){
                                    Text("Unlock one Frequency").font(.system(size: 18)).bold().foregroundColor(AppColor.colorWhite)
                                    Spacer().frame(height: 5)
                                    Text(AppStrings.watchAdd).font(.system(size: 18)).foregroundColor(AppColor.colorWhite).font(.system(size: 12))
                                }
                                Spacer()
                            }.padding(10).background(AppColor.green).cornerRadius(15)
                        }

                        
                        Spacer().frame(height: 15)
                        
                        NavigationLink {
                            PaymentView(goBack: true)
                        } label: {
                            HStack{
                                ZStack{
                                    Image("premium").resizable().frame(width: 24,height: 24).foregroundColor(AppColor.colorWhite).padding()
                                }.frame(width: 50, height: 50).background(Color.white.opacity(0.2)).cornerRadius(100)
                                
                                VStack(alignment: .leading){
                                    Text(AppStrings.getUnlimitedAccess).font(.system(size: 18)).bold().foregroundColor(AppColor.colorWhite)
                                    Spacer().frame(height: 5)
                                    Text(AppStrings.threeDaysTrial).font(.system(size: 18)).foregroundColor(AppColor.colorWhite).font(.system(size: 12))
                                }
                                Spacer()
                            }.padding(10).background(AppColor.skyBlue).cornerRadius(15)
                        }

                        
                    }.padding().background(AppColor.lightGrey).cornerRadius(15).padding([.horizontal])
                }
                if loadingAdd{
                    ZStack{
                        AppColor.colorBlack.opacity(0.6)
                        ProgressView()
                    }.frame(width: geometry.size.width, height: geometry.size.height)
                }
            }.background(AppColor.colorBlack).toast(isPresenting: $showToast){
                
                AlertToast(displayMode: .banner(.pop), type: .regular, title: toastText,style: AlertToast.AlertStyle.style(backgroundColor: AppColor.colorBlack.opacity(0.4),titleColor: AppColor.colorWhite))
            }.onAppear{
                
                PurchaseService.getPremiumStatus {
                    isPremium = true
                }
                
                if !alreadyLoaded{
                    let minute = Calendar.current.component(.minute, from: Date.now)
                    
                    
                    
                    print("Minutes \(minute)")
                    startDate = Calendar.current.date(byAdding: .minute, value: -minute, to: Date.now) ?? Date.now
                    
                    let hour = Calendar.current.component(.hour, from: startDate)
                    
                    print("Hour: \(hour)")
                    
                    //Hou
                    let differenceHour = 9 - hour
                    
                    startDate = Calendar.current.date(byAdding: .hour, value: differenceHour, to: startDate) ?? Date.now
                    
//                    let datea = Calendar.current.date()
                    
//                    var components = DateComponents()
//                    components.hour = 09
//                    components.minute = 00
//                    startDate = Calendar.current.date(from: components) ?? Date.now
                    
                    endDate = Calendar.current.date(byAdding: .hour, value: 12, to: startDate) ?? Date.now
                    alreadyLoaded = true
                }
            }.onChange(of: adHelper.isRewarded) { v in
                if self.adHelper.isRewarded ?? false{
//                    print("Khoti k bachay ho jaa")
                    loadingAdd = false
                    showDialoge = false
                    number = number + 1
                    if maxActiveNumber<number{
                        maxActiveNumber = number
                    }
                    adHelper.isRewarded = nil
                }else{
                    if loadingAdd{
                        loadingAdd = false
                        toastText = "No Ad Found. Try another time"
                        showToast = true
                        adHelper.isRewarded = nil
                    }
                }
            }
        }.edgesIgnoringSafeArea([.top,.bottom])
    }
    
    func internetError(){
        saving = false
        toastText = "Check Your Internet Connection"
        showToast = true
    }
    
    func addReminder(){
        saving = true
        print("Getting Reminders")
//        isLoading = true
        
        guard let url = URL(string: Global.urlSaveReminder)
        else {
            internetError()
            fatalError("Missing URL")
        }
    
        let nowDate = Date.now
        
        

        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        var ids: [String] = []
        for index in 0..<selectedCategories.count{
            ids.append(selectedCategories[index]._id)
        }
        
        print(ids)
        
        var mSelectedDays: [String] = []
        for item in selectedDays{
            if !item.isEmpty{
                mSelectedDays.append(item)
            }
        }
        
        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let strStartDate = formatter.string(from: startDate)
        let strEndDate = formatter.string(from: endDate)
        
        
        print("Start Date: \(startDate)")
        print("End Date: \(endDate)")
        print("Now Date \(nowDate)")
        
        print("String Start Date: \(strStartDate)")
        print("String End Date: \(strEndDate)")
        
        let dayOfWeek = nowDate.dayOfWeek()
        
        print("day of week: \(dayOfWeek!)")
        print("selected Days: \(mSelectedDays)")
        
        var isInRange : Bool = false
        
        if mSelectedDays.isEmpty || haveDays(currnetDay: dayOfWeek ?? "", selectedDays: mSelectedDays){
            let nowMinute = Calendar.current.component(.minute, from: nowDate)
            let nowHour = Calendar.current.component(.hour, from: nowDate)
            
            let startMinute = Calendar.current.component(.minute, from: startDate)
            let startHour = Calendar.current.component(.hour, from: startDate)
            
            let endMinute = Calendar.current.component(.minute, from: endDate)
            let endHour = Calendar.current.component(.hour, from: endDate)
            
            
            
            if(nowHour <= endHour && nowHour >= startHour){
                if nowHour == startHour && nowHour == endHour{
                    if nowMinute <= endMinute && nowMinute >= startMinute{
                        isInRange = true
                    }else{
                        isInRange = false
                    }
                }else if nowHour == startHour{
                    if nowMinute >= startMinute {
                        isInRange = true
                    }else{
                        isInRange = false
                    }
                }else if nowHour == endHour{
                    if nowMinute <= endMinute{
                        isInRange = true
                    }else{
                        isInRange = false
                    }
                }else{
                    isInRange = true
                }
            }else{
                isInRange = false
            }
        }
        
        print("in Range: \(isInRange)")
        
        
        
        let parameters: [String: Any] = [
            "device_id": Global.device_id,
            "types_of_quotes": ids,
            "start_time": strStartDate,
            "end_time": strEndDate,
            "sound": "\(sound)",
            "repeat": mSelectedDays,
            "how_many": "\(number)",
            "current_day" : dayOfWeek ?? "",
            "current_hour" : isInRange
        ]
        do {
            // convert parameters to Data and assign dictionary to httpBody of request
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
          } catch let error {
            print(error.localizedDescription)
              internetError()
            return
          }

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                internetError()
                return
            }

            guard let response = response as? HTTPURLResponse
            else {
                internetError()
                return
            }

            
            if response.statusCode == 200 {
                
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        let response = try JSONDecoder().decode(GeneralResponse.self, from: data)
                        if(response.status){
                            print("Added Reminders")
                            AppUtils.callAdjustEvent(token: AdjustTokens.quoteReminderSet)
                            saving = false
                            self.presentationMode.wrappedValue.dismiss()
//                            remindersReponse = response
//                            quotesResponse = response
//                            isLoading = false
                        }else{
                            internetError()
                        }
//                        if(response.data.count != 0){
//                            selectedCat = response.categories[0]._id
//                        }
//                        mWallpaperCatModel = response
//                        isLoading = false
                    } catch let error {
                        internetError()
                        print("Error decoding: ", error)
                    }
                }
            }else{
                internetError()
                print("Got the error: \(response.statusCode)")
            }
        }

        dataTask.resume()
    }
    
    func haveDays(currnetDay: String, selectedDays: [String]) -> Bool{
        var value = false
        for item in selectedDays{
            if currnetDay.lowercased().contains(item.lowercased()){
                value = true
                break
            }
        }
        return value
    }
}

struct AddReminderView_Previews: PreviewProvider {
    static var previews: some View {
        AddReminderView()
    }
}

extension Array where Element: Equatable {

    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }

}

extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}

extension Date {
    public func setTime(hour: Int, min: Int, sec: Int, timeZoneAbbrev: String = "UTC") -> Date? {
        let x: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let cal = Calendar.current
        var components = cal.dateComponents(x, from: self)

        components.timeZone = TimeZone(abbreviation: timeZoneAbbrev)
        components.hour = hour
        components.minute = min
        components.second = sec

        return cal.date(from: components)
    }
}
