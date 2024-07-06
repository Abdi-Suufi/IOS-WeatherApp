import SwiftUI
import Foundation

struct ContentView: View {
    @State private var cityName: String = ""
    @State private var temperature: String = "--"
    @State private var description: String = "--"
    @State private var isMorning: Bool = true // Assume it's morning by default

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
        .background(backgroundImage)
        .onAppear {
            updateBackgroundBasedOnTime()
        }
    }

    private var backgroundImage: Image {
        let imageUrlString = isMorning ? "https://i.pinimg.com/564x/76/10/68/76106886a3e76323d19c841fb065e59b.jpg" : "https://i.pinimg.com/564x/bb/df/94/bbdf9470b9979af881ee2d725532f968.jpg"
        return Image(uiImage: fetchImage(urlString: imageUrlString))
    }

    private func updateBackgroundBasedOnTime() {
        let hour = Calendar.current.component(.hour, from: Date())
        isMorning = (6..<18).contains(hour) // Set isMorning based on hour (assuming morning from 6 AM to 5:59 PM)
    }

    private func fetchImage(urlString: String) -> UIImage {
        guard let url = URL(string: urlString),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            return UIImage() // Return a default image or handle error
        }
        return image
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
