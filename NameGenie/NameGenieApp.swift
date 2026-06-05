import SwiftUI
import SwiftData

@main
struct NameGenieApp: App {
    let container: ModelContainer = {
        let schema = Schema([FavoriteName.self])
        let config = ModelConfiguration(cloudKitDatabase: .none)
        return try! ModelContainer(for: schema, configurations: config)
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
