//
//  ViewController.swift
//  TipCalculatorPlus
//
//  Created by Akifumi Shinagawa on 6/12/16.
//  Copyright © 2016 BlurryBlue. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum ThemeMode:Int {
        case Light
        case Dark
    }
    
    @IBOutlet weak var billAmountView: UIView!
    @IBOutlet weak var splitBillView: UIView!
    @IBOutlet weak var originalPriceText: UITextField!
    @IBOutlet weak var tipPercentageLabel: UILabel!
    @IBOutlet weak var tipPriceLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    @IBOutlet weak var percentageSlider: UISlider!
    @IBOutlet weak var splitNumberText: UITextField!
    @IBOutlet weak var priceSplitByPeopleLabel: UILabel!
    
    let defaultTipPercentage = 15.0
    let defaultMaxTipPercentage = 20.0
    let defaultminTipPercentage = 5.0
    let previousBillAmountKeepDuration = 600.0
    
    var currentBillAmount = 0.0
    var tipPercentage = 0.0
    var maxTipPercentage = 0.0
    var minTipPercentage = 0.0
    var splitNumber = 1
    
    var themeMode:ThemeMode = .Light
    
    @IBAction func onTipPercentageChanged(sender: AnyObject) {
        tipPercentage = Double(minTipPercentage) + (Double(maxTipPercentage - minTipPercentage) * Double(percentageSlider.value))
        self.updateValues()
    }
    
    @IBAction func returnToMainView(segue: UIStoryboardSegue) {
        self.checkPreviousData()
        self.updateThemeMode()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // pass default value to SettingViewController
        if segue.identifier == "goSetting" {
            let settingViewController = segue.destinationViewController as! SettingViewController
            settingViewController.maxTipPercentage = self.maxTipPercentage
            settingViewController.minTipPercentage = self.minTipPercentage
            settingViewController.currentThemeMode = self.themeMode.rawValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplicationDidBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplicationWillResignActiveNotification, object: nil)
         
        self.checkPreviousData()
        self.updateThemeMode()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    deinit {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        // Set originalPriceText as FirstResponder for better UX
        self.originalPriceText.becomeFirstResponder()
        
        super.viewWillAppear(animated)
        
        self.checkPreviousData()
        self.updateThemeMode()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        self.updateValues()
    }
    
    func checkPreviousData() {
        if (NSUserDefaults.standardUserDefaults().objectForKey("savedBefore") != nil) {
            tipPercentage = NSUserDefaults.standardUserDefaults().doubleForKey("defaultPercentage")
            maxTipPercentage = NSUserDefaults.standardUserDefaults().doubleForKey("maxPercentage")
            minTipPercentage = NSUserDefaults.standardUserDefaults().doubleForKey("minPercentage")
            let tempThemeMode = NSUserDefaults.standardUserDefaults().integerForKey("themeMode")
            if tempThemeMode == ThemeMode.Dark.rawValue {
                themeMode = .Dark
            }
            else {
                themeMode = .Light
            }
        }
        else {
            tipPercentage = defaultTipPercentage
            maxTipPercentage = defaultMaxTipPercentage
            minTipPercentage = defaultminTipPercentage
            themeMode = .Light
            
            NSUserDefaults.standardUserDefaults().setObject("yes", forKey: "savedBefore")
            NSUserDefaults.standardUserDefaults().setDouble(tipPercentage, forKey: "defaultPercentage")
            NSUserDefaults.standardUserDefaults().setDouble(maxTipPercentage, forKey: "maxPercentage")
            NSUserDefaults.standardUserDefaults().setDouble(minTipPercentage, forKey: "minPercentage")
            NSUserDefaults.standardUserDefaults().setInteger(themeMode.rawValue, forKey: "themeMode")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        self.setPreviousTipPercentageToSlider()
        self.updateValues()
    }
    
    func updateThemeMode() {
        // Dark color
        let darkColorBG = UIColor(red: 0.0, green: 0.45, blue: 0.9, alpha: 255.0)
        let darkColorBillBG = UIColor(red: 0.0, green: 0.25, blue: 0.5, alpha: 255.0)
        let darkColorSplitBG = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 255.0)
        //Light COlor
        let lightColorBG = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let lightColorBillBG = UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0)
        let dlightColorSplitBG = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 255.0)
        
        switch themeMode {
        case .Dark:
            self.view.backgroundColor = darkColorBG
            billAmountView.backgroundColor = darkColorBillBG
            splitBillView.backgroundColor = darkColorSplitBG

        case .Light:
            self.view.backgroundColor = lightColorBG
            billAmountView.backgroundColor = lightColorBillBG
            splitBillView.backgroundColor = dlightColorSplitBG
        }
    }
    
    func setPreviousTipPercentageToSlider() {
        // Set slider value
        let sliderValue = (tipPercentage - Double(minTipPercentage)) / Double(maxTipPercentage - minTipPercentage)
        percentageSlider.setValue(Float(sliderValue), animated: false)
        
        // Set tip percent to textfield
        let percentFrmatter = NSNumberFormatter()
        percentFrmatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        percentFrmatter.maximumFractionDigits = 1
        percentFrmatter.positiveFormat = "0.0"
        percentFrmatter.roundingMode = NSNumberFormatterRoundingMode.RoundHalfUp
        tipPercentageLabel.text = percentFrmatter.stringFromNumber(tipPercentage)! + " %"
    }
    
    func saveCurrentData() {
        NSUserDefaults.standardUserDefaults().setDouble(tipPercentage, forKey: "defaultPercentage")
        NSUserDefaults.standardUserDefaults().setDouble(maxTipPercentage, forKey: "maxPercentage")
        NSUserDefaults.standardUserDefaults().setDouble(minTipPercentage, forKey: "minPercentage")
        NSUserDefaults.standardUserDefaults().setDouble(currentBillAmount, forKey: "previousBillAmount")
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "previousBillEnteredDate")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    func updateValues() {
        let billText = Double(originalPriceText.text!)
        if billText == nil {
            currentBillAmount = 0.0
        }
        else {
            currentBillAmount = Double(billText!)
        }

        let tipPrice = Double(currentBillAmount) * Double(tipPercentage) / 100
        let totalPrice = currentBillAmount + tipPrice
        
        let currencyFormatter = NSNumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        currencyFormatter.locale = NSLocale.currentLocale()
        
        tipPriceLabel.text = currencyFormatter.stringFromNumber(tipPrice)
        totalPriceLabel.text = currencyFormatter.stringFromNumber(totalPrice)
        
        let percentFrmatter = NSNumberFormatter()
        percentFrmatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        percentFrmatter.maximumFractionDigits = 1
        percentFrmatter.positiveFormat = "0.0"
        percentFrmatter.roundingMode = NSNumberFormatterRoundingMode.RoundHalfUp

        tipPercentageLabel.text = percentFrmatter.stringFromNumber(tipPercentage)! + " %"
        
        if splitNumberText.text != nil {
            splitNumber = Int(splitNumberText.text!)!
        }
        else {
            splitNumber = 1
        }
        
        let splittedPrice = Double(totalPrice) / Double(splitNumber)
        
        priceSplitByPeopleLabel.text = currencyFormatter.stringFromNumber(splittedPrice)
     
        self.saveCurrentData()
    }
    
    func appMovedToForeground() {
        let previousBillAmount = NSUserDefaults.standardUserDefaults().doubleForKey("previousBillAmount")
        let previousBillEnteredDate:NSDate = NSUserDefaults.standardUserDefaults().objectForKey("previousBillEnteredDate") as! NSDate
        let now = NSDate()
        let timeDiff = now.timeIntervalSinceDate(previousBillEnteredDate)
        
        if timeDiff <= previousBillAmountKeepDuration && previousBillAmount != 0 {
            originalPriceText.text = String(previousBillAmount)
            self.updateValues()
        }
        else{
            originalPriceText.text = ""
        }
    }
    
    func appMovedToBackground() {
        let billText = Double(originalPriceText.text!)
        if billText == nil {
            currentBillAmount = 0.0
        }
        else {
            currentBillAmount = Double(billText!)
        }
        
        self.saveCurrentData()
    }
}

