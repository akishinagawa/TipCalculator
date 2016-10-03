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
    
    
    let defaulBillViewSize:CGRect = CGRect(x: 0, y: 64, width: 375, height: 108)
    let keypadFocusedBillViewSize:CGRect = CGRect(x: 0, y: 64, width: 375, height: 200)
    
    let defaultTipPercentage = 15.0
    let defaultMaxTipPercentage = 20
    let defaultminTipPercentage = 5
    let previousBillAmountKeepDuration = 600.0
    
    var currentBillAmount = 0.0
    var tipPercentage = 0.0
    var maxTipPercentage = 0
    var minTipPercentage = 0
    var splitNumber = 1
    var previousBillAmountString = ""
    
    var themeMode:ThemeMode = .Light
    var currentLocale:String = ""
    
    @IBAction func onTipPercentageChanged(sender: AnyObject) {
        tipPercentage = Double(minTipPercentage) + (Double(maxTipPercentage - minTipPercentage) * Double(percentageSlider.value))
        self.updateValues()
    }
    
    @IBAction func returnToMainView(segue: UIStoryboardSegue) {
        
        // !!This method is not called anymore - remove
        let previousBillAmount = NSUserDefaults.standardUserDefaults().doubleForKey("previousBillAmount")
        originalPriceText.text = String(previousBillAmount)
        
        if previousBillAmount != 0 {
            originalPriceText.text = String(previousBillAmount)
            self.updateValues()
        }
        else{
            originalPriceText.text = ""
        }

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
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    deinit {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        // Set originalPriceText as FirstResponder for better UX
        let previousBillAmount = NSUserDefaults.standardUserDefaults().doubleForKey("previousBillAmount")
        
        if(previousBillAmount == 0){
            self.originalPriceText.becomeFirstResponder()
        }
        
        super.viewWillAppear(animated)
        
        self.checkPreviousData()
        self.updateThemeMode()
        
//        self.enlargeBillTextField()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)

        let billText = String(originalPriceText.text!)
        if(previousBillAmountString != billText){
            if billText == "" {
                currentBillAmount = 0.0
            }
            else {
                currentBillAmount = Double(billText)!
            }
        }
        
        self.updateValues()
        
//        self.shrinkBillTextField()
    }
    
    func checkPreviousData() {
        if (NSUserDefaults.standardUserDefaults().objectForKey("savedBefore") != nil) {
            tipPercentage = NSUserDefaults.standardUserDefaults().doubleForKey("defaultPercentage")
            maxTipPercentage = NSUserDefaults.standardUserDefaults().integerForKey("maxPercentage")
            minTipPercentage = NSUserDefaults.standardUserDefaults().integerForKey("minPercentage")
            currentLocale = NSUserDefaults.standardUserDefaults().stringForKey("currentLocale")!
            let tempThemeMode = NSUserDefaults.standardUserDefaults().integerForKey("themeMode")
            if tempThemeMode == ThemeMode.Dark.rawValue {
                themeMode = .Dark
            }
            else {
                themeMode = .Light
            }
            
            self.setPreviousTipPercentageToSlider()
            self.updateValues()
        }
        else {
            tipPercentage = defaultTipPercentage
            maxTipPercentage = defaultMaxTipPercentage
            minTipPercentage = defaultminTipPercentage
            themeMode = .Light
            currentLocale = "U.S."
            
            NSUserDefaults.standardUserDefaults().setObject("yes", forKey: "savedBefore")
            NSUserDefaults.standardUserDefaults().setDouble(tipPercentage, forKey: "defaultPercentage")
            NSUserDefaults.standardUserDefaults().setInteger(maxTipPercentage, forKey: "maxPercentage")
            NSUserDefaults.standardUserDefaults().setInteger(minTipPercentage, forKey: "minPercentage")
            NSUserDefaults.standardUserDefaults().setInteger(themeMode.rawValue, forKey: "themeMode")
            NSUserDefaults.standardUserDefaults().setObject(currentLocale, forKey: "currentLocale")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func updateThemeMode() {
        // Dark color
        let darkColorBG = UIColor(red: 0.43, green: 0.76, blue: 0.57, alpha: 255.0)
        let darkColorBillBG = UIColor(red: 0.0, green: 0.5, blue: 0.25, alpha: 255.0)
        let darkColorSplitBG = UIColor(red: 0.05, green: 0.3, blue: 0.15, alpha: 255.0)
        //Light COlor
        let lightColorBG = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let lightColorBillBG = UIColor(red: 0.2, green: 0.84, blue: 0.35, alpha: 1.0)
        let lightColorSplitBG = UIColor(red: 0.43, green: 0.76, blue: 0.57, alpha: 255.0)
        
        switch themeMode {
        case .Dark:
            self.view.backgroundColor = darkColorBG
            billAmountView.backgroundColor = darkColorBillBG
            splitBillView.backgroundColor = darkColorSplitBG

        case .Light:
            self.view.backgroundColor = lightColorBG
            billAmountView.backgroundColor = lightColorBillBG
            splitBillView.backgroundColor = lightColorSplitBG
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
        NSUserDefaults.standardUserDefaults().setInteger(maxTipPercentage, forKey: "maxPercentage")
        NSUserDefaults.standardUserDefaults().setInteger(minTipPercentage, forKey: "minPercentage")
        NSUserDefaults.standardUserDefaults().setDouble(currentBillAmount, forKey: "previousBillAmount")
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "previousBillEnteredDate")
        NSUserDefaults.standardUserDefaults().setObject(currentLocale, forKey: "currentLocale")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool{
        textField.resignFirstResponder()

        return true
    }
    
    func updateValues() {
        let tipPrice = Double(currentBillAmount) * Double(tipPercentage) / 100
        let totalPrice = currentBillAmount + tipPrice
        
        let currencyFormatter = NSNumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        
        // Set current Locale
        let selectedLocal:NSLocale
        
        switch currentLocale {
        case "U.S":
            selectedLocal = NSLocale(localeIdentifier: "en_US")
        case "MEXICO":
            selectedLocal = NSLocale(localeIdentifier: "es_MX")
        case "FRANCE":
            selectedLocal = NSLocale(localeIdentifier: "fr_FR")
        case "United Kingdom":
            selectedLocal = NSLocale(localeIdentifier: "cy_GB")
        case "Japan":
            selectedLocal = NSLocale(localeIdentifier: "ja_JP")
            
        default:
            selectedLocal = NSLocale.currentLocale()
        }
        currencyFormatter.locale = selectedLocal
        
        tipPriceLabel.text = currencyFormatter.stringFromNumber(tipPrice)
        totalPriceLabel.text = currencyFormatter.stringFromNumber(totalPrice)
        
        previousBillAmountString = currencyFormatter.stringFromNumber(currentBillAmount)!
        originalPriceText.text =  previousBillAmountString
        
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

    
    func enlargeBillTextField() {
        // animation test
        
//        let moveToLargePos = CABasicAnimation(keyPath: "height")
//        moveToLargePos.fromValue = 0
//        moveToLargePos.toValue = 200
//        moveToLargePos.duration = 2
//        self.billAmountView.layer.addAnimation(moveToLargePos, forKey: nil)
        
        
//        self.billAmountView.frame = self.defaulBillViewSize
//        UIView.animateWithDuration(0.4, animations: {
//            self.billAmountView.frame = self.keypadFocusedBillViewSize
//        })
    }
    
    func shrinkBillTextField() {
        // animation test
//        UIView.animateWithDuration(0.4, animations: { () -> Void in
//            self.billAmountView.frame = self.defaulBillViewSize
//        })

    }
    
    func appMovedToForeground() {
        let previousBillAmount = NSUserDefaults.standardUserDefaults().doubleForKey("previousBillAmount")
        let previousBillEnteredDate:NSDate = NSUserDefaults.standardUserDefaults().objectForKey("previousBillEnteredDate") as! NSDate
        let now = NSDate()
        let timeDiff = now.timeIntervalSinceDate(previousBillEnteredDate)
        
        if timeDiff <= previousBillAmountKeepDuration && previousBillAmount != 0 {
            originalPriceText.text = String(previousBillAmount)
        }
        else{
            originalPriceText.text = ""
            currentBillAmount = 0.0
            self.originalPriceText.becomeFirstResponder()
        }
        self.updateValues()
    }
    
    func appMovedToBackground() {
//        let billText = Double(originalPriceText.text!)
//        if billText == nil {
//            currentBillAmount = 0.0
//        }
        
        self.saveCurrentData()
    }
}

