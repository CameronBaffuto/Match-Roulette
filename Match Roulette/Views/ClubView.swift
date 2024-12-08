//
//  ClubView.swift
//  Match Mixer
//
//  Created by Cameron Baffuto on 4/7/23.
//

import SwiftUI
import Combine

struct Team: Codable {
    let logo: String
    let name: String
    let league: String
    let rating: Double
}

struct ClubView: View {
    @State private var isOn = false
    @State private var symbols: [(logo: String, name: String, league: String, rating: Double)] = []
    @State private var pOneNumbers: [Int] = []
    @State private var pTwoNumbers: [Int] = []
    @State private var showingFilters = false
    
    func fetchTeams() -> AnyPublisher<[Team], Error> {
        let url = URL(string: "https://us-central1-soccerapi-4e947.cloudfunctions.net/expressApi/teams")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Team].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    func generatePOneNumbers() {
        guard !symbols.isEmpty else { return }

        var numbers = Set<Int>()
        while numbers.count < 3 {
            numbers.insert(Int.random(in: 0..<symbols.count))
        }
        pOneNumbers = Array(numbers)
    }

    func generatePTwoNumbers() {
        guard !symbols.isEmpty else { return }

        var numbers = Set<Int>()
        while numbers.count < 3 {
            numbers.insert(Int.random(in: 0..<symbols.count))
        }
        pTwoNumbers = Array(numbers)
    }
    
    func filteredLeaguesQueryString() -> String {
            if let savedData = UserDefaults.standard.data(forKey: "filterLists") {
                let decoder = JSONDecoder()
                if let loadedLists = try? decoder.decode([FilterList].self, from: savedData) {
                    let selectedLeagues = loadedLists.filter { $0.isSelected }.map { $0.id }
                    let leagueString = selectedLeagues.joined(separator: ",")
                    return leagueString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                }
            }
            return ""
        }

        func loadSymbols() {
            let queryString = filteredLeaguesQueryString()
            let urlString = "https://us-central1-soccerapi-4e947.cloudfunctions.net/expressApi/teams"

            if let url = URL(string: urlString + "?leagues=\(queryString)") {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data {
                        if let decodedResponse = try? JSONDecoder().decode([Team].self, from: data) {
                            self.symbols = decodedResponse.map { ($0.logo, $0.name, $0.league, $0.rating) }
                            return
                        }
                    }
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                }.resume()
            }
        }
    
    var body: some View {
            ZStack {
                CustomColor.darkGreenColor.ignoresSafeArea()
                VStack {
                    Text("Club Teams")
                        .font(.largeTitle)
                    //toggle
                    HStack {
                        VStack {
                            Button(action: {
                                self.pOneNumbers = []
                                self.pTwoNumbers = []
                            }, label: {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 24))
                                
                                Text("Reset")
                                    .font(.headline)
                                    .foregroundColor(Color.white)
                            })
                            .frame(width: 100)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 2))
                            
                            //Filter
                            Button(action: {
                                self.pOneNumbers = []
                                self.pTwoNumbers = []
                                showingFilters.toggle()
                            }, label: {
                                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                    .font(.system(size: 24))
                                
                                Text("Filter")
                                    .font(.headline)
                                    .foregroundColor(Color.white)
                            })
                            .frame(width: 100)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 2))
                        }
                        .sheet(isPresented: $showingFilters) {
                            FilterView()
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Multiplayer").font(.system(size: 22, weight: .semibold)).lineLimit(2)
                                HStack {
                                    if self.isOn { 
                                        Text("On")
                                    } else {
                                        Text("Off")
                                    }
                                    Spacer()
                                    Toggle("", isOn: $isOn)
                                }
                        }
                        .frame(width: 115)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(self.isOn ? Color.green: Color.gray, lineWidth: 2)
                            )
                    }
                    .padding()
                    
                    
                    //player 1
                    Section(header: Text("Player One")) {
                        HStack {
                            ForEach(0..<3, id: \.self) { index in
                                    if index < pOneNumbers.count && index < symbols.count {
                                        let number = pOneNumbers[index]
                                        VStack {
                                            ZStack {
                                                AsyncImage(url: URL(string: symbols[number].logo)) { phase in
                                                    switch phase {
                                                    case .success(let image):
                                                        image
                                                            .resizable()
                                                            .aspectRatio(1, contentMode: .fit)
                                                    case .failure:
                                                        Image(systemName: "circle")
                                                            .resizable()
                                                            .aspectRatio(1, contentMode: .fit)
                                                    case .empty:
                                                        Image(systemName: "circle")
                                                            .resizable()
                                                            .aspectRatio(1, contentMode: .fit)
                                                    @unknown default:
                                                        Image(systemName: "circle")
                                                            .resizable()
                                                            .aspectRatio(1, contentMode: .fit)
                                                    }
                                                }
                                            }
                                            .padding()
                                            .background(Color.white.opacity(0.7))
                                            .cornerRadius(20)
                                            
                                            Text(symbols[number].name)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .multilineTextAlignment(.center)
                                                .lineLimit(2)
                                                .padding(.top, 5)
                                        }
                                    } else {
                                    VStack {
                                        ZStack {
                                            Image(systemName: "circle")
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fit)
                                        }
                                        .padding()
                                        .background(Color.white.opacity(0.7))
                                        .cornerRadius(20)
                                        
                                        Text("Empty")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                            .padding(.top, 5)
                                    }
                                }
                            }
                        }
                        .padding()
                        
                        Button(action: {
                            generatePOneNumbers()
                        }) {
                            Text("Spin")
                                .bold()
                                .foregroundColor(.white)
                                .padding()
                                .background(.pink)
                                .cornerRadius(10)
                                .frame(minWidth: 0, maxWidth: .infinity)
                        }
                    }
                    .onAppear {
                        loadSymbols()
                    }
                    .onChange(of: showingFilters) { newValue in
                        if !newValue {
                            loadSymbols()
                        }
                    }
                    Spacer()
                    
                    if isOn {
                    Divider()
                    Spacer()
                    
                    //player 2
                        Section(header: Text("Player Two")) {
                            HStack {
                                ForEach(0..<3, id: \.self) { index in
                                        if index < pTwoNumbers.count && index < symbols.count {
                                            let number = pTwoNumbers[index]
                                            VStack {
                                                ZStack {
                                                    AsyncImage(url: URL(string: symbols[number].logo)) { phase in
                                                        switch phase {
                                                        case .success(let image):
                                                            image
                                                                .resizable()
                                                                .aspectRatio(1, contentMode: .fit)
                                                        case .failure:
                                                            Image(systemName: "circle")
                                                                .resizable()
                                                                .aspectRatio(1, contentMode: .fit)
                                                        case .empty:
                                                            Image(systemName: "circle")
                                                                .resizable()
                                                                .aspectRatio(1, contentMode: .fit)
                                                        @unknown default:
                                                            Image(systemName: "circle")
                                                                .resizable()
                                                                .aspectRatio(1, contentMode: .fit)
                                                        }
                                                    }
                                                }
                                                .padding(15)
                                                .background(Color.white.opacity(0.7))
                                                .cornerRadius(20)
                                                
                                                Text(symbols[number].name)
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .multilineTextAlignment(.center)
                                                    .lineLimit(2)
                                                    .padding(.top, 5)
                                            }
                                    } else {
                                        VStack {
                                            ZStack {
                                                Image(systemName: "circle")
                                                    .resizable()
                                                    .aspectRatio(1, contentMode: .fit)
                                            }
                                            .padding(15)
                                            .background(Color.white.opacity(0.7))
                                            .cornerRadius(20)
                                            
                                            Text("Empty")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .multilineTextAlignment(.center)
                                                .lineLimit(2)
                                                .padding(.top, 5)
                                        }
                                    }
                                }
                            }
                            .padding()
                            
                            Button(action: {
                                generatePTwoNumbers()
                            }) {
                                Text("Spin")
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(.pink)
                                    .cornerRadius(10)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                            }
                        }
                        .transition(.opacity)
                    }
                    Spacer()
                }

                }
            }
        }


struct ClubView_Previews: PreviewProvider {
    static var previews: some View {
        ClubView()
    }
}
    
