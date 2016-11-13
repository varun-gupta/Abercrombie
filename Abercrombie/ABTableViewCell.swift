//
//  ABTableViewCell.swift
//  Abercrombie
//
//  Created by Varun Gupta on 11/11/16.
//  Copyright © 2016 Varun GuptaAbercrombie. All rights reserved.
//

import UIKit

protocol AbMainTableViewControllerDelegate: class {
    func didBtnClicked(urlStr: String?)
}

class ABTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var menBtn: UIButton!
    @IBOutlet weak var womenBtn: UIButton!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageVw: UIImageView!
    weak var delegate: AbMainTableViewControllerDelegate?

    var menBtnUrl: String?
    var womenBtnUrl: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(dataModelObj: dataModel)  {
        
        descLabel.hidden = false
        headerLabel.hidden = false
        codeLabel.hidden = false
        detailLabel.hidden = false
        menBtn.hidden = false
        womenBtn.hidden = false

        if let lblStr = dataModelObj.titleString {
            headerLabel.text = lblStr
        } else {
            headerLabel.hidden = true
        }
        if let lblStr = dataModelObj.descriptionString {
            descLabel.text = lblStr
        } else {
            descLabel.hidden = true
        }
        if let lblStr = dataModelObj.codeString {
            codeLabel.text = lblStr
        } else {
            codeLabel.hidden = true
        }
        if let lblStr = dataModelObj.detailString {
            detailLabel.attributedText = lblStr.htmlAttributedString()
            detailLabel.textAlignment = .Center
        } else {
            detailLabel.hidden = true
        }
        
        if let lblStr = dataModelObj.btn1Lbl {
            menBtn.setTitle(lblStr, forState: .Normal)
            menBtn.layer.borderWidth = 1
            menBtn.layer.borderColor = UIColor.blackColor().CGColor
            menBtn.addTarget(self, action: #selector(menBtnClicked), forControlEvents: .TouchUpInside)
            menBtnUrl = dataModelObj.btn1URL
        } else {
            menBtn.hidden = true
        }
        
        if let lblStr = dataModelObj.btn2Lbl {
            womenBtn.setTitle(lblStr, forState: .Normal)
            womenBtn.layer.borderWidth = 1
            womenBtn.layer.borderColor = UIColor.blackColor().CGColor
            womenBtn.addTarget(self, action: #selector(womenBtnClicked), forControlEvents: .TouchUpInside)
            womenBtnUrl = dataModelObj.btn2URL
        } else {
            womenBtn.hidden = true
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func menBtnClicked() {
        delegate?.didBtnClicked(menBtnUrl)
    }
    
    func womenBtnClicked() {
        delegate?.didBtnClicked(womenBtnUrl)
    }
    
}

extension String {
    func htmlAttributedString() -> NSAttributedString? {
        guard let data = self.dataUsingEncoding(NSUTF16StringEncoding, allowLossyConversion: false) else { return nil }
        guard let html = try? NSMutableAttributedString(
            data: data,
            options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil) else { return nil }
        return html
    }
}
