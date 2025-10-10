//
//  BaseViewController.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import UIKit
import Toast

class BaseViewController: UIViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "Use init(frame:) instead.")
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.view.backgroundColor = .clear
        setupNaviBar()
    }
    
    func setupNaviBar() {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .backGround
        appearance.titleTextAttributes = [.foregroundColor: UIColor.textPrimary]
        navigationController?.navigationBar.tintColor = .textPrimary
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    // MARK: - Toast

    func showToast(message: String) {
        view.makeToast(message, duration: 2.0, position: .bottom)
    }
}
