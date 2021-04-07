//
//  DemoTabBarControllerViewController.swift
//  BoostAiUIApp
//
//  Copyright © 2021 boost.ai
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
//  Please contact us at contact@boost.ai if you have any questions.
//

import UIKit
import BoostAI

class DemoTabBarControllerViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backend = ChatBackend.shared
        backend.domain = "sdk.boost.ai"
        backend.languageCode = "no-NO"
        
        let chatDialogVC = DemoChatViewController(backend: backend)
        chatDialogVC.tabBarItem = UITabBarItem(title: "Fullscreen", image: UIImage(named: "expand-light"), selectedImage: nil)
        let chatDialogNavController = DemoNavigationController(rootViewController: chatDialogVC)
        
        let floatingDialogNavController = viewControllers!.first! as! UINavigationController
        let floatingDialogVC = floatingDialogNavController.viewControllers.first! as! FloatingAvatarViewController
        floatingDialogVC.tabBarItem = UITabBarItem(title: "Floating", image: UIImage(named: "circle-light"), selectedImage: nil)
        floatingDialogVC.backend = backend
        
        let secureBackend = ChatBackend()
        secureBackend.domain = backend.domain
        secureBackend.languageCode = backend.languageCode
        secureBackend.userToken = UUID().uuidString
        
        let secureChatDialogVC = DemoChatViewController(backend: secureBackend)
        secureChatDialogVC.tabBarItem = UITabBarItem(title: "Secure chat", image: UIImage(named: "secure"), selectedImage: nil)
        let secureChatDialogNavController = DemoNavigationController(rootViewController: secureChatDialogVC)
        
        viewControllers = [floatingDialogNavController, chatDialogNavController, secureChatDialogNavController]
        
        tabBar.tintColor = UIColor.BoostAI.purple
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
