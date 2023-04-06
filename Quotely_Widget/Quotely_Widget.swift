//
//  Quotely_Widget.swift
//  Quotely_Widget
//
//  Created by Brilliant Gamez on 8/12/22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    @AppStorage("rememberItem", store: UserDefaults(suiteName: "group.com.kaizem.motivation")) var primaryItemData: Data = Data()
    
    func placeholder(in context: Context) -> SimpleEntry {
        print("Widget: PlaceHolder is called")
        let rememberItem = AppliedWidgetModel(id: 101, name: "widget1", quote: [],color: "#ffffff", font_family: "")
        return SimpleEntry(date: Date(),rememberItem: rememberItem, quote: "Active A Widget From App.", author: "\(Global.appName)")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        print("Widget: getSnapchat is called")
        let rememberItem = try? JSONDecoder().decode(AppliedWidgetModel.self, from: primaryItemData)
        if rememberItem == nil{
            
            let entry = SimpleEntry(date: Date(),rememberItem: AppliedWidgetModel(id: 101, name: "widget1", quote: [],color: "#ffffff", font_family: ""), quote: "Active A Widget From App.", author: "\(Global.appName)")
            completion(entry)
        }else{
            
            let entry = SimpleEntry(date: Date(),rememberItem: rememberItem!, quote: "", author: "")
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        print("Widget: getTimeline is called")
        let rememberItem = try? JSONDecoder().decode(AppliedWidgetModel.self, from: primaryItemData)
        var entries = [SimpleEntry]()
        if rememberItem == nil{
            let entry = SimpleEntry(date: Date(),rememberItem: AppliedWidgetModel(id: 101, name: "widget1", quote: [],color: "#ffffff", font_family: ""), quote: "Active A Widget From App.", author: "\(Global.appName)")
            entries.append(entry)
        }else{
            if rememberItem!.quote.isEmpty{
                let entry = SimpleEntry(date: Date(),rememberItem: AppliedWidgetModel(id: 101, name: "widget1", quote: [],color: "#ffffff", font_family: ""), quote: "Active A Widget From App.", author: "\(Global.appName)")
                entries.append(entry)
            }else{
                let currentDate = Date()
                for hourOffset in 0 ..< 15 {
                    let mQuote = rememberItem!.quote.randomElement()
                    print(hourOffset)
                    let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset, to: currentDate)!
                    let entry = SimpleEntry(date: entryDate,rememberItem: rememberItem!, quote: mQuote!.name, author: mQuote!.author ?? "")
                    entries.append(entry)
                }
            }
        }
//        var entries = [SimpleEntry]()
        

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
        
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let rememberItem: AppliedWidgetModel
    let quote: String
    let author: String
//    let quote: String
//    let author: String
//    let minute: Int
}

struct Quotely_WidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family
    
    var deeplinkURL: URL
    
    init(entry: Provider.Entry){
        self.entry = entry
        let queryItems = [URLQueryItem(name: "quote", value: entry.quote), URLQueryItem(name: "author", value: entry.author)]
        var urlComps = URLComponents(string: "widget-deeplink://")!
        urlComps.queryItems = queryItems
        deeplinkURL = urlComps.url!
    }

    var body: some View {
        switch family {
                case .accessoryRectangular:
            ZStack{
//                if entry.rememberItem.data != nil{
//                    Image(uiImage: UIImage(data: entry.rememberItem.data!)!).resizable().scaledToFill()
//                }else{
//                    Image("theme_default").resizable().scaledToFill()
//                }
    //            Image("widget_background")
                VStack{
                    Text("\(entry.quote)").padding([.horizontal],20).multilineTextAlignment(.center).font(.custom(entry.rememberItem.font_family, size: 10)).foregroundColor(Color(AppColor.hexStringToUIColor(hex: entry.rememberItem.color)))
                    Spacer().frame(height: 5)
                    Text("~\(entry.author)").padding([.horizontal],20).multilineTextAlignment(.center).font(.custom(entry.rememberItem.font_family, size: 8)).foregroundColor(Color(AppColor.hexStringToUIColor(hex: entry.rememberItem.color)))
                }
            }
                case .systemMedium:
            ZStack{
                if entry.rememberItem.data != nil{
                    Image(uiImage: UIImage(data: entry.rememberItem.data!) ?? UIImage(named: "theme_default")!).resizable().scaledToFill()
                }else{
                    Image("theme_default").resizable().scaledToFill()
                }
    //            Image("widget_background")
                VStack{
                    Text("\(entry.quote)").lineLimit(3).padding([.horizontal],20).multilineTextAlignment(.center).font(.custom(entry.rememberItem.font_family, size: 20)).foregroundColor(Color(AppColor.hexStringToUIColor(hex: entry.rememberItem.color)))
                    Spacer().frame(height: 5)
                    Text("~\(entry.author)").padding([.horizontal],20).multilineTextAlignment(.center).font(.custom(entry.rememberItem.font_family, size: 12)).foregroundColor(Color(AppColor.hexStringToUIColor(hex: entry.rememberItem.color)))
                }
            }.widgetURL(deeplinkURL)
                default:
                    Text("No Size defined")
                }

    }
}

@main
struct Quotely_Widget: Widget {
    let kind: String = "(\(Global.appName)_Widget"

    var body: some WidgetConfiguration {
        if #available(iOSApplicationExtension 16.0, *) {
            return StaticConfiguration(kind: kind, provider: Provider()) { entry in
                Quotely_WidgetEntryView(entry: entry)
            }
            .configurationDisplayName("Uplift Widget")
            .description("This is Uplift widget.")
            .supportedFamilies([.systemMedium,.accessoryRectangular])
        } else {
            return StaticConfiguration(kind: kind, provider: Provider()) { entry in
                Quotely_WidgetEntryView(entry: entry)
            }
            .configurationDisplayName("Uplift Widget")
            .description("This is Uplift widget.")
            .supportedFamilies([.systemMedium])
        }
    }
}

struct Quotely_Widget_Previews: PreviewProvider {
    static let rememberItem = AppliedWidgetModel(id: 101, name: "widget1", quote: [], color: "#ffffff", font_family: "")
    static var previews: some View {
        Quotely_WidgetEntryView(entry: SimpleEntry(date: Date(), rememberItem: rememberItem
                                                  ,quote: "",author: ""))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
