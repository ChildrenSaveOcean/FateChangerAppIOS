//
//  KSOBaseViewController.swift
//  KidsSaveOcean
//
//  Created by Maria Soboleva on 6/2/18.
//  Copyright © 2018 KidsSaveOcean. All rights reserved.
//

import UIKit

class KSOBaseViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var subViewsData:KSODataArray!
    var stackView:UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.backgroundGray
        
        var subViews = [KSOBaseSubView]()
        
        for subViewFields in subViewsData {
            subViews.append(createSubView(subViewFields, orientation:.vertical))
        }
        
        stackView = UIStackView(arrangedSubviews: subViews)
        
        scrollView.addSubview(stackView)
        
        stackView.axis = UILayoutConstraintAxis.vertical
        stackView.distribution = UIStackViewDistribution.fillEqually
        stackView.alignment = UIStackViewAlignment.center
        stackView.spacing = kStandardViewGap
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        stackView.backgroundColor = UIColor.blue
        stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: kStandardViewGap).isActive = true
        
        stackView.layoutIfNeeded()
        scrollView.contentInsetAdjustmentBehavior =  .always
        scrollView.contentSize = CGSize(width:scrollView.frame.width, height: stackView.frame.height + 2*kStandardViewGap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createSubView(_ subViewF:KSODataDictionary, orientation:ViewOrientation) ->(KSOBaseSubView) {
        
        let subViewData = BaseViewData(dictionary: subViewF)
        
        let subView = KSOBaseSubView(orientation)
        
        subView.image?.setImage(subViewData?.image, for: .normal)
        
        subView.titleLabel?.text = subViewData?.title
        subView.subTitleLabel.text = subViewData?.subTitle
        subView.descriptionLabel?.text = subViewData?.decription
        
        return subView
        
    }
    // TODO Delete Horizontal Bouncing
}
