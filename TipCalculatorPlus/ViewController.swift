//
//  ViewController.swift
//  TipCalculatorPlus
//
//  Created by Akifumi Shinagawa on 6/12/16.
//  Copyright © 2016 BlurryBlue. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
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
    
    var tipPercentage = 0.0
    var maxTipPercentage = 0.0
    var minTipPercentage = 0.0
    var splitNumber = 1
    
    @IBAction func onTipPercentageChanged(sender: AnyObject) {
        //NSLog("---->>onTipPercentageChanged")
        
        tipPercentage = Double(minTipPercentage) + (Double(maxTipPercentage - minTipPercentage) * Double(percentageSlider.value))
        self.updateValues()
    }
    
    @IBAction func returnToMainView(segue: UIStoryboardSegue) {
        NSLog("---->>　UIViewController: returnToMainView")
        self.checkPreviousData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // pass default value to SettingViewController
        if segue.identifier == "goSetting" {
            let settingViewController = segue.destinationViewController as! SettingViewController
            settingViewController.maxTipPercentage = self.maxTipPercentage
            settingViewController.minTipPercentage = self.minTipPercentage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.checkPreviousData()
        
        NSLog("---->>　UIViewController: viewDidLoad")
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        NSLog("---->>touchesBegan")
        
        self.view.endEditing(true)
        self.updateValues()
    }
    
    func checkPreviousData() {
        
        if (NSUserDefaults.standardUserDefaults().objectForKey("savedBefore") != nil) {
            NSLog("---->>checkPreviousData : Yes. There is data.")
            
            tipPercentage = NSUserDefaults.standardUserDefaults().doubleForKey("defaultPercentage")
            maxTipPercentage = NSUserDefaults.standardUserDefaults().doubleForKey("maxPercentage")
            minTipPercentage = NSUserDefaults.standardUserDefaults().doubleForKey("minPercentage")
        }
        else {
            NSLog("---->>checkPreviousData : No. There is no data.")
            
            tipPercentage = defaultTipPercentage
            maxTipPercentage = defaultMaxTipPercentage
            minTipPercentage = defaultminTipPercentage
            
            NSUserDefaults.standardUserDefaults().setObject("yes", forKey: "savedBefore")
            NSUserDefaults.standardUserDefaults().setDouble(tipPercentage, forKey: "defaultPercentage")
            NSUserDefaults.standardUserDefaults().setDouble(maxTipPercentage, forKey: "maxPercentage")
            NSUserDefaults.standardUserDefaults().setDouble(minTipPercentage, forKey: "minPercentage")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        self.setPreviousTipPercentageToSlider()
        self.updateValues()
    }
    
    func setPreviousTipPercentageToSlider() {
        
        let sliderValue = (tipPercentage - Double(minTipPercentage)) / Double(maxTipPercentage - minTipPercentage)
        NSLog("--->> sliderValue == " + String(sliderValue))
        
        percentageSlider.setValue(Float(0.5), animated: false)
        
        let percentFrmatter = NSNumberFormatter()
        percentFrmatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        percentFrmatter.maximumFractionDigits = 1
        percentFrmatter.positiveFormat = "0.0"
        percentFrmatter.roundingMode = NSNumberFormatterRoundingMode.RoundHalfUp
        tipPercentageLabel.text = percentFrmatter.stringFromNumber(tipPercentage)! + " %"
    }
    
    func saveCurrentPercentage() {
        NSUserDefaults.standardUserDefaults().setDouble(tipPercentage, forKey: "defaultPercentage")
        NSUserDefaults.standardUserDefaults().setDouble(maxTipPercentage, forKey: "maxPercentage")
        NSUserDefaults.standardUserDefaults().setDouble(minTipPercentage, forKey: "minPercentage")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    func updateValues() {
        //NSLog("---->>calculateTip"
        var originalPrice = Double(originalPriceText.text!)
        if originalPrice == nil {
            originalPrice = 0.0
        }

        let tipPrice = Double(originalPrice!) * Double(tipPercentage) / 100
        let totalPrice = originalPrice! + tipPrice
        
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
        
    }
    
}

