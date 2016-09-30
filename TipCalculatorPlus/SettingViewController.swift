//
//  SettingViewController.swift
//  TipCalculatorPlus
//
//  Created by Akifumi Shinagawa on 7/5/16.
//  Copyright © 2016 BlurryBlue. All rights reserved.
//


import UIKit

import Foundation

class SettingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {

    let defaultminTipPercentageMax = 10.0
    let defaultMaxTipPercentageMax = 20.0
    
    var minTipPercentage = 0.0
    var maxTipPercentage = 0.0
    var currentThemeMode = 0
    
    @IBOutlet weak var minPercentgeLabel: UILabel!
    @IBOutlet weak var maxPercentageLabel: UILabel!
    @IBOutlet weak var themeSegment: UISegmentedControl!
    
    @IBOutlet weak var minPercentageSlider: UISlider!
    @IBAction func minPercentageSliderChanged(sender: AnyObject) {
        
        minTipPercentage = Double(defaultminTipPercentageMax) * Double(minPercentageSlider.value)
        
        let percentFrmatter = NSNumberFormatter()
        percentFrmatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        percentFrmatter.maximumFractionDigits = 1
        percentFrmatter.positiveFormat = "0.0"
        percentFrmatter.roundingMode = NSNumberFormatterRoundingMode.RoundHalfUp
        
        minPercentgeLabel.text = percentFrmatter.stringFromNumber(minTipPercentage)! + " %"
        
        NSUserDefaults.standardUserDefaults().setDouble(minTipPercentage, forKey: "minPercentage")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    @IBOutlet weak var maxPercentageSlider: UISlider!
    @IBAction func maxPercentageSliderChanged(sender: AnyObject) {
       maxTipPercentage = Double(defaultMaxTipPercentageMax - defaultminTipPercentageMax) * Double(maxPercentageSlider.value)
        
        let percentFrmatter = NSNumberFormatter()
        percentFrmatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        percentFrmatter.maximumFractionDigits = 1
        percentFrmatter.positiveFormat = "0.0"
        percentFrmatter.roundingMode = NSNumberFormatterRoundingMode.RoundHalfUp
        
        maxPercentageLabel.text = percentFrmatter.stringFromNumber(maxTipPercentage)! + " %"
        
        NSUserDefaults.standardUserDefaults().setDouble(maxTipPercentage, forKey: "maxPercentage")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    @IBAction func themeSegementChanged(sender: AnyObject) {
        currentThemeMode = sender.selectedSegmentIndex
        
        NSUserDefaults.standardUserDefaults().setInteger(currentThemeMode, forKey: "themeMode")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    @IBOutlet weak var localePickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTipPercentageValues()
        self.setCurrentThemeMode()
        self.setPickerViewWithPreviousSetting()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setTipPercentageValues() {
        let percentFrmatter = NSNumberFormatter()
        percentFrmatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        percentFrmatter.maximumFractionDigits = 1
        percentFrmatter.positiveFormat = "0.0"
        percentFrmatter.roundingMode = NSNumberFormatterRoundingMode.RoundHalfUp
        
        minPercentgeLabel.text = percentFrmatter.stringFromNumber(minTipPercentage)! + " %"
        maxPercentageLabel.text = percentFrmatter.stringFromNumber(maxTipPercentage)! + " %"
    }
    
    func setCurrentThemeMode() {
        themeSegment.selectedSegmentIndex = currentThemeMode
    }
    
    // UIPickerViewDelegate, UIPickerViewDataSource related
    let localeDataList = [["U.S.","MEXICO","FRANCE","United Kingdom","Japan"]]

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return localeDataList.count
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return localeDataList[component].count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return localeDataList[component][row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let currentLocale = self.pickerView(pickerView, titleForRow: pickerView.selectedRowInComponent(0), forComponent: 0)
        NSUserDefaults.standardUserDefaults().setObject(currentLocale, forKey: "currentLocale")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func setPickerViewWithPreviousSetting() {
        let currentSelectedLocale = NSUserDefaults.standardUserDefaults().stringForKey("currentLocale")!
        
        var selectedRow = 0
        switch currentSelectedLocale {
        case "U.S":
            selectedRow = 0
        case "MEXICO":
            selectedRow = 1
        case "FRANCE":
            selectedRow = 2
        case "United Kingdom":
            selectedRow = 3
        case "Japan":
            selectedRow = 4
            
        default:
            selectedRow = 0
        }
        
        self.localePickerView.selectRow(selectedRow, inComponent: 0, animated: false)
    }
}

