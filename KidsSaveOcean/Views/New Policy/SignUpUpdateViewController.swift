//
//  SignUpUpdateViewController.swift
//  KidsSaveOcean
//
//  Created by Neha Mittal on 9/17/19.
//  Copyright © 2019 KidsSaveOcean. All rights reserved.
//

import AVFoundation
import UIKit
import MapKit

class SignUpUpdateViewController: UIViewController, Instantiatable {

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var chooseLocationButton: UIButton!
    
    @IBOutlet weak var policyLabel: UILabel!
    
    @IBOutlet weak var signaturesBlock: UIStackView!
    @IBOutlet weak var collectedSingaturesUpdateButton: UIButton!
    @IBOutlet weak var signaturesReqdTextField: UITextField!
    @IBOutlet weak var signaturesCollectedTextField: UITextField!
    @IBOutlet weak var newSignaturesCollected: UITextField!
    
    @IBOutlet weak var liveLocationView: UIView!
    @IBOutlet weak var chooseLocationView: UIView!
    @IBOutlet weak var pickerViewHeightConstraint: KSOLayoutConstraint!
    @IBOutlet weak var baseStackViewBottonConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var signaturesRequiredLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var signaturesTotalCollectedLabel: UILabel!
    
    @IBOutlet weak var liveCampaingStateLabel: UILabel!
    @IBOutlet weak var unliveLocationMessageLabel: UILabel!
    
    let liveCampaignLocationStateMessages = [false: "Live Campaigns: None - still building",
                                             true: "Your location is live: "]
    
    var selectedCountryForCampaign: HijackLocation?
    
    private lazy var campaigns = CampaignViewModel.shared().campaigns
    private lazy var campaignLocations = HijackPLocationViewModel.shared().hidjackPLocations.sorted { $0.location < $1.location }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(aNotification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
         
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(aNotification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
         
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(aNotification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        self.setHidingKeyboardWhenTappedAround()
        
        if UIScreen.main.bounds.height > 800 {
            pickerViewHeightConstraint.constant = 216
            baseStackViewBottonConstraint.constant = 40
        } else {
            pickerViewHeightConstraint.constant = 100
            baseStackViewBottonConstraint.constant = 20
        }
        
        let policy = "none yet - still voting"
//        let policy = HijackPoliciesViewModel.shared().hidjackPolicies.filter {$0.id == campaigns.first?.hijack_policy}.first
//        if policy != nil {
            policyLabel.attributedText = HijackPoliciesViewModel.shared().getPolicyAttrString(for: policy) //policy != nil ?  : ""
//        }
        
        unliveLocationMessageLabel.isHidden = true
        liveCampaingStateLabel.text = ""
        
        pickerView.layer.borderColor = UIColor.darkGray.cgColor
        pickerView.layer.borderWidth = 1
        
        let campaign = UserViewModel.shared().campaign

        signaturesReqdTextField.layer.borderColor = UIColor.gray.cgColor
        signaturesReqdTextField.layer.borderWidth = 1.0
        signaturesReqdTextField.roundCorners()
        signaturesReqdTextField.text = String(UserViewModel.shared().signatures_pledged)
        
        newSignaturesCollected.layer.borderColor = UIColor.gray.cgColor
        newSignaturesCollected.layer.borderWidth = 1.0
        newSignaturesCollected.roundCorners()
        newSignaturesCollected.text = ""
        
        signaturesCollectedTextField.layer.borderColor = UIColor.gray.cgColor
        signaturesCollectedTextField.layer.borderWidth = 1.0
        signaturesCollectedTextField.roundCorners()
        signaturesCollectedTextField.text = String(campaign?.signatures_collected ?? 0)
        signaturesCollectedTextField.isUserInteractionEnabled = false
        
        showLocationView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        CampaignViewModel.shared().setup()
    }
    
    // MARK:- Action methods
    @IBAction func signUpButtonClicked(_ sender: Any) {
        let locale = Locale.current
        guard let code = locale.regionCode else {
            lockChoosenLocationForUser()
            return
        }
        let countryStr = locale.localizedString(forRegionCode: code)
        let country = countryStr == "United States" ? "USA" : countryStr
        let choosenLocation = campaignLocations[pickerView.selectedRow(inComponent: 0)].location
        
        guard choosenLocation == country else {
            lockChoosenLocationForUser()
            return
        }
        
        signUpUserToTheLoaction()
    }
    
    @IBAction func plannedSignaturesClicked(_ sender: Any) {
        if let signatures = signaturesReqdTextField.text {
            //UserViewModel.shared().campaign?.signatures_pledged = Int(signatures) ?? 0
            UserViewModel.shared().signatures_pledged = Int(signatures) ?? 0
            UserViewModel.shared().saveUser()
            dismissKeyboard()
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    @IBAction func collectedSignaturesClicked(_ sender: Any) {
        guard let signatures = newSignaturesCollected.text,
            let addedSignaturesAmount = Int(signatures), addedSignaturesAmount >= 0 else {
            return
        }
        
        //if let signatures = signaturesCollectedTextField.text {
        //   let signaturesAmount = Int(signatures) ?? 0
        let currentCollectedAmount = UserViewModel.shared().campaign?.signatures_collected ?? 0
            
        //    let addedSignaturesAmount = signaturesAmount - currentCollectedAmount
    
        let userTotalSignatures = UserViewModel.shared().campaign!.signatures_collected + addedSignaturesAmount
        UserViewModel.shared().campaign?.signatures_collected = userTotalSignatures
        UserViewModel.shared().saveUser()
        signaturesCollectedTextField.text = String(userTotalSignatures)
        newSignaturesCollected.text = ""
        
        let location_id = UserViewModel.shared().location_id
        let campaign = campaigns.filter{$0.location_id == location_id}.first
        if campaign != nil {
            let newCollectedAmount = (Int(signaturesTotalCollectedLabel.text ?? "") ?? 0) + addedSignaturesAmount
                CampaignViewModel.shared().updateCollectedSignatures(campaign: campaign!, value: addedSignaturesAmount)
                signaturesTotalCollectedLabel.text = String(newCollectedAmount)
        }
        dismissKeyboard()
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        //}
    }
    
    @IBAction func shareAction(_ sender: Any) {
        ShareKidsSaveOcean.share(target: self, text: "With this app (called FateChanger), kids might be able to force through environmental policies! Check it out...")
    }
    
    @IBAction func learnMoreAction(_ sender: Any) {
        //tabBarController?.showLink("https://www.kidssaveocean.com/projects", clear: nil)
        let hijackVideoVC = YouthInitiativeProcessViewController.instantiate()
        navigationController?.pushViewController(hijackVideoVC, animated: true)
    }
    
    // MARK: Private methods
    private func showLocationView() {
        let userCampaign = UserViewModel.shared().campaign
        let campaignLive = UserViewModel.shared().isUserLocationCampaignIsLive()
        let userCampaignLocationId = UserViewModel.shared().location_id
        let currentCampaignLocationNum = campaignLocations.firstIndex(where: { (location) -> Bool in
            return location.id == userCampaignLocationId
        }) ?? 0
        
        
        if campaignLive == true {

            liveLocationView.isHidden = false
            chooseLocationView.isHidden = true
            
            setCampaignLiveDescription(currentCampaignLocationNum)
            updateLiveLocationView()
            
        } else {
            
            liveLocationView.isHidden = true
            chooseLocationView.isHidden = false
            
            signaturesReqdTextField.text = String(UserViewModel.shared().signatures_pledged)
            signaturesCollectedTextField.text = "0"
            
            //var currentCampaignLocationNum = 0
            
            if !userCampaignLocationId.isEmpty {
                pickerView.selectRow(currentCampaignLocationNum, inComponent: 0, animated: true)
                setCampaignLiveDescription(currentCampaignLocationNum)
                
                enableChooseLocationButton(false)
            } else if campaignLocations.count == 0 {
                pickerView.isUserInteractionEnabled = false
                enableChooseLocationButton(false)
            } else {
                pickerView.selectRow(0, inComponent: 0, animated: true)
                setCampaignLiveDescription(0)
            }
            
        }
        
        if userCampaign != nil, !userCampaignLocationId.isEmpty {
            //!(userCampaign!.campaign_id.isEmpty) {
            signaturesBlock.alpha = 1
        } else {
            signaturesBlock.alpha = 0
        }
        
    }
    
    private func setCampaignLiveDescription(_ num: Int) {
        selectedCountryForCampaign = campaignLocations[num]
        
        let campaign = campaigns.filter({ $0.location_id == selectedCountryForCampaign?.id }).first
        
        if selectedCountryForCampaign != nil,
            campaign != nil,
            campaign?.live == true {
            unliveLocationMessageLabel.isHidden = true
            liveCampaingStateLabel.text = liveCampaignLocationStateMessages[true]! + selectedCountryForCampaign!.location
            signaturesCollectedTextField.isEnabled = true
            collectedSingaturesUpdateButton.isEnabled = true
            collectedSingaturesUpdateButton.alpha = 1.0
            newSignaturesCollected.isUserInteractionEnabled = true
            newSignaturesCollected.alpha = 1.0
        } else {
            unliveLocationMessageLabel.isHidden = false
            liveCampaingStateLabel.text = liveCampaignLocationStateMessages[false]
            signaturesCollectedTextField.isEnabled = false
            signaturesCollectedTextField.alpha = 0.5
            collectedSingaturesUpdateButton.isEnabled = false
            collectedSingaturesUpdateButton.alpha = 0.5
            newSignaturesCollected.isUserInteractionEnabled = false
            newSignaturesCollected.alpha = 0.5
        }
    }
    
    private func updateLiveLocationView() {
        let campaign = campaigns.filter { $0.id == UserViewModel.shared().campaign?.campaign_id }.first
        signaturesRequiredLabel.text =  String( campaign?.signatures_required ?? 0)
        signaturesTotalCollectedLabel.text = String(campaign?.signatures_collected ?? 0)
        deadlineLabel.text = "--"
    }
    
    private func lockChoosenLocationForUser() {
        let alertView = UIAlertController(title: "Are you sure this is your location?", message: "", preferredStyle: .alert)
        
        let yesButton = UIAlertAction(title: "YES", style: .default) { (_) in
            self.signUpUserToTheLoaction()
        }
        yesButton.setAppTextColor()
        
        let noButton = UIAlertAction(title: "NO", style: .cancel, handler: nil)
        noButton.setAppTextColor()
//        let noButton = UIAlertAction(title: "NO", style: .default) { (_) in
//            let explainAlertView = UIAlertController(title: nil, message: "I'm sorry, but the goverment of your location doesn't offer the opportunity for citizen ballon initiatives. But you can influence them with letters in our letter-writing campaign.", preferredStyle: .alert)
//            let okButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//            explainAlertView.addAction(okButton)
//            self.present(explainAlertView, animated: true) {
//                self.enableChooseLocationButton(false)
//            }
//        }
        
        alertView.addAction(yesButton)
        alertView.addAction(noButton)
        self.present(alertView, animated: true, completion: nil)
    }
    
    private func signUpUserToTheLoaction() {
        let dialogMessage = UIAlertController(title: "Are you sure you want to choose this location?", message: "", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (_) -> Void in

            let num = self.pickerView.selectedRow(inComponent: 0)
//            guard let campaign = self.campaigns.filter({$0.location_id == self.campaignLocations[num].id}).first else {
//                return
//            }
            //first else { return }
            
            let campaign = self.campaigns.filter({$0.location_id == self.campaignLocations[num].id}).first
            if campaign != nil {
                let campSign = CampaignSignatures(campaign_id: campaign!.id, signatures_required: campaign!.signatures_required, signatures_collected: 0)
                UserViewModel.shared().campaign = campSign
                UserViewModel.shared().location_id = campaign!.location_id
            } else {
                UserViewModel.shared().location_id = self.campaignLocations[num].id
            }
            
//            let campSign = CampaignSignatures(campaign_id: campaign.id, signatures_required: campaign.signatures_required, signatures_collected: 0)
//            UserViewModel.shared().campaign = campSign
//            UserViewModel.shared().location_id = campaign.location_id
            
            UserViewModel.shared().saveUser()
            
            self.liveLocationView.isHidden = true
            self.chooseLocationView.isHidden = false
            self.showLocationView()
            self.view.setNeedsLayout()
            self.dismiss(animated: false, completion: nil)
            
        })
        ok.setAppTextColor()
    
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
           // self.alertMessageAboutWrongLocation()
        }
        cancel.setAppTextColor()
        
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    private func alertMessageAboutWrongLocation() {
        let alertView = UIAlertController(title: "", message: "I'm sorry, but the goverment of your location doesn't offer the opportunity for citizen ballot initiatives. But you can influence them with letters in our letter-writting campaign.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Got it", style: .cancel) { (_) in
            self.dismiss(animated: false, completion: nil)
        }
        action.setAppTextColor()
        
        alertView.addAction(action)
        self.present(alertView, animated: true, completion: nil)
    }
    
    private func enableChooseLocationButton(_ isOn: Bool) {
        self.chooseLocationButton.isEnabled = isOn
        self.chooseLocationButton.alpha = isOn ? 1 : 0.5
    }
    
    // MARK:- Keyboard Delegate methods
    @objc func keyboardWillHide(aNotification: NSNotification) {
        let size = UIScreen.main.bounds.size
        UIView.animate(withDuration: 1.0) {
            self.view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }
    }
    
    @objc func keyboardWillShow(aNotification: NSNotification) {
        guard let keyboardHeight = (aNotification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height else {
            return
        }
        let size = UIScreen.main.bounds.size
        UIView.animate(withDuration: 1.0) {
            self.view.frame = CGRect(x: 0, y: -keyboardHeight, width: size.width, height: size.height)
        }
    }
    
    @objc func keyboardDidShow(aNotification: NSNotification) {
        guard let keyboardHeight = (aNotification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height else {
            return
        }
        let size = UIScreen.main.bounds.size
        UIView.animate(withDuration: 1.0) {
            self.view.frame = CGRect(x: 0, y: -keyboardHeight, width: size.width, height: size.height)
        }
    }
}

// MARK: - UIPickerViewDataSource
extension SignUpUpdateViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return campaignLocations.count
    }
}

// MARK: - UIPickerViewDelegate
extension SignUpUpdateViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: campaignLocations[row].location, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        return attributedString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setCampaignLiveDescription(row)
        //enableChooseLocationButton(true)
    }
    
}
