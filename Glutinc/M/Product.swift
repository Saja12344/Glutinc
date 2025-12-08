   struct Product: Identifiable {
        let id = UUID()
        let imageName: String
        let name: String
        let username: String
        let rating: Double
        let isGlutenFree: Bool
    }