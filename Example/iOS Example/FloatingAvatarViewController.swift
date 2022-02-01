//
//  ViewController.swift
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

class FloatingAvatarViewController: UIViewController {
    
    var backend: ChatBackend!
    var customConfig: ChatConfig? = nil
    var conversationId: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "boost.ai DEMO"
        tabBarItem.title = "Floating"
        
        backend.onReady { [weak self] (_, _) in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                
                let avatarView = AgentAvatarView(backend: strongSelf.backend,
                                                 customConfig: strongSelf.customConfig)
                avatarView.translatesAutoresizingMaskIntoConstraints = false
                
                strongSelf.view.addSubview(avatarView)
                
                let constraints = [
                    strongSelf.view.trailingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 20),
                    strongSelf.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 20)
                ]
                
                NSLayoutConstraint.activate(constraints)
            }
        }
    }

}

