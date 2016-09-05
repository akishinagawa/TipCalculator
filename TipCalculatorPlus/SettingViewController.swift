//
//  SettingViewController.swift
//  TipCalculatorPlus
//
//  Created by Akifumi Shinagawa on 7/5/16.
//  Copyright © 2016 BlurryBlue. All rights reserved.
//


import UIKit

import Foundation

class SettingViewController: UIViewController {

    let defaultminTipPercentageMax = 10.0
    let defaultMaxTipPercentageMax = 20.0
    
    var minTipPercentage = 0.0
    var maxTipPercentage = 0.0
    
    @IBOutlet weak var minPercentgeLabel: UILabel!
    @IBOutlet weak var maxPercentageLabel: UILabel!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTipPercentageValues()
        
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

}