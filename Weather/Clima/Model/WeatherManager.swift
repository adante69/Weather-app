import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    
    func didUpdateWeather(_ WeatherManager: WeatherManager, weather: WeatherModel)
    func didEndWithError(_ error: Error)
}


struct WeatherManager {
    
    var delegate:WeatherManagerDelegate?
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=5c7738452c25d90580244c06c9170d49&units=metric"
    
    func fetchWeather(_ cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        PerformRequest(with: urlString)

    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
            let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
            PerformRequest(with: urlString)
        }
        
    func PerformRequest(with urlString: String){
        
        if let url = URL(string: urlString){
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) {(data, response, error) in
                
                if error != nil{
                    self.delegate?.didEndWithError(error!)
                }
                if let safeData = data{
                    if let weather =  self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                   
                }
            }
            
            task.resume()
            
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
            let decodeData = try decoder.decode(WeatherData.self, from: weatherData)
            
            let temp = decodeData.main.temp
            let id = decodeData.weather[0].id
            let name = decodeData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            _ = weather.conditionName
            
            return weather
            
        } catch{
            self.delegate?.didEndWithError(error)
            return nil
        }
    }
    
    
}



