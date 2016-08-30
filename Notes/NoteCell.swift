//
//  NoteCell.swift
//  Notes
//
//  Created by Pallav Trivedi on 23/08/16.
//  Copyright © 2016 CodeIt. All rights reserved.
//

import UIKit

protocol NoteCellDelegate:class
{
    func didClickOnDeletebutton(tag:Int)
}

class NoteCell: UICollectionViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    weak var delegate:NoteCellDelegate?
    
    @IBAction func didClickOnDeleteButton(sender: AnyObject)
    {
        delegate?.didClickOnDeletebutton(self.tag)
    }

}
