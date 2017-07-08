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
    
    // MARK: - Outlet Properties
    
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
                self.updateUIBarIndicator(to: 10) // 5 pixels * 10 bars
                self.PaxCountLabel.text = "10:00 AM"
            } else {
                iconImageView.image = UIImage(named: "PAXIconFormPDF")
                self.updateUIBarIndicator(to: 1)
                self.PaxCountLabel.text = "1"
            }
        }
    }
    
    /// container view for dynamically generated bars
    @IBOutlet weak var barsContainerView: UIView!
    
    @IBOutlet var view: UIView!
    var nibName: String = "PaxPicker"
    
    @IBOutlet weak var PaxCountLabel: UILabel!
    
    @IBOutlet weak var maskingBar: UIView!
    @IBOutlet weak var maskingBarWidthConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var firstTouchPan: CGPoint? = nil
    
    var buttonSound: AVAudioPlayer?
    
    var totalBars = 24
    var barsArray: [UIView] = []
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: nibName, bundle: Bundle(for: type(of: self)))
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
    func setup() {
        view = loadViewFromNib()
        view.translatesAutoresizingMaskIntoConstraints = true // NOTE: lesson learned: hours saved if you'll remember -- without this set to true, you'll need to programaticaly provide constraints
        view.frame = self.bounds
        addSubview(view)
        
        self.buttonSound = soundPlayer()
        
        // TODO: setup initial dynamic bars (both underlays and highlights)
        for index in 1...totalBars {
            let containerWidth = barsContainerView.frame.width
            let barHeight = barsContainerView.frame.height
            let barWidth = 2
            let sectionSpanWidth = containerWidth / CGFloat(totalBars)
            //let gaps = sectionSpanWidth - CGFloat(barWidth)
            let x = (CGFloat(index) * sectionSpanWidth)
            let aView = UIView(frame: CGRect(x: x, y: 0.0, width: CGFloat(barWidth), height: CGFloat(barHeight)))
            let underView = UIView(frame: CGRect(x: x, y: 0.0, width: CGFloat(barWidth), height: CGFloat(barHeight)))
            underView.backgroundColor = AppStyle.skylarGrey
            aView.backgroundColor = AppStyle.skylarGrey
            aView.tag = index
            barsContainerView.addSubview(underView)
            barsContainerView.addSubview(aView)
            barsArray.append(aView)
        }
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
    
    // MARK: Indicator methods
    
    private func updateUIBarIndicator(to barNumber: Int) {
        // iterate through bars and set the appropriate value for the current bar setting (barNumber)
        for aView in barsArray.reversed() {
            if aView.tag > barNumber {
                // color as dimmed
                aView.backgroundColor = AppStyle.skylarGrey
            } else if aView.tag == barNumber {
                // set brightest hilite
                aView.backgroundColor = AppStyle.skylarGold
            } else if aView.tag < barNumber {
                let diff = barNumber - aView.tag
                let color = AppStyle.skylarGold
                let alpha = CGFloat(1 - (CGFloat(diff) * 0.05))
                if alpha <= 0.0 {
                    aView.backgroundColor = AppStyle.skylarGrey
                } else {
                    aView.backgroundColor = color.withAlphaComponent(alpha)
                }
                
            }
        }
    }
    
    private func triggerUIFeedback() {
        
        buttonSound?.play()
        
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    // MARK: Gestures
    
    var previousPaxCount = 1
    @IBAction func panGestureAction(_ gestureRecognizer : UIPanGestureRecognizer) {
        if gestureRecognizer.state == .changed || gestureRecognizer.state == .began {
            
            let x = gestureRecognizer.location(in: gestureRecognizer.view).x
            let percentTouchOverMaxPixels = x / barsContainerView.frame.width
            var numberOfBars = Int(percentTouchOverMaxPixels * CGFloat(totalBars))
            
            let prev = previousPaxCount
            previousPaxCount = numberOfBars
            
            numberOfBars = max(numberOfBars, 1) // has to be 1 or more
            numberOfBars = min(numberOfBars, totalBars)  // has to be 24 or less
            
            if prev != numberOfBars && !(numberOfBars == totalBars || numberOfBars == 1) {
                self.triggerUIFeedback()
            }
            
            PaxCountLabel.text = self.formattedIndicatorText(for: numberOfBars)
            
            let jumpGap = barsContainerView.frame.width / CGFloat(totalBars)
            var barsProgress = CGFloat(numberOfBars) * jumpGap
            barsProgress = max(barsProgress, jumpGap)
            barsProgress = min(barsProgress, barsContainerView.frame.width)

            self.updateUIBarIndicator(to: numberOfBars)
        }
    }
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        
        self.triggerUIFeedback()
        
        let x = sender.location(in: sender.view).x
        let percentTouchOverMaxPixels = x / barsContainerView.frame.width
        var numberOfBars = Int(percentTouchOverMaxPixels * CGFloat(totalBars))
        numberOfBars = max(numberOfBars, 1) // has to be 1 or more
        numberOfBars = min(numberOfBars, totalBars)  // has to be 24 or less

        PaxCountLabel.text = self.formattedIndicatorText(for: numberOfBars)
        
        let jumpGap = barsContainerView.frame.width / CGFloat(totalBars)
        var barsProgress = CGFloat(numberOfBars) * jumpGap
        barsProgress = max(barsProgress, jumpGap)
        barsProgress = min(barsProgress, barsContainerView.frame.width)
        self.updateUIBarIndicator(to: numberOfBars)
    }
    
    // MARK: Support
    
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
}
