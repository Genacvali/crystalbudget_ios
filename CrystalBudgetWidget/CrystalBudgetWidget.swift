import WidgetKit
import SwiftUI

struct CrystalBudgetWidget: Widget {
    let kind: String = "CrystalBudgetWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetTimelineProvider()) { entry in
            CrystalBudgetWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Баланс")
        .description("Показывает текущий баланс")
        .supportedFamilies([.systemSmall])
    }
}
