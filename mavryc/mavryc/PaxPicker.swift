//
//  PaxPicker.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/5/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit
import AVFoundation

@IBDesignable class PaxPicker: UIView {
    
    
    @IBOutlet weak var iconImageView: UIImageView! {
        didSet {
            if self.isTimeControl {
                iconImageView.image = UIImage(named: "TimeIconFormPDF")
            } else {
                iconImageView.image = UIImage(named: "PAXIconFormPDF")
            }
        }
    }
    
    @IBInspectable var isTimeControl: Bool = true {
        didSet {
            if isTimeControl {
                iconImageView.image = UIImage(named: "TimeIconFormPDF")
                self.updateUIBarIndicator(to: 50.0) // 5 pixels * 10 bars
                self.PaxCountLabel.text = "10:00 AM"
            } else {
                iconImageView.image = UIImage(named: "PAXIconFormPDF")
            }
        }
    }
    
    @IBOutlet var view: UIView!
    var nibName: String = "PaxPicker"
    
    @IBOutlet weak var PaxCountLabel: UILabel!
    @IBOutlet weak var filledBarsImageView: UIImageView!
    
    @IBOutlet weak var maskingBar: UIView!
    @IBOutlet weak var maskingBarWidthConstraint: NSLayoutConstraint!
    
    var firstTouchPan: CGPoint? = nil
    
    var buttonSound: AVAudioPlayer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        view = loadViewFromNib()
        view.translatesAutoresizingMaskIntoConstraints = true // NOTE: lesson learned: hours saved if you'll remember -- without this set to true, you'll need to programaticaly provide constraints
        
        view.frame = self.bounds
        addSubview(view)
        
        filledBarsImageView.mask = maskingBar
        
        self.buttonSound = soundPlayer()
    }
    
    func soundPlayer() -> AVAudioPlayer? {
        if let path = Bundle.main.path(forResource: "tap5", ofType:"wav") {
            let url = URL(fileURLWithPath: path)
            
            do {
                let sound = try AVAudioPlayer(contentsOf: url)
//                self.player = sound
                sound.numberOfLoops = 1
                sound.prepareToPlay()
                return sound
                //sound.play()
            } catch {
                print("error loading file")
                // couldn't load file :(
            }
        }
        return nil
    }
    
    func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: nibName, bundle: Bundle(for: type(of: self)))
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
    // MARK: Indicator methods
    private func updateUIBarIndicator(to barProgressPercent: CGFloat) {
        maskingBar.frame = CGRect(x: maskingBar.frame.origin.x, y: maskingBar.frame.origin.y, width: barProgressPercent, height: maskingBar.frame.height)
    }
    
    private func triggerUIFeedback() {
        
        buttonSound?.play()
        
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    private func formattedIndicatorText(for numberOfBars: Int) -> String {
        if self.isTimeControl {
            var formattedTime = String(numberOfBars)
            let amPmString = (numberOfBars >= 12) ? "PM" : "AM"
            
            if FeatureFlag.militaryTime.isFeatureEnabled() {
                if numberOfBars < 10 {
                    formattedTime = "0" + formattedTime + ":00"
                } else {
                    formattedTime = formattedTime + ":00"
                }
            } else {
                if numberOfBars > 12 {
                    formattedTime = "\(numberOfBars - 12)"
                }
                
                formattedTime = formattedTime + ":00" + " \(amPmString)"
            }
            
            return formattedTime
        } else {
            return String(numberOfBars)
        }
    }
    
    // MARK: Gestures
    var previousPaxCount = 1
    @IBAction func panGestureAction(_ gestureRecognizer : UIPanGestureRecognizer) {
        if gestureRecognizer.state == .changed || gestureRecognizer.state == .began {
            
            let x = gestureRecognizer.location(in: gestureRecognizer.view).x
            let percentTouchOverMaxPixels = x / filledBarsImageView.frame.width
            var numberOfBars = Int(percentTouchOverMaxPixels * 24)
//            
//            if previousPaxCount < numberOfBars || previousPaxCount > numberOfBars {
//                self.triggerUIFeedback()
//            }
            
            let prev = previousPaxCount
            previousPaxCount = numberOfBars
            
            numberOfBars = max(numberOfBars, 1) // has to be 1 or more
            numberOfBars = min(numberOfBars, 24)  // has to be 24 or less
            
            if prev != numberOfBars && !(numberOfBars == 24 || numberOfBars == 1) {
                self.triggerUIFeedback()
            }
            
            PaxCountLabel.text = self.formattedIndicatorText(for: numberOfBars)
            
            let jumpGap = filledBarsImageView.frame.width / 24
            var barsProgress = CGFloat(numberOfBars) * jumpGap
            barsProgress = max(barsProgress, jumpGap)
            barsProgress = min(barsProgress, filledBarsImageView.frame.width)

            self.updateUIBarIndicator(to: barsProgress)
        }
    }
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        
        self.triggerUIFeedback()
        
        let x = sender.location(in: sender.view).x
        let percentTouchOverMaxPixels = x / filledBarsImageView.frame.width
        var numberOfBars = Int(percentTouchOverMaxPixels * 24)
        numberOfBars = max(numberOfBars, 1) // has to be 1 or more
        numberOfBars = min(numberOfBars, 24)  // has to be 24 or less

        PaxCountLabel.text = self.formattedIndicatorText(for: numberOfBars)
        
        let jumpGap = filledBarsImageView.frame.width / 24
        var barsProgress = CGFloat(numberOfBars) * jumpGap
        barsProgress = max(barsProgress, jumpGap)
        barsProgress = min(barsProgress, filledBarsImageView.frame.width)
        self.updateUIBarIndicator(to: barsProgress)
    }
    
}
