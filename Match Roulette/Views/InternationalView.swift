//
//  InternationalView.swift
//  Match Mixer
//
//  Created by Cameron Baffuto on 4/7/23.
//

import SwiftUI
import Combine

struct IntlTeam: Codable {
    let logo: String
    let name: String
    let rating: Double
}

struct InternationalView: View {
    @State private var isOn = false
    @State private var symbols: [(logo: String, name: String, rating: Double)] = []
    @State private var pOneNumbers: [Int] = []
    @State private var pTwoNumbers: [Int] = []
    @State private var showingSettings = false
    
    func fetchTeams() -> AnyPublisher<[IntlTeam], Error> {
        let url = URL(string: "https://us-central1-soccerapi-4e947.cloudfunctions.net/expressApi/intl")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [IntlTeam].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    func generatePOneNumbers() {
        var numbers = Set<Int>()
        while numbers.count < 3 {
            numbers.insert(Int.random(in: 0..<symbols.count))
        }
        pOneNumbers = Array(numbers)
    }

    func generatePTwoNumbers() {
        var numbers = Set<Int>()
        while numbers.count < 3 {
            numbers.insert(Int.random(in: 0..<symbols.count))
        }
        pTwoNumbers = Array(numbers)
    }
    
    func loadSymbols() {
            let url = URL(string: "https://us-central1-soccerapi-4e947.cloudfunctions.net/expressApi/intl")!
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    if let decodedResponse = try? JSONDecoder().decode([IntlTeam].self, from: data) {
                        self.symbols = decodedResponse.map { ($0.logo, $0.name, $0.rating) }
                        return
                    }
                }
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
            }.resume()
    }

    
    var body: some View {
            ZStack {
                CustomColor.darkGreenColor.ignoresSafeArea()
                VStack {
                    Text("International Teams")
                        .font(.largeTitle)
                    
                    //toggle
                    HStack {
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
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(self.isOn ? Color.green: Color.gray, lineWidth: 2)
                            )
                    }
                    .padding()
                    
                    //player 1
                    Section(header: Text("Player One")) {
                        HStack {
                            if pOneNumbers.isEmpty {
                                ForEach(0..<3) { _ in
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
                                
                            } else {
                                ForEach(pOneNumbers, id: \.self) { number in
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
                    Spacer()
                    
                    if isOn {
                    Divider()
                    Spacer()
                    
                    //player 2
                    
                        Section(header: Text("Player Two")) {
                            HStack {
                                if pTwoNumbers.isEmpty {
                                    ForEach(0..<3) { _ in
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
                                    
                                } else {
                                    ForEach(pTwoNumbers, id: \.self) { number in
                                        VStack {
                                            ZStack {
                                                AsyncImage(url: URL(string: symbols[number].logo)) { phase in
                                                    switch phase {
                                                    case .success(let image):
                                                        image
                                                            .resizable()
                                                            .aspectRatio(1.3, contentMode: .fit)
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

struct InternationalView_Previews: PreviewProvider {
    static var previews: some View {
        InternationalView()
    }
}
