//
//  ViewController.swift
//  Power Weather
//
//  Created by Ishaan Sarna on 23/01/22.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        weatherManager.delegate = self
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
}

extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        searchTextField.endEditing(false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(false)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Enter a location"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let cityName = searchTextField.text?.lowercased() {
            weatherManager.fetchWeather(cityName: cityName)
        }
        searchTextField.text = ""
    }
}

extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateWeather(weather: WeatherModel) {
        DispatchQueue.main.async {
            self.cityLabel.text = weather.cityName
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.temperatureLabel.text = weather.temperatureString
        }
    }
    
    func didFailWithError(_ error: Error) {
        print(error)
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    
    @IBAction func locationButtonPressed(_ sender: Any) {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: latitude, longitude: longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

