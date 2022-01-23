//
//  WeatherManager.swift
//  Power Weather
//
//  Created by Ishaan Sarna on 23/01/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(weather: WeatherModel)
    func didFailWithError(_ error: Error)
}

struct WeatherManager {
    var delegate: WeatherManagerDelegate?
    
    // apiKey defined in Secrets.swift and added to .gitignore for security reasons
    
    func fetchWeather(cityName: String) {
        let url = "https://api.openweathermap.org/data/2.5/weather?appid=\(apiKey)&units=metric&q=\(cityName)"
        makeRequest(with: url)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let url = "https://api.openweathermap.org/data/2.5/weather?appid=\(apiKey)&units=metric&lat=\(latitude)&lon=\(longitude)"
        makeRequest(with: url)
    }
    
    func makeRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForResource = 15
            
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: url) { data, reponse, error in
                if error != nil {
                    if error!.localizedDescription == "The request timed out." {
                        print("You ran out of time!")
                        return
                    }
                    delegate?.didFailWithError(error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = parseJSON(from: safeData) {
                        delegate?.didUpdateWeather(weather: weather)
                    } else {
                        print("ERROR: Weather is nil!")
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON(from data: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let weatherData = try decoder.decode(WeatherData.self, from: data)
            let weatherID = weatherData.weather[0].id
            let name = weatherData.name
            let temp = weatherData.main.temp
            
            let weather = WeatherModel(weatherID: weatherID, cityName: name, temperature: temp)
            
            return weather
        } catch {
            delegate?.didFailWithError(error)
        }
        return nil
    }
}
