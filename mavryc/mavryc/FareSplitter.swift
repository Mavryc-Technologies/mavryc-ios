//
//  FareSplitterView.swift
//  mavryc
//
//  Created by Todd Hopkinson on 7/14/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit
import AVFoundation

protocol FareSplitterDelegate {
    func fareSplitter(fareSplitter: FareSplitter, closeButtonWasTapped:  Bool)
    func fareSplitter(fareSplitter: FareSplitter, didUpdateBarsToVale: Int)
}

@IBDesignable class FareSplitter: UIView {
    
    // MARK: - Properties
    
    var delegate: FareSplitterDelegate?
    
    @IBOutlet weak var backgroundShapeView: UIView! {
        didSet {
            backgroundShapeView.layer.cornerRadius = 6
        }
    }
    
    @IBOutlet weak var closeButton: UIImageView!
    
    @IBOutlet weak var seatsLabel: UILabel!
    
    @IBOutlet weak var barsContainer: UIView!
    
    
    @IBInspectable var isPrimaryUserControl: Bool = false {
        didSet {
            if isPrimaryUserControl {
                closeButton.isHidden = true
                //                iconImageView.image = UIImage(named: "TimeIconFormPDF")
                //                self.updateUIBarIndicator(to: 10) // 5 pixels * 10 bars
                //                self.PaxCountLabel.text = "10:00 AM"
            } else {
                closeButton.isHidden = false
                //                iconImageView.image = UIImage(named: "PAXIconFormPDF")
                //                self.updateUIBarIndicator(to: 1)
                //                self.PaxCountLabel.text = "1"
            }
        }
    }
    
    @IBOutlet weak var priceLabel: UILabel!
    
    var totalBars = 24
    var barsArray: [UIView] = []
    var buttonSound: AVAudioPlayer?
    var firstTouchPan: CGPoint? = nil
    
    // MARK: - Initialization
    @IBOutlet var view: UIView!
    var nibName: String = "FareSplitter"
    
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
        
        view.backgroundColor = UIColor.clear
        
        self.buttonSound = soundPlayer()

        for index in 1...totalBars {
            let containerWidth = barsContainer.frame.width
            let barHeight = barsContainer.frame.height
            let barWidth = 2
            let sectionSpanWidth = containerWidth / CGFloat(totalBars)
            let x = (CGFloat(index) * sectionSpanWidth)
            let aView = UIView(frame: CGRect(x: x, y: 0.0, width: CGFloat(barWidth), height: CGFloat(barHeight)))
            let underView = UIView(frame: CGRect(x: x, y: 0.0, width: CGFloat(barWidth), height: CGFloat(barHeight)))
            underView.backgroundColor = AppStyle.skylarGrey
            aView.backgroundColor = AppStyle.skylarGrey
            aView.tag = index
            barsContainer.addSubview(underView)
            barsContainer.addSubview(aView)
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
            let percentTouchOverMaxPixels = x / barsContainer.frame.width
            var numberOfBars = Int(percentTouchOverMaxPixels * CGFloat(totalBars))
            
            let prev = previousPaxCount
            previousPaxCount = numberOfBars
            
            numberOfBars = max(numberOfBars, 1) // has to be 1 or more
            numberOfBars = min(numberOfBars, totalBars)  // has to be 24 or less
            
            if prev != numberOfBars && !(numberOfBars == totalBars || numberOfBars == 1) {
                self.triggerUIFeedback()
            }
            
            seatsLabel.text = "\(numberOfBars)"
            
            let jumpGap = barsContainer.frame.width / CGFloat(totalBars)
            var barsProgress = CGFloat(numberOfBars) * jumpGap
            barsProgress = max(barsProgress, jumpGap)
            barsProgress = min(barsProgress, barsContainer.frame.width)
            
            self.updateUIBarIndicator(to: numberOfBars)
            
            delegate?.fareSplitter(fareSplitter: self, didUpdateBarsToVale: numberOfBars)
        }
    }
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        
        self.triggerUIFeedback()
        
        let x = sender.location(in: sender.view).x
        let percentTouchOverMaxPixels = x / barsContainer.frame.width
        var numberOfBars = Int(percentTouchOverMaxPixels * CGFloat(totalBars))
        numberOfBars = max(numberOfBars, 1) // has to be 1 or more
        numberOfBars = min(numberOfBars, totalBars)  // has to be 24 or less
        
        seatsLabel.text = "\(numberOfBars)"
        
        let jumpGap = barsContainer.frame.width / CGFloat(totalBars)
        var barsProgress = CGFloat(numberOfBars) * jumpGap
        barsProgress = max(barsProgress, jumpGap)
        barsProgress = min(barsProgress, barsContainer.frame.width)
        self.updateUIBarIndicator(to: numberOfBars)
        
        delegate?.fareSplitter(fareSplitter: self, didUpdateBarsToVale: numberOfBars)
    }

    
    // MARK: - Control Actions
    
    @IBAction func closeButtonTapAction(_ sender: UITapGestureRecognizer) {
        delegate?.fareSplitter(fareSplitter: self, closeButtonWasTapped: true)
    }
    
}
