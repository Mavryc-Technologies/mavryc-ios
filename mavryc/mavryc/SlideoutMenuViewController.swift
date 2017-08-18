//
//  SlideoutMenuViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 8/10/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit
import LFLoginController

class SlideoutMenuViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        }
    }
    
    @IBOutlet weak var profileNameLabel: UILabel!
    
    @IBOutlet weak var versionLabel: UILabel! {
        didSet {
            
            versionLabel.text = "\(Bundle.main.appName) v \(Bundle.main.versionNumber) (Build \(Bundle.main.buildNumber))"
        }
    }
    
    enum Menu: String {
        case settings
        case help
        case profile
    }
    
    var menuList: [Menu] = [.settings,.help,.profile]
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SlideoutMenuTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "menuCell")
        
        profileNameLabel.text = "John Appleseed"
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.layer.masksToBounds = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.layer.masksToBounds = true
    }
    
    
    // MARK: - control actions
    
    @IBAction func dismissalTapAction(_ sender: UITapGestureRecognizer) {
                NotificationCenter.default.post(name: Notification.Name.SlideoutMenu.CloseWasTapped, object: self, userInfo:[:])
    }
    
    @IBAction func profileHeaderTapAction(_ sender: UITapGestureRecognizer) {
        
        self.presentScreen(menuItem: .profile)
    }
    
    
    
    // MARK: - Present Menu Screens
    
    func presentScreen(menuItem: Menu) {
        switch menuItem {
        case .help:
            let sb = UIStoryboard.init(name: "Profile", bundle: Bundle.main)
            if let vc = sb.instantiateInitialViewController(){
                self.show(vc, sender: self)
            }
            break
        case .profile:
            LoginManager.shared.presentLoginScreen(sender: self)
            
            break
        case .settings:
            let sb = UIStoryboard.init(name: "Profile", bundle: Bundle.main)
            if let vc = sb.instantiateInitialViewController(){
                self.show(vc, sender: self)
            }
            break
        }
    }
}

extension SlideoutMenuViewController: LoginMulticastDelegate {
    
    func identifier() -> String {
        return self.description
    }
    
    func onLogin(success: Bool, manager: LoginManager, Login: LoginUser) {
        print("onLogin")
        
        if success {
            print("login success")
            manager.dismissLoginScreen()
        }
    }
    
    func onLogout(manager: LoginManager) {
        print("onLogout")
    }
}


extension SlideoutMenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 49.5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuItem = self.menuList[indexPath.row]
        self.presentScreen(menuItem: menuItem)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as? SlideoutMenuTableViewCell else { return UITableViewCell() }
        cell.title?.text = menuList[indexPath.row].rawValue.capitalizingFirstLetter()
        return cell
    }
}
