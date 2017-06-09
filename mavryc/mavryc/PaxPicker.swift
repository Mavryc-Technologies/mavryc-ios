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
        if let path = Bundle.main.path(forResource: "digi_plink_short", ofType:"wav") {
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
    
    // MARK: Gestures
    var previousPaxCount = 1
    @IBAction func panGestureAction(_ gestureRecognizer : UIPanGestureRecognizer) {
        if gestureRecognizer.state == .changed || gestureRecognizer.state == .began {
            
            let x = gestureRecognizer.location(in: gestureRecognizer.view).x
            let percentTouchOverMaxPixels = x / filledBarsImageView.frame.width
            var numberOfPax = Int(percentTouchOverMaxPixels * 24)
            
            if previousPaxCount < numberOfPax || previousPaxCount > numberOfPax {
                buttonSound?.play()
                if #available(iOS 10.0, *) {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                } else {
                    // Fallback on earlier versions
                }
            }
            
            previousPaxCount = numberOfPax
            
            numberOfPax = max(numberOfPax, 1) // has to be 1 or more
            numberOfPax = min(numberOfPax, 24)  // has to be 24 or less
            
            PaxCountLabel.text = String(numberOfPax)
            
            let jumpGap = filledBarsImageView.frame.width / 24
            var barsProgress = CGFloat(numberOfPax) * jumpGap
            barsProgress = max(barsProgress, jumpGap)
            barsProgress = min(barsProgress, filledBarsImageView.frame.width)

            maskingBar.frame = CGRect(x: maskingBar.frame.origin.x, y: maskingBar.frame.origin.y, width: barsProgress, height: maskingBar.frame.height)
        }
    }
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {

        buttonSound?.play()
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        } else {
            // Fallback on earlier versions
        }
        
        let x = sender.location(in: sender.view).x
        let percentTouchOverMaxPixels = x / filledBarsImageView.frame.width
        var numberOfPax = Int(percentTouchOverMaxPixels * 24)
        numberOfPax = max(numberOfPax, 1) // has to be 1 or more
        numberOfPax = min(numberOfPax, 24)  // has to be 24 or less
        
        PaxCountLabel.text = String(numberOfPax)
        
        let jumpGap = filledBarsImageView.frame.width / 24
        var barsProgress = CGFloat(numberOfPax) * jumpGap
        barsProgress = max(barsProgress, jumpGap)
        barsProgress = min(barsProgress, filledBarsImageView.frame.width)
        
        maskingBar.frame = CGRect(x: maskingBar.frame.origin.x, y: maskingBar.frame.origin.y, width: barsProgress, height: maskingBar.frame.height)
    
        
    }
    
}
