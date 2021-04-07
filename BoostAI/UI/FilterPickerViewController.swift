//
//  FilterPickerViewController.swift
//  BoostAI
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

open class FilterPickerViewController: UIViewController {

    open var pickerView: UIPickerView!
    open var currentFilter: ConfigFilter?
    open var filters: [ConfigFilter]?
    open var didSelectFilterItem: ((ConfigFilter) -> Void)?
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSelf))
        
        setupView()
    }
    
    private func setupView() {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.delegate = self
        pickerView.dataSource = self
        
        view.addSubview(pickerView)
        
        pickerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: pickerView.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: pickerView.bottomAnchor).isActive = true
        pickerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 216).isActive = true
        pickerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
        
        if let currentFilter = currentFilter, let index = filters?.firstIndex(where: { $0 == currentFilter }) {
            pickerView.selectRow(index, inComponent: 0, animated: false)
        }
        
        
        self.pickerView =  pickerView
    }
    
    @objc open func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
    open override var preferredContentSize: CGSize {
        set {
            super.preferredContentSize = newValue
        }
        
        get {
            return pickerView.intrinsicContentSize
        }
    }

}

extension FilterPickerViewController: UIPickerViewDataSource {
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
}

extension FilterPickerViewController: UIPickerViewDelegate {
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return filters?[row].title
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let item = filters?[row] else {
            return
        }
        
        didSelectFilterItem?(item)
    }
}
