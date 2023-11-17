//
//  ContentView.swift
//  ManaBoxCard
//
//  Created by MacBook Pro on 10/11/23.
//

// 10 November, Done Collection list, can Search, and can sort by name

import SwiftUI

import Foundation
struct Card: Codable {
    let object: String
    let total_cards: Int
    let has_more: Bool
    let data: [CardData]
}

struct CardData: Codable {
    let object: String?
    let id: String?
    let oracle_id: String?
    let multiverse_ids: [Int]?
    let mtgo_id: Int?
    let arena_id: Int?
    let tcgplayer_id: Int?
    let cardmarket_id: Int?
    let name: String?
    let lang: String?
    let released_at: String?
    let uri: String?
    let scryfall_uri: String?
    let layout: String?
    let highres_image: Bool?
    let image_status: String?
    let image_uris: ImageURIs?
    let mana_cost: String?
    let cmc: Double?
    let type_line: String?
    let oracle_text: String?
    let colors: [String]?
    let color_identity: [String]?
    let keywords: [String]?
    let legalities: Legalities?
    let games: [String]?
    let reserved: Bool?
    let foil: Bool?
    let nonfoil: Bool?
    let finishes: [String]?
    let oversized: Bool?
    let promo: Bool?
    let reprint: Bool?
    let variation: Bool?
    let set_id: String?
    let set: String?
    let set_name: String?
    let set_type: String?
    let set_uri: String?
    let set_search_uri: String?
    let scryfall_set_uri: String?
    let rulings_uri: String?
    let prints_search_uri: String?
    let collector_number: String?
    let digital: Bool?
    let rarity: String?
    let flavor_text: String?
    let card_back_id: String?
    let artist: String?
    let artist_ids: [String]?
    let illustration_id: String?
    let border_color: String?
    let frame: String?
    let frame_effects: [String]?
    let security_stamp: String?
    let full_art: Bool?
    let textless: Bool?
    let booster: Bool?
    let story_spotlight: Bool?
    let promo_types: [String]?
    let edhrec_rank: Int?
    let penny_rank: Int?
    let prices: Prices?
    let related_uris: RelatedURIs?
    let purchase_uris: PurchaseURIs?
}


struct ImageURIs: Codable {
    let small: String?
    let normal: String?
    let large: String?
    let png: String?
    let art_crop: String?
    let border_crop: String?
}

struct Legalities: Codable {
    let standard: String?
    let future: String?
    let historic: String?
    let gladiator: String?
    let pioneer: String?
    let explorer: String?
    let modern: String?
    let legacy: String?
    let pauper: String?
    let vintage: String?
    let penny: String?
    let commander: String?
    let oathbreaker: String?
    let brawl: String?
    let historicbrawl: String?
    let alchemy: String?
    let paupercommander: String?
    let duel: String?
    let oldschool: String?
    let premodern: String?
    let predh: String?
}

struct Prices: Codable {
    let usd: String?
    let usd_foil: String?
    let usd_etched: String?
    let eur: String?
    let eur_foil: String?
    let tix: String?
}

struct RelatedURIs: Codable {
    let gatherer: String?
    let tcgplayer_infinite_articles: String?
    let tcgplayer_infinite_decks: String?
    let edhrec: String?
}

struct PurchaseURIs: Codable {
    let tcgplayer: String?
    let cardmarket: String?
    let cardhoarder: String?
}


struct ContentView: View {

    @State private var searchCard: String = ""
    @State private var cards: [CardData] = []
    @State private var selectedSortOption: SortOption = .Default
    @State private var showingActionSheet = false

    let columns = [
        GridItem(.adaptive(minimum: 100))
    ]

    enum SortOption: String, CaseIterable, Identifiable {
        case Default = "Default"
        case sortByName = "Sort A-Z"
        case sortByNameDescending = "Sort Z-A"
//        case sortByType = "Sort by Type"
        case sortByRarity = "Sort by Rarity"
        case sortByColor = "Sort by Color"

        var id: String { self.rawValue }
    }

    var body: some View {
            NavigationView {
                ZStack{
                    
                    VStack {
                        HStack {
                            SearchBar(text: $searchCard)
                                .padding(.horizontal)
                            
                            Button(action: {
                                showingActionSheet = true
                            }) {
                                Text("Sort")
                                        .font(.system(size: 16)) // Change font size
                                        .fontWeight(.bold) // Make text bold
                                        .frame(minWidth: 0, maxWidth: 70, maxHeight:8) // Make button width match parent
                                        .padding() // Add padding
                                        .background(Color.blue) // Change background color
                                        .foregroundColor(.white) // Change text color
                                        .cornerRadius(10) // Make corners rounded
                            }

                            .actionSheet(isPresented: $showingActionSheet) {
                                ActionSheet(title: Text("Sort By"), buttons: SortOption.allCases.map { option in
                                    .default(Text(option.rawValue)) { selectedSortOption = option }
                                })
                            }
                            .padding(.horizontal, 15)// Add horizontal padding
                        }
        
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(filteredCards.indices, id: \.self) { index in
                                    NavigationLink(destination: CardDetailView(cards: filteredCards, currentIndex: index)) {
                                        let card = filteredCards[index]
                                        AsyncImage(url: URL(string: card.image_uris?.normal ?? "")!) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear {
                        if let url = Bundle.main.url(forResource: "WOT-Scryfall", withExtension: "json") {
                            do {
                                let data = try Data(contentsOf: url)
                                let decoder = JSONDecoder()
                                let card = try decoder.decode(Card.self, from: data)
                                self.cards = card.data
                            } catch {
                                print("Error decoding JSON: \(error)")
                            }
                        }
                    }
                }
            }
        
        var filteredCards: [CardData] {
            let filtered = cards.filter { card in
                searchCard.isEmpty || (card.name?.localizedCaseInsensitiveContains(searchCard) == true)
            }
            
            switch selectedSortOption {
            case .Default:
                return filtered
            case .sortByName:
                return filtered.sorted { $0.name ?? "" < $1.name ?? "" }
            case .sortByNameDescending:
                return filtered.sorted { $0.name ?? "" > $1.name ?? "" }
                //        case .sortByType:
                //            return filtered.sorted { $0.type_line ?? "" < $1.type_line ?? "" }
            case .sortByRarity:
                return filtered.sorted { $0.rarity ?? "" < $1.rarity ?? "" }
            case .sortByColor:
                return filtered.sorted {
                    let color0 = $0.color_identity?.first ?? ""
                    let color1 = $1.color_identity?.first ?? ""
                    return color0 < color1
                }
            }
        }
    }
}


struct CardDetailView: View {

    let cards: [CardData]
    @State private var currentIndex: Int
    @State private var selectedTab = 0
    @State private var showingFullImage = false
    
    init(cards: [CardData], currentIndex: Int) {
        self.cards = cards
        _currentIndex = State(initialValue: currentIndex)
    }
    
    var body: some View {
        let card = cards[currentIndex]
        ScrollView {
            ZStack{
                VStack {
                    HStack{
                        Button(action: {
                            if currentIndex > 0 {
                                currentIndex -= 1
                            }
                        }) {
                            Image(systemName: "arrow.left") // replace with your arrow image
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showingFullImage = true
                        }) {
                            AsyncImage(url: URL(string: card.image_uris?.art_crop ?? "")!) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                        .padding(.top)
                        
                        Spacer()
                        
                        Button(action: {
                            if currentIndex < cards.count - 1 {
                                currentIndex += 1
                            }
                        }) {
                            Image(systemName: "arrow.right") // replace with your arrow image
                        }
                    }
                    
                    Text("Illustrated By \(card.artist ?? "")")
                        .font(.headline)
                        .padding(.bottom, 8)
                        .foregroundColor(.black)
                    
                    
                    Spacer()
                    
                    HStack (spacing: 5) {
                        Button(action: {
                            selectedTab = 0
                        }) {
                            Text("Versions")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(selectedTab == 0 ? .white : .black)
                                .background(selectedTab == 0 ? Color.red : Color.clear)
                                .cornerRadius(15)
                                .overlay( RoundedRectangle(cornerRadius: 15) .stroke(Color.gray, lineWidth: 1) // Warna dan ketebalan border
                                )
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            selectedTab = 1
                        }) {
                            Text("Rulings")
                                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                                .padding()
                                .foregroundColor(selectedTab == 1 ? .white : .black)
                                .background(selectedTab == 1 ? Color.red : Color.clear)
                                .cornerRadius(15)
                                .overlay( RoundedRectangle(cornerRadius: 15) .stroke(Color.gray, lineWidth: 1) // Warna dan ketebalan border
                                )
                        }
                    }
                    .frame(maxWidth: .infinity) // Menempatkan HStack di tengah layar
                    .padding()
                    Spacer()
                    
                    Divider()
                    
                    if selectedTab == 0 {
                        VStack {
                            
                            
                            HStack {
                                Text("\(card.name ?? "") ")
                                    .font(.title)
                                    .fontWeight(.bold)
                                //                                    .padding(.top)
                                ForEach(card.mana_cost?.manaSymbols ?? [], id: \.self) { symbol in
                                    ZStack {
                                        Image(uiImage: symbol)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                        Image(uiImage: symbol)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                    }
                                }
                            }
                            Divider()
                            
                            VStack{
                                Text(card.type_line ?? "")
                                    .font(.title)
                                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                    .padding(.leading)
                                
                                Divider()
                                
                                Text(card.oracle_text ?? "")
                                    .font(.body)
                                    .padding(.bottom)
//                                OracleTextView(oracleText: card.oracle_text ?? "")
//                                        .font(.body)
//                                        .padding(.bottom)
                                
                                Text(card.flavor_text ?? "")
                                    .font(.body)
                                    .padding(.bottom)
                            }
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                            .padding()
                            .background(Color.init(red: 240/255, green: 240/255, blue: 240/255))
                            .cornerRadius(15)
                            .overlay( RoundedRectangle(cornerRadius: 15) .stroke(Color.gray, lineWidth: 1) // Warna dan ketebalan border
                            )
                            
                        }
                        Spacer()
                    }
                    
                    else if selectedTab == 1 {
                        Text("Legalities")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top)
                        
                        LegalitiesView(legalities: card.legalities)
                    }
                    
                }
                
                if showingFullImage {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showingFullImage = false
                        }
                    
                    VStack {
                        AsyncImage(url: URL(string: card.image_uris?.normal ?? "")!) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .padding()
                        Button(action: {
                            showingFullImage = false
                        }) {
                            Text("Close")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.clear)
                    .cornerRadius(20)
                    .shadow(radius: 20)
                }
                
                
                
            }
            
            
        }
        .navigationTitle(card.name ?? "")
    }
}

extension String {
    var manaSymbols: [UIImage] {
        var symbols: [UIImage] = []

        let components = self.components(separatedBy: "}")
        for component in components {
            let trimmedComponent = component.replacingOccurrences(of: "{", with: "")
            switch trimmedComponent {
            case "W":
                symbols.append(UIImage(named: "W") ?? UIImage())
            case "U":
                symbols.append(UIImage(named: "U") ?? UIImage())
            case "B":
                symbols.append(UIImage(named: "B") ?? UIImage())
            case "R":
                symbols.append(UIImage(named: "R") ?? UIImage())
            case "G":
                symbols.append(UIImage(named: "G") ?? UIImage())
            case "1":
                symbols.append(UIImage(named: "1") ?? UIImage())
            case "2":
                symbols.append(UIImage(named: "2") ?? UIImage())
            case "3":
                symbols.append(UIImage(named: "3") ?? UIImage())
            case "4":
                symbols.append(UIImage(named: "4") ?? UIImage())
            case "5":
                symbols.append(UIImage(named: "5") ?? UIImage())
            case "0":
                symbols.append(UIImage(named: "0") ?? UIImage())
            case "7":
                symbols.append(UIImage(named: "7") ?? UIImage())
            // Add the rest of your cases here...
            default:
                break
            }
        }

        return symbols
    }
}

struct LegalitiesView: View {
    let legalities: Legalities?
    
    var body: some View {
        VStack(alignment: .leading) {
            
            if let formattedLegalities = legalities?.formattedLegalities {
                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    ForEach(formattedLegalities, id: \.self) { legality in
                        legalityRow(title: legality.title, legality: legality.status)
                    }
                }
            }
        }
        .padding()
    }

    func legalityRow(title: String, legality: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Spacer()

            Text(legality.uppercased())
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .center)
                .lineLimit(1)
                .background(legalityBackgroundColor(legality))
                .minimumScaleFactor(0.8)
        }
        .listRowInsets(EdgeInsets())
    }

    func legalityBackgroundColor(_ legality: String) -> Color {
        switch legality {
        case "legal":
            return Color.green
        case "not_legal":
            return Color.gray
        default:
            return Color.clear
        }
    }
}

extension Legalities {
    var formattedLegalities: [LegalitiesTuple] {
        return [
            LegalitiesTuple(title: "Standard", status: standard ?? ""),
            LegalitiesTuple(title: "Future", status: future ?? ""),
            LegalitiesTuple(title: "Historic", status: historic ?? ""),
            LegalitiesTuple(title: "Gladiator", status: gladiator ?? ""),
            LegalitiesTuple(title: "Pioneer", status: pioneer ?? ""),
            LegalitiesTuple(title: "Explorer", status: explorer ?? ""),
            LegalitiesTuple(title: "Modern", status: modern ?? ""),
            LegalitiesTuple(title: "Legacy", status: legacy ?? ""),
            LegalitiesTuple(title: "Pauper", status: pauper ?? ""),
            LegalitiesTuple(title: "Vintage", status: vintage ?? ""),
            LegalitiesTuple(title: "Penny", status: penny ?? ""),
            LegalitiesTuple(title: "Commander", status: commander ?? ""),
            LegalitiesTuple(title: "Oathbreaker", status: oathbreaker ?? ""),
            LegalitiesTuple(title: "Brawl", status: brawl ?? ""),
            LegalitiesTuple(title: "Historic Brawl", status: historicbrawl ?? ""),
            LegalitiesTuple(title: "Alchemy", status: alchemy ?? ""),
            LegalitiesTuple(title: "Pauper Commander", status: paupercommander ?? ""),
            LegalitiesTuple(title: "Duel", status: duel ?? ""),
            LegalitiesTuple(title: "Old School", status: oldschool ?? ""),
            LegalitiesTuple(title: "Premodern", status: premodern ?? ""),
            LegalitiesTuple(title: "PrEDH", status: predh ?? "")
        ]
    }
}

//struct OracleTextView: View {
//    let oracleText: String
//
//    var body: some View {
//        let components = oracleText.components(separatedBy: "}")
//        return ForEach(components, id: \.self) { component in
//            let symbolComponents = component.components(separatedBy: "{")
//            if symbolComponents.count > 1 {
//                let trimmedSymbol = symbolComponents[1].trimmingCharacters(in: .whitespacesAndNewlines)
//                if let image = UIImage(named: trimmedSymbol) {
//                    Image(uiImage: image)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 20, height: 20)
//                }
//                Text(symbolComponents[0])
//            } else {
//                Text(component)
//            }
//        }
//    }
//}

struct LegalitiesTuple: Hashable {
    let title: String
    let status: String
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(5) // Increase padding
                .padding(.horizontal, 30) // Increase horizontal padding
                .background(Color(.systemGray6))
                .cornerRadius(15) // Increase corner radius
                .shadow(color: .gray, radius: 2, x: 0, y: 0) // Add shadow
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 15) // Increase leading padding
                        
                        if !text.isEmpty {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 15) // Increase trailing padding
                            }
                        }
                    }
                )
                .padding(.horizontal, 5) // Increase horizontal padding
                .autocapitalization(.none)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
