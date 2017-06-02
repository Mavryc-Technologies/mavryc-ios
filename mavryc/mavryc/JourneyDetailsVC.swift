//
//  JourneyDetailsVC.swift
//  mavryc
//
//  Created by Todd Hopkinson on 5/12/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class JourneyDetailsVC: UIViewController {

    // MARK: Properties
    // TODO: add enum for state of control
    
    // MARK: Outlet Properties
    @IBOutlet weak var nextButton: UIButton! {
        didSet {
            nextButton.layer.borderWidth = 1
            nextButton.layer.borderColor = AppStyle.journeyDetailsNextButtonBorderColor.cgColor
            nextButton.layer.backgroundColor = AppStyle.journeyDetailsNextButtonBGColor.cgColor
            nextButton.layer.cornerRadius = 12
        }
    }
    
    @IBOutlet weak var oneWayReturnSegmentControl: UISegmentedControl! {
        didSet {
            oneWayReturnSegmentControl.setTitleTextAttributes([NSForegroundColorAttributeName: AppStyle.journeyDetailsSegmentedControllerHighlightTextColor], for: UIControlState.selected)
            oneWayReturnSegmentControl.setTitleTextAttributes([NSForegroundColorAttributeName: AppStyle.journeyDetailsSegmentedControllerNormalTextColor], for: UIControlState.normal)
        }
    }
    
    // use to expand or retract departure city/airport list
    @IBOutlet weak var departureTableViewHeightConstraint: NSLayoutConstraint!
    
    // use to expand or retract arrival city/airport list
    @IBOutlet weak var arrivalTableViewHeightConstraint: NSLayoutConstraint!
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.deselectSearchControls()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Control Actions
    
    @IBAction func nextButtonAction(_ sender: Any) {
        print("next button pressed")
    }
    
    @IBAction func departureIconTapAction(_ sender: Any) {
        print("tapped departure icon")
        self.triggerDepartureList()
    }
    
    @IBAction func arrivalIconTapAction(_ sender: Any) {
        print("tapped arrival icon")
        self.triggerArrivalList()
    }
    
    // MARK: - Search Control Support
    func triggerDepartureList() {
        if self.departureTableViewHeightConstraint.constant == 0 {
            self.arrivalTableViewHeightConstraint.constant = 0
            self.departureTableViewHeightConstraint.constant = 600
        } else {
            self.departureTableViewHeightConstraint.constant = 0
        }
    }

    func triggerArrivalList() {
        if self.arrivalTableViewHeightConstraint.constant == 0 {
            self.arrivalTableViewHeightConstraint.constant = 600
            self.departureTableViewHeightConstraint.constant = 0
        } else {
            self.arrivalTableViewHeightConstraint.constant = 0
        }
    }
    
    func deselectSearchControls() {
        self.arrivalTableViewHeightConstraint.constant = 0
        self.departureTableViewHeightConstraint.constant = 0
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
