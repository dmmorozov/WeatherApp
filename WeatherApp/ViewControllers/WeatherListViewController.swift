//
//  ViewController.swift
//  WeatherApp
//
//  Created by Dmitrii Morozov on 25/01/2018.
//  Copyright © 2018 Dmitrii Morozov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WeatherListViewController: UIViewController
{
    /// Outlets
    @IBOutlet weak var tableView: UITableView!
    var editBarButtonItem: UIBarButtonItem!
    
    /// Controller
    let weatherListController = WeatherListController()
    
    /// State
    var cities: [CityCurrentWeather] = []
}

extension WeatherListViewController
{
    func loadDataFromDatabase()
    {
        cities = weatherListController.getCurrentWeathersFromDatabase()
    }
}

// MARK: - Constants
extension WeatherListViewController
{
    fileprivate struct Constants
    {
        static let numberOfSections = 1
    }
}

// MARK: - Lifecycle
extension WeatherListViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        loadDataFromDatabase()
        
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        weatherListController.getCurrentWeathersOnline(completionCallback: updateCityCurrentWeathers)
    }
    
    private func updateCityCurrentWeathers(_ newCityCurrentWeathers: [CityCurrentWeather])
    {
        if newCityCurrentWeathers.count > 0
        {
            self.cities = newCityCurrentWeathers
            
            self.tableView.reloadData()
        }
        else
        {
            alert(title: "Error", message: "Could not load actual data. Check you internet connection. Only saved data will be available")
        }
    }
}

// MARK: - Setup
extension WeatherListViewController
{
    fileprivate func setupNavigationBar()
    {
        editBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(changeTableEditingStyle))
        navigationItem.leftBarButtonItem = editBarButtonItem
    }
}

// MARK: - UI Handlers
extension WeatherListViewController
{
    @IBAction func onAddBarButtonItem(_ sender: Any)
    {
        alertWithTextInput(title: "New city", message: "Enter the name") { self.weatherListController.addNewCity(city: $0, completionCallback: self.addNewCityCurrentWeather) }
    }
    
    private func addNewCityCurrentWeather(_ newCityCurrentWeather: CityCurrentWeather?, addCityResult: AddCityResult)
    {
        switch addCityResult
        {
        case .error:
            alert(title: "Error", message: "Could not add city. Check the name and try again")
            
        case .exist:
            alert(title: "Error", message: "The city is already on the list")
            
        case .success:
            cities.append(newCityCurrentWeather!)
            self.tableView.insertRows(at: [IndexPath(row: cities.count - 1, section: 0)], with: .top)
        }
    }
}

// MARK: - Navigation
extension WeatherListViewController
{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let detailViewController = segue.destination as? WeatherDetailViewController
        {
            detailViewController.setup(cities[(tableView.indexPathForSelectedRow?.row)!])
            tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
        }
    }
}

// MARK: - Table
extension WeatherListViewController: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return Constants.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: CityWeatherCell.identifier, for: indexPath) as! CityWeatherCell
        
        cell.setup(currentWeather: cities[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if cities[indexPath.row].cityId != "524901" && cities[indexPath.row].cityId != "498817"
        {
            weatherListController.deleteCity(cityId: cities[indexPath.row].cityId)
            
            cities.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        else
        {
            alert(title: "Error", message: "You can't delete embedded cities")
        }
    }
    
    @objc func changeTableEditingStyle()
    {
        tableView.setEditing(!tableView.isEditing, animated: true)
        editBarButtonItem.title = tableView.isEditing ? "Done" : "Edit"
    }
}

// MARK: - Cell
class CityWeatherCell: UITableViewCell
{
    /// Outlets
    @IBOutlet weak var cityTitleLabel:   UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    /// Identifier
    static let identifier = "CityWeatherCell"
    
    // MARK: - Setup
    func setup(currentWeather: CityCurrentWeather)
    {
        cityTitleLabel.text   = currentWeather.title.capitalized
        temperatureLabel.text = currentWeather.temperature.description + "°"
    }
}