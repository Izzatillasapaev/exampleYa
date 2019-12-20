//
//  SearchViewController.swift
//  AKV
//
//  Created by Izzatilla on 29.11.2019.
//  Copyright © 2019 User. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class SearchViewController: UIViewController, UITextFieldDelegate, CalendarDateRangePickerViewControllerDelegate, SearchAppertmentGuestNumberVCDelegate {
    
    
    
    @IBOutlet weak var searchTextField: UITextField!
    
    //choose date
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateImageView: UIImageView!
    
    //choose guests
    @IBOutlet weak var guestView: UIView!
    @IBOutlet weak var guestImageView: UIImageView!
    @IBOutlet weak var guestLabel: UILabel!
    var picker = UIPickerView()
    var toolBar  = UIToolbar()
    let guestData = [1,2,3,4,5,6]
    //choose on map
    @IBOutlet weak var mapView: UIImageView!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var mapLabel: UILabel!
    
    @IBOutlet weak var mainView: UIView!
    //    @IBOutlet weak var mainViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var view1TopConstraint: NSLayoutConstraint!
    var adultsNumber: Int = 1 {
        didSet {
            
        }
    }
    var childrenNumber: Int = 0
    var searchTimer: Timer?
    var viewModel = SearchAppartmentViewModel()
    
    @IBOutlet weak var view1: UIView!
    var configureHouseTypes: (_ data: [HouseType]) -> () = {_ in}
    var configureSearchResults: (_ data: SearchResult) -> () = {_ in}
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        configureUI()
        
        //        loadHouseTypesView()
        viewModel.getHouseTypes()
        //        viewModel.getSearhResultsByHouseId(id: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        view1.addShadow(location: .bottom)
    }
    
    func configureUI() {
        
        
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(textFieldDidEditingChanged(_:)), for: .editingChanged)
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Пример: Mega Towers", attributes: [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont(name: "Montserrat-Light", size: 15) ?? UIFont.systemFont(ofSize: 15, weight: .light)
        ])
        
        
        
        picker.reloadAllComponents()
        let tapOnDate = UITapGestureRecognizer(target: self, action: #selector(self.dateTapped(_:)))
        dateView.addGestureRecognizer(tapOnDate)
        
        let tapOnGuest = UITapGestureRecognizer(target: self, action: #selector(self.guestTapped(_:)))
        guestView.addGestureRecognizer(tapOnGuest)
        
        
    }
    
    
    // MARK: Main view
    
    func loadHouseTypesView(data: [HouseType]) {
        guard let view = Bundle.main.loadNibNamed("HouseTypesView", owner: self, options: nil)?.first as? SearchAppartmentBottomViewProtocol else {
            print("ewq error")
            return
        }
        (view as! HouseTypesView).viewModel = self.viewModel
        view.initConfiguration()
        view.configure(data: data)
        mainView.addSubview(view as! UIView)
        
        NSLayoutConstraint.activate ((view as! UIView).constraintsForAnchoringTo(boundsOf: mainView) )
        (view as! HouseTypesView).translatesAutoresizingMaskIntoConstraints = false
        
        configureHouseTypes = {data in
            view.configure(data: data)}
        
        (view as! HouseTypesView).topConstraint = view1TopConstraint
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
        //            self.mainViewConstraint.constant = 10
        //        }
        
    }
    func clearMainView() {
        for v in mainView.subviews {
            v.removeFromSuperview()
        }
    }
    // MARK: Guests and Date
    @objc func guestTapped(_ sender: UITapGestureRecognizer? = nil) {
        
        let vc = SearchAppertmentGuestNumberVC().fromSB()
        vc.delegate = self
        vc.adultsNumber = adultsNumber
        vc.childrenNumber = childrenNumber
        self.presentModallyFullScreen(vc: vc)
        
    }
    @objc func dateTapped(_ sender: UITapGestureRecognizer? = nil) {
        
        let dateRangePickerViewController = CalendarDateRangePickerViewController(collectionViewLayout: UICollectionViewFlowLayout())
        dateRangePickerViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: dateRangePickerViewController)
        self.present(navigationController, animated: true, completion: nil)
        
    }
    func guestNumberChanged(number: Int) {
        
        guestView.backgroundColor = UIColor(named: "buttonRedColor")
        guestView.layer.borderWidth = 0
        guestImageView.image = UIImage(named: "users2")
        guestLabel.text = "\(number) \(number == 1 ? "гость" : "гости")"
        guestLabel.textColor = UIColor.white
        
    }
    
    func didPickDateRange(dates: [Date]) {
        
        dateView.backgroundColor = UIColor(named: "buttonRedColor")
        dateView.layer.borderWidth = 0
        dateImageView.image = UIImage(named: "calendar-white")
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "dd.MM"
        
        
        dateLabel.textColor = UIColor.white
        
        let date1 = formatter.string(from: dates.first!)
        dateLabel.text = date1
        if dates.count == 1 {
            return
        }
        let date2 = formatter.string(from: dates[1])
        dateLabel.text = dateLabel.text! + " - " + date2
        
        
    }
    
    func guestNumberChanged(adults: Int, children: Int) {
        guestNumberChanged(number: adults + children)
        adultsNumber = adults
        childrenNumber = children
    }
    
    func didCancelPickingDateRange() {
        
    }
    // MARK: Search
    
    @objc func textFieldDidEditingChanged(_ textField: UITextField) {
        
        // if a timer is already active, prevent it from firing
        if searchTimer != nil {
            searchTimer?.invalidate()
            searchTimer = nil
        }
        
        // reschedule the search: in 1.0 second, call the searchForKeyword method on the new textfield content
        searchTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(search(_:)), userInfo: textField.text!, repeats: false)
    }
    
    
    @objc func search(_ timer: Timer) {
        let keyword = timer.userInfo!
        
        print("Searching for keyword \(keyword)")
    }
    
    func houseTypePressed(id: Int, name: String){
        
    }
}
extension SearchViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.guestData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return "\(self.guestData[row])"
    }
    
    
}
extension SearchViewController: SearchAppartmentViewModelDelegate {
    func showSearchResults(result: SearchResult) {
        self.clearMainView()
        guard let view = Bundle.main.loadNibNamed("SearchResultsView", owner: self, options: nil)?.first as? SearchResultsView else {
            print("ewq error")
            return
        }
        view.viewModel = self.viewModel
        
        view.initConfiguration()
        let data = result.results
        
        mainView.addSubview(view)
        
        NSLayoutConstraint.activate (view.constraintsForAnchoringTo(boundsOf: mainView) )
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.configure(data: data)
        view.topConstraint = self.view1TopConstraint
        view.itemsCount = result.count
        configureSearchResults = { data in
            var allDatas = view.data
            allDatas += data.results
            view.configure(data: data.results)
        }
        
    }
    
    func updateHouseTypesData(data: [HouseType]) {
        clearMainView()
        self.loadHouseTypesView(data: data)
    }
    
    func isShouldStartLoading(_ isShould: Bool) {
        isShould ? self.showLoadingHUD() : self.dismissLoadingHUD()
    }
    
    func showError(error: String) {
        self.showError(message: error)
    }
    
    
}
