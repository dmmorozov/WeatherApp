//
//  WeatherListController.swift
//  WeatherApp
//
//  Created by Dmitrii Morozov on 28/01/2018.
//  Copyright © 2018 Dmitrii Morozov. All rights reserved.
//

class WeatherListController
{
    func getCurrentWeatherItemsOnline(completionCallback: @escaping ([CityCurrentWeather]) -> Void)
    {
        if let cities = LocalStorage.sharedInstance.getCities()
        {
            WeatherService.sharedInstance.getCurrentWeathers(cityIds: cities.map{ $0.id! })
            {
                cityCurrentWeatherItems in
                
                LocalStorage.sharedInstance.createOrUpdateCityCurrentWeatherItems(items: cityCurrentWeatherItems)
                
                completionCallback(cityCurrentWeatherItems)
            }
        }
        else
        {
            completionCallback([])
        }
    }
    
    func getCurrentWeathersFromDatabase() -> [CityCurrentWeather]
    {
        var resultArray: [CityCurrentWeather] = []

        if let cities = LocalStorage.sharedInstance.getCities()
        {
            
            for city in cities
            {
                if let currentWeather = LocalStorage.sharedInstance.getCityCurrentWeather(cityId: city.id!)
                {
                    let cityCurrentWeather = CityCurrentWeather(title: city.title!,
                                                                cityId: city.id!,
                                                                wind: Int(currentWeather.wind),
                                                                humidity: Int(currentWeather.humidity),
                                                                pressure: Int(currentWeather.pressure),
                                                                temperature: Int(currentWeather.temperature),
                                                                weatherDescription: currentWeather.weatherDescription!)
                    
                    resultArray.append(cityCurrentWeather)
                }
            }
        }
        
        return resultArray
    }
    
    func addNewCity(city: String, completionCallback: @escaping (CityCurrentWeather?, AddCityResult) -> Void)
    {
        WeatherService.sharedInstance.getCurrentWeather(city: city)
        {
            cityCurrentWeather in
            
            if let cityCurrentWeather = cityCurrentWeather
            {
                if let _ = LocalStorage.sharedInstance.getCity(id: cityCurrentWeather.cityId)
                {
                    completionCallback(nil, .exist)
                }
                else
                {
                    LocalStorage.sharedInstance.createCity(title: cityCurrentWeather.title, cityId: cityCurrentWeather.cityId)
                    LocalStorage.sharedInstance.createOrUpdateCityCurrentWeather(cityCurrentWeather)
                    completionCallback(cityCurrentWeather, .success)
                }
            }
            else
            {
                completionCallback(nil, .error)
            }
        }
    }
    
    func deleteCity(cityId: String)
    {
        LocalStorage.sharedInstance.deleteCity(id: cityId)
    }
}

enum AddCityResult
{
    case success
    case exist
    case error
}
