//
//  FilterView.swift
//  Match Roulette
//
//  Created by Cameron Baffuto on 4/13/23.
//

import SwiftUI

struct FilterList: Identifiable, Codable {
    var id: String
    var isSelected = false
}

struct FilterView: View {
    @Environment(\.dismiss) var dismiss
    @State var isInternationalFilterSelected = false
    @State var lists = [
        FilterList(id: "German", isSelected: true),
        FilterList(id: "Spanish", isSelected: true),
        FilterList(id: "French", isSelected: true),
        FilterList(id: "English", isSelected: true),
        FilterList(id: "Italian", isSelected: true),
    ]
    
    private var allLeaguesSelected: Binding<Bool> {
        Binding(
            get: { lists.allSatisfy { $0.isSelected } },
            set: { newValue in
                if newValue {
                    lists = lists.map { FilterList(id: $0.id, isSelected: true) }
                }
            }
        )
    }
    
    private var isSaveButtonDisabled: Bool {
        !lists.contains { $0.isSelected }
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {

                    Section(header: Text("Leagues")) {
                        ForEach($lists) { $list in
                            Toggle(list.id, isOn: $list.isSelected)
                        }
                    }
                    
                    Section {
                        Toggle("All Leagues", isOn: allLeaguesSelected)
                    }
                }
            }
            .onAppear(perform: loadChoicesFromUserDefaults)
            .navigationBarTitle("Filter Settings", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: saveButtonTapped) {
                            Text("Save")
                                
            }
                .buttonStyle(.bordered)
                .tint(.pink)
                .disabled(isSaveButtonDisabled))
        }
    }
    
    func saveButtonTapped() {
        // Save the league selections to UserDefaults
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(lists) {
            UserDefaults.standard.set(encodedData, forKey: "filterLists")
            print("Choices saved to UserDefaults")
        } else {
            print("Failed to save choices to UserDefaults")
        }
        
        dismiss()
    }
    
    func loadChoicesFromUserDefaults() {
        if let savedData = UserDefaults.standard.data(forKey: "filterLists") {
            let decoder = JSONDecoder()
            if let loadedLists = try? decoder.decode([FilterList].self, from: savedData) {
                lists = loadedLists
                print("Loaded choices from UserDefaults")
            } else {
                print("Failed to load choices from UserDefaults")
            }
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
    }
}
