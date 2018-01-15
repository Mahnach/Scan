//
//  PDFTableViewCell.swift
//  SCN
//
//  Created by BAMFAdmin on 17.12.17.
//  Copyright © 2017 BAMFAdmin. All rights reserved.
//

import UIKit

class PDFTableViewCell: UITableViewCell {

    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var documentPreview: UIImageView!
    @IBOutlet weak var createData: UILabel!
    @IBOutlet weak var pdfName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
