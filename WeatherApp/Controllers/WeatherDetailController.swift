//
//  WeatherDetailController.swift
//  WeatherApp
//
//  Created by Dmitrii Morozov on 28/01/2018.
//  Copyright © 2018 Dmitrii Morozov. All rights reserved.
//

import Foundation

class WeatherDetailController
{
    func getForecast(cityId: String, completionCallback: @escaping ([Forecast]) -> Void)
    {
        WeatherService.sharedInstance.getForecast(cityId: cityId)
        {
            forecast in
            
            LocalStorage.sharedInstance.createOrUpdateForecastRecord(forecastItems: forecast, cityId: cityId)
            completionCallback(forecast)
        }
    }
    
    func getForecastFromDatabase(cityId: String) -> [Forecast]
    {
        var resultArray = [Forecast]()
        
        if let forecastRecord = LocalStorage.sharedInstance.getCityForecast(cityId: cityId)
        {
            for i in 0..<forecastRecord.count
            {
                let temperature = forecastRecord.temperature![Int(i)]
                let date = Calendar.current.date(byAdding: .day, value: Int(i), to: forecastRecord.startDate!)!
                
                resultArray.append(Forecast(date: date, temperature: temperature))
            }
        }
        
        return resultArray
    }
}
