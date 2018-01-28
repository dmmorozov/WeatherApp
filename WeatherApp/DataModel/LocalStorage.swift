//
//  LocalStorage.swift
//  WeatherApp
//
//  Created by Dmitrii Morozov on 25/01/2018.
//  Copyright © 2018 Dmitrii Morozov. All rights reserved.
//

import CoreData

class LocalStorage
{
    /// Init
    init()
    {
        createCity(title: "Moscow", cityId: "524901")
        createCity(title: "Saint Petersburg", cityId: "498817")
    }
    
    /// Singleton
    static let sharedInstance = LocalStorage()
    
    lazy var persistentContainer: NSPersistentContainer =
    {
        let container = NSPersistentContainer(name: "WeatherApp")
        
        container.loadPersistentStores(completionHandler:
        {
            (storeDescription, error) in
            
            if let error = error as NSError?
            {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private func saveContext(context: NSManagedObjectContext? = nil)
    {
        let context = context ?? persistentContainer.viewContext
        
        do
        {
            try context.save()
        }
        catch
        {
            print(error)
        }
    }
}

// MARK: - CurrentWeather
extension LocalStorage
{
    func createOrUpdateCityCurrentWeatherItems(items: [CityCurrentWeather])
    {
        let context = persistentContainer.newBackgroundContext()
        
        for cityCurrentWeatherItem in items
        {
            createOrUpdateCityCurrentWeather(cityCurrentWeatherItem, context: context)
        }
    }
    
    func createOrUpdateCityCurrentWeather(_ cityCurrentWeather: CityCurrentWeather, context: NSManagedObjectContext? = nil)
    {
        let context = context ?? persistentContainer.newBackgroundContext()
        
        let currentWeatherRecord = getCityCurrentWeather(cityId: cityCurrentWeather.cityId, context: context) ?? NSEntityDescription.insertNewObject(forEntityName: "CurrentWeather", into: context) as! CurrentWeather
        
        currentWeatherRecord.city               = getCity(id: cityCurrentWeather.cityId, context: context)
        currentWeatherRecord.wind               = Int32(cityCurrentWeather.wind)
        currentWeatherRecord.humidity           = Int32(cityCurrentWeather.humidity)
        currentWeatherRecord.pressure           = Int32(cityCurrentWeather.pressure)
        currentWeatherRecord.temperature        = Int32(cityCurrentWeather.temperature)
        currentWeatherRecord.weatherDescription = cityCurrentWeather.weatherDescription
        
        saveContext(context: context)
    }
    
    func getCityCurrentWeather(cityId: String, context: NSManagedObjectContext? = nil) -> CurrentWeather?
    {
        let context = context ?? persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CurrentWeather")
        
        fetchRequest.predicate = NSPredicate(format: "city.id == %@", cityId)
        
        do
        {
            let currentWeatherRecords = try context.fetch(fetchRequest) as? [CurrentWeather]
            
            return currentWeatherRecords?.first
        }
        catch let error as NSError
        {
            print("Could not fetch. \(error), \(error.userInfo)")
            
            return nil
        }
    }
}

// MARK: - City
extension LocalStorage
{
    func deleteCity(id: String)
    {
        if let city = getCity(id: id)
        {
            city.managedObjectContext!.delete(city)
            
            saveContext()
        }
    }
    
    func createCity(title: String, cityId: String)
    {
        if getCity(id: cityId) == nil
        {
            let context = persistentContainer.newBackgroundContext()
            
            let city = NSEntityDescription.insertNewObject(forEntityName: "City", into: context) as! City
            
            city.title = title
            city.id    = cityId
            
            saveContext(context: context)
        }
    }
    
    func getCity(id: String, context: NSManagedObjectContext? = nil) -> City?
    {
        let context = context ?? persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "City")
        
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do
        {
            let cities = try context.fetch(fetchRequest) as? [City]
            
            return cities?.first
        }
        catch let error as NSError
        {
            print("Could not fetch. \(error), \(error.userInfo)")
            
            return nil
        }
    }
    
    func getCities() -> [City]?
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "City")
        
        let managedContext = persistentContainer.viewContext
        
        do
        {
            return try managedContext.fetch(fetchRequest) as? [City]
        }
        catch let error as NSError
        {
            print("Could not fetch. \(error), \(error.userInfo)")
            
            return nil
        }
    }
}

// MARK: - ForecastRecord
extension LocalStorage
{
    func createOrUpdateForecastRecord(forecastItems: [Forecast], cityId: String)
    {
        if forecastItems.count > 0
        {
            let context = persistentContainer.newBackgroundContext()
            
            let forecastRecord = getCityForecast(cityId: cityId, context: context) ??  NSEntityDescription.insertNewObject(forEntityName: "ForecastRecord", into: context) as! ForecastRecord
            
            forecastRecord.city        = getCity(id: cityId, context: context)
            forecastRecord.count       = Int16(forecastItems.count)
            forecastRecord.startDate   = forecastItems.first!.date
            forecastRecord.temperature = forecastItems.map{ $0.temperature }
            
            saveContext(context: context)
        }
    }
    
    func getCityForecast(cityId: String, context: NSManagedObjectContext? = nil) -> ForecastRecord?
    {
        let context = context ?? persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ForecastRecord")
        
        fetchRequest.predicate = NSPredicate(format: "city.id == %@", cityId)
        
        do
        {
            let cityForecasts = try context.fetch(fetchRequest) as? [ForecastRecord]
            
            return cityForecasts?.first
        }
        catch let error as NSError
        {
            print("Could not fetch. \(error), \(error.userInfo)")
            
            return nil
        }
    }
}
