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
        
        func iconImage() -> UIImage? {
            switch self {
            case .settings:
                return UIImage(named: "Settings Icon")
            case .profile:
                return UIImage(named: "Profile Icon")
            case .help:
                return UIImage(named: "HELP Icon")
            }
        }
    }
    
    var menuList: [Menu] = [.settings,.help,.profile]
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SlideoutMenuTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "menuCell")
        
        profileNameLabel.text = "Login"
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.layer.masksToBounds = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.layer.masksToBounds = true
        
        if User.isUserLoggedIn() {
            if let first = User.storedUser()?.firstName, let last = User.storedUser()?.lastName {
                profileNameLabel.text = first + " " + last
            } else if let email = User.storedUser()?.email {
                profileNameLabel.text = email
            }
            
            profileImageView.image = UIImage(named: "the-rock-studio71")
        } else {
            profileNameLabel.text = "Login"
            profileImageView.image = nil
        }
    }
    
    
    // MARK: - control actions
    
    @IBAction func xButtonTapAction(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name.SlideoutMenu.CloseWasTapped, object: self, userInfo:[:])
    }
    
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
            if User.isUserLoggedIn() {
                print("should show profile screen here")
                let sb = UIStoryboard.init(name: "Profile", bundle: Bundle.main)
                if let vc = sb.instantiateInitialViewController(){
                    self.show(vc, sender: self)
                }
            } else {
                LoginManager.shared.presentLoginScreen(sender: self)
            }
            
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
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuItem = self.menuList[indexPath.row]
        self.presentScreen(menuItem: menuItem)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as? SlideoutMenuTableViewCell else { return UITableViewCell() }
        cell.title?.text = menuList[indexPath.row].rawValue.capitalizingFirstLetter()
        let menuType = menuList[indexPath.row]
        cell.iconImageView.image = menuType.iconImage()
        return cell
    }
}
