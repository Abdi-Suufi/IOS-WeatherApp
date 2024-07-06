//
//  ContentView.swift
//  WeatherApp
//
//  Created by Abdi Suufi on 06/07/2024.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var cityName: String = ""
    @State private var temperature: String = "--"
    @State private var description: String = "--"

    var body: some View {
        VStack {
            TextField("Enter city name", text: $cityName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                fetchWeather()
            }) {
                Text("Get Weather")
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
            Text("Temperature: \(temperature)°C")
                .font(.largeTitle)
                .padding()
            
            Text(description)
                .font(.title)
                .padding()
        }
        .padding()
    }

    func fetchWeather() {
        guard !cityName.isEmpty else { return }
                
                let apiKey = "7498cb58a91c5ae6a5886a8a34ff290b"
                let city = cityName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
                let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"
                
                guard let url = URL(string: urlString) else { return }
                
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data {
                        if let weatherResponse = try? JSONDecoder().decode(WeatherResponse.self, from: data) {
                            DispatchQueue.main.async {
                                self.temperature = String(format: "%.1f", weatherResponse.main.temp)
                                self.description = weatherResponse.weather.first?.description ?? ""
                            }
                        }
                    }
                }.resume()
            }
        }

struct WeatherResponse: Codable {
    let weather: [Weather]
    let main: Main
}

struct Weather: Codable {
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Double
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            
            
            
            
    }
}
