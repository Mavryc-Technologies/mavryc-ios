//
//  AircraftSelectViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/7/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class AircraftSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties

    var offscreenRight: CGFloat = 1000.0
    var offscreenLeft: CGFloat = -1000.0
    var onscreenX: CGFloat = 20.0
    
    // note: upon didSet, this the origin needs to be (totalSuperview width - 300) / 2 in order to center it, and then the offscreen
    @IBOutlet weak var subscreen1LeadingSpaceConstraint: NSLayoutConstraint! {
        didSet {
            //self.subscreen1VisibleX = (self.view.frame.size.width - 300) / 2
            //subscreen1LeadingSpaceConstraint.constant = self.subscreen1VisibleX
            
            self.onscreenX = subscreen1LeadingSpaceConstraint.constant
            
            // put subscreen1 offscreen
            subscreen1LeadingSpaceConstraint.constant = self.offscreenRight
        }
    }
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var nextButton: StyledButton! {
        didSet{
            // TODO: check trip data to see if enabled nextButton
            nextButton.isEnabled = false
        }
    }
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    
    @IBOutlet weak var leftChevron: UIImageView! {
        didSet {
            leftChevron.isHidden = true
        }
    }
    
    @IBOutlet weak var rightChevron: UIImageView! {
        didSet {
            rightChevron.isHidden = true
        }
    }
    
    // MARK: Temp Data
    var titleData = ["MID","SUPER","HEAVY"]
    var subtitleData = ["Flight Time: 1hr 32mins","Flight Time: 1hr 24mins","Flight Time: 1hr 12mins"]
    var costData = [" $12,995.95"," $14,775.00", " $17,445.00"]

    var cellWasSelectedAtIndexPath: IndexPath?
    
    // MARK: - Screen and Subscreen support
    var currentSubscreenIndex = 0 // 0, 1, 2, or 3 where = represents main screen
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ScreenNavigator.sharedInstance.registerScreen(screen: self, asScreen: .aircraftSelection)
        
        tableView.register(UINib(nibName: "AircraftSelectCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(infoButtonTap),
                                               name: Notification.Name.SubscreenEvents.AircraftCellInfoButtonTap,
                                               object: nil)
        
        self.setupSwipeGesture()
        
        //self.tableView(self.tableView, didSelectRowAt: IndexPath(row: 1, section: 0)) // defaults to second item
        cellWasSelectedAtIndexPath = IndexPath(row: 1, section: 0)
        nextButton.isEnabled = true
        
        // this will center appropriately each subscreen setting their constraint.constant to onscreenX
        self.onscreenX = ((self.view.frame.size.width - 300) / 2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ScreenNavigator.sharedInstance.currentPanelScreen = .aircraftSelection
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - Info Button Handler
    @objc private func infoButtonTap(notif: NSNotification) {
        if let userInfo = notif.userInfo as? [String: Int] {
            let subscreen = userInfo["tag"]
            self.transitionToSubscreen(currentScreenIndex: self.currentSubscreenIndex, targetScreenIndex: subscreen!)
        }
    }
    
    // MARK: - Control Actions
    
    func setupSwipeGesture() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        
        if self.currentSubscreenIndex > 0 {
            
            // handle subscreen swiping
            if gesture.direction == UISwipeGestureRecognizerDirection.right {
                print("SUBSCREEN    Swipe Right")
                self.navigateSubscreenLeft()
            } else if gesture.direction == UISwipeGestureRecognizerDirection.left {
                print("SUB SCREEN Swipe Left")
                self.navigateSubscreenRight()
            }
            
            return
        }
        
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            print("Swipe Right")
            ScreenNavigator.sharedInstance.navigateBackward()
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            print("Swipe Left")
            if nextButton.isEnabled {
                self.performSegue(withIdentifier: "ConfirmDetailsScreenSegue", sender: self)
            }
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.up {
            print("Swipe Up")
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.down {
            print("Swipe Down")
            ScreenNavigator.sharedInstance.closePanel()
        }
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AircraftDetailsViewControllerSegue1" {
            let vc = segue.destination as? AircraftDetailViewController
            vc?.costData = self.costData[0]
            vc?.titleData = self.titleData[0]
            vc?.subtitleData = self.subtitleData[0]
        } else if segue.identifier == "e" {

        } else if segue.identifier == "t" {

        }
    }
    
    // MARK: - Subscreen mode support
    
    @IBAction func leftChevronTapAction(_ sender: Any) {
        self.navigateSubscreenLeft()
    }
    
    @IBAction func rightChevronTapAction(_ sender: Any) {
        self.navigateSubscreenRight()
    }
    

    fileprivate func navigateSubscreenLeft() {
        if currentSubscreenIndex - 1 < 0 {
            return
        }
        
        self.transitionToSubscreen(currentScreenIndex: self.currentSubscreenIndex, targetScreenIndex: self.currentSubscreenIndex - 1)
    }
    
    fileprivate func navigateSubscreenRight() {
        if currentSubscreenIndex + 1 > 3 {
            return
        }
        
        self.transitionToSubscreen(currentScreenIndex: self.currentSubscreenIndex, targetScreenIndex: self.currentSubscreenIndex + 1)
    }
    
    func transitionToSubscreen(currentScreenIndex: Int?, targetScreenIndex: Int?) {
        
        if let currentScreen = currentScreenIndex, let targetScreen = targetScreenIndex {
            
            if targetScreen < currentScreen { // GOING LEFT
                let goHome = targetScreen == 0
                if goHome {
                    UIView.animate(withDuration: 0.3, animations: { 
                        // move subscreens off screen
                        self.subscreen1LeadingSpaceConstraint.constant = self.offscreenRight
                        // and 2 = offscreenRight
                        // and 3 = offscreenRight
                        
                        self.view.layoutIfNeeded()
                    }, completion: { (done) in
                        UIView.animate(withDuration: 0.2, animations: { 
                            self.tableView.isHidden = false
                            self.leftChevron.isHidden = true
                            self.rightChevron.isHidden = true
                            self.view.layoutIfNeeded()
                        })
                    })
                } else {
                    let goScreen2LeftFrom3 = targetScreen == 2
                    let goScreen1LeftFrom2 = targetScreen == 1
                    
                    if goScreen2LeftFrom3 {
                        self.tableView.isHidden = true
                        // TODO: screen2 = offscreenLeft
                        // here... then, animate...
                        UIView.animate(withDuration: 0.3, animations: { 
                            self.leftChevron.isHidden = false
                            self.rightChevron.isHidden = false

                            self.subscreen1LeadingSpaceConstraint.constant = self.offscreenLeft
                            // 2 = ONSCREENX
                            // and 3 = offscreenXRight
                        })

                    } else if goScreen1LeftFrom2 {

                        self.subscreen1LeadingSpaceConstraint.constant = self.offscreenLeft
                        //self.tableView.isHidden = true
                        UIView.animate(withDuration: 0.3, animations: {
                            self.leftChevron.isHidden = false
                            self.rightChevron.isHidden = false
                            self.subscreen1LeadingSpaceConstraint.constant = self.onscreenX
                            // TODO: screen2 = offscreenRight
                            // and 2 = onscreenXRight
                            // and 3 = offscreenXRight
                        })
                    }

                }
            } else { // GOING RIGHT
                let goScreen1RightFrom0 = targetScreen == 1
                if goScreen1RightFrom0 {
                    
                    self.subscreen1LeadingSpaceConstraint.constant = self.offscreenRight
                    UIView.animate(withDuration: 0.3, animations: {
                        self.tableView.isHidden = true
                        self.leftChevron.isHidden = false
                        self.rightChevron.isHidden = false
                        
                        self.subscreen1LeadingSpaceConstraint.constant = self.onscreenX
                        // and 2 = offscreenRight
                        // and 3 = offscreenRight
                        self.view.layoutIfNeeded()
                    })
                } else if targetScreen == 2 { // from left to right
                    // 2 offscreenRight
                    UIView.animate(withDuration: 0.3, animations: {
                        self.tableView.isHidden = true
                        self.leftChevron.isHidden = false
                        self.rightChevron.isHidden = false

                        self.subscreen1LeadingSpaceConstraint.constant = self.offscreenLeft
                        // and 2 ONSCREEN
                        // and 3 offscreenRight
                        
                        self.view.layoutIfNeeded()
                    })
                } else {
                    // 3 offscreenRight
                    UIView.animate(withDuration: 0.3, animations: {
                        self.tableView.isHidden = true
                        self.leftChevron.isHidden = false
                        self.rightChevron.isHidden = false
                        
                        self.subscreen1LeadingSpaceConstraint.constant = self.offscreenLeft
                        // hide the others subviews not targeted too
                        // 2 offscreenLeft
                        // 3 ONSCREEN
                        
                        self.view.layoutIfNeeded()
                    })
                }
            }
            
            self.currentSubscreenIndex = targetScreen
        }
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleData.count    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let customCell = cell as? AircraftSelectCell {

            // setup info details tag for supporting subscreen behavior
            customCell.tag = indexPath.row + 1
            
            customCell.lefthandView.backgroundColor = AppStyle.aircraftSelectScreenCellNormalColor
            
            customCell.title.text = titleData[indexPath.row] + costData[indexPath.row]
            customCell.unattributedTitle = customCell.title.text
            customCell.subtitle.text = subtitleData[indexPath.row]
            
            customCell.title.textColor = AppStyle.aircraftSelectScreenCellTextNormalColor
            
            if let selectedCellIndexPath = cellWasSelectedAtIndexPath {
                if selectedCellIndexPath == indexPath {
                    highlightCell(cell: customCell, indexPath: indexPath)
                    highlightCellBackground(cell: customCell)
                } else {
                    delightCell(cell: customCell) // turns off highlight for rest of cells once a cell is selected
                }
            } else {
                highlightCell(cell: customCell, indexPath: indexPath)
            }
            
            return customCell
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("I was tapped")
        
        if let cell = tableView.cellForRow(at: indexPath) as? AircraftSelectCell {
            if cell.isSelected {
                
                cellWasSelectedAtIndexPath = indexPath
                
                cell.lefthandView.backgroundColor = AppStyle.aircraftSelectScreenCellHighlightColor
                cell.title.textColor = AppStyle.aircraftSelectScreenCellTextHighlightPrimaryColor
                
                highlightCell(cell: cell, indexPath: indexPath)
                
                nextButton.isEnabled = true
                
                // reload
                tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AircraftSelectCell {
            delightCell(cell: cell)
        }
    }
    
    private func highlightCellBackground(cell: AircraftSelectCell) {
        cell.lefthandView.backgroundColor = AppStyle.aircraftSelectScreenCellHighlightColor
    }
    
    private func highlightCell(cell: AircraftSelectCell, indexPath: IndexPath) {
        if let _ = cell.unattributedTitle {
            let attributedString = self.applyColorToTitle(indexPath: indexPath, color: AppStyle.aircraftSelectScreenCellTextHighlightSecondaryColor)
            cell.title.attributedText = attributedString
        }
    }
    
    private func delightCell(cell: AircraftSelectCell) {
        cell.lefthandView.backgroundColor = AppStyle.aircraftSelectScreenCellNormalColor
        cell.title.textColor = AppStyle.aircraftSelectScreenCellTextNormalColor
        cell.title.attributedText = nil
        cell.title.text = cell.unattributedTitle
        cell.lefthandView.backgroundColor = AppStyle.aircraftSelectScreenCellNormalColor
    }
    
    private func applyColorToTitle(indexPath: IndexPath, color: UIColor) -> NSAttributedString {
        let cost = costData[indexPath.row]
        let title = titleData[indexPath.row]
        let combined = title + cost
        
        // yellow/gold
        let range = (combined as NSString).range(of: cost)
        let attribute = NSMutableAttributedString.init(string: combined)
        attribute.addAttribute(NSForegroundColorAttributeName, value: color , range: range)
        
        // white
        let whiteRange = (combined as NSString).range(of: title)
        attribute.addAttribute(NSForegroundColorAttributeName, value: AppStyle.aircraftSelectScreenCellTextHighlightPrimaryColor , range: whiteRange)
        
        return attribute
    }
}

extension AircraftSelectViewController: ScreenNavigable {
    
    func screenNavigator(_ screenNavigator: ScreenNavigator, backButtonWasPressed: Bool) {}
    
    func screenNavigatorIsScreenVisible(_ screenNavigator: ScreenNavigator) -> Bool? {
        return nil
    }
    
    func screenNavigatorRefreshCurrentScreen(_ screenNavigator: ScreenNavigator) {}
}
