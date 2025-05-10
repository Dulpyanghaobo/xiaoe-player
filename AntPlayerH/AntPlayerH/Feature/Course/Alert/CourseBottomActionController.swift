//
//  CourseBottomActionController.swift
//  AntPlayerH
//
//  Created by i564407 on 7/20/24.
//

import Foundation
import XLActionController

class CourseBottomActionController: ActionController<CourseBottomCell, SimpleCourseModel, CourseBottomHeaderView, String, CourseBottomHeaderView, String>
{
    
    
    public override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // customizing behavior and present/dismiss animations
        settings.behavior.hideOnScrollDown = false
        settings.animation.scale = nil
        settings.animation.present.duration = 0.6
        settings.animation.dismiss.duration = 0.5
        settings.animation.dismiss.options = .curveEaseIn
        settings.animation.dismiss.offset = 30
        settings.cancelView.showCancel = false
        // providing a specific collection view cell which will be used to display each action, height parameter expects a block that returns the cell height for a particular action.
        cellSpec = .cellClass(height: { _ in 60 })
        // providing a specific view that will render each section header.
        sectionHeaderSpec = .cellClass(height: {
            _ in 44 })
        headerSpec = .cellClass(height: { _ in
            44
        })
        // providing a specific view that will render the action sheet header. We calculate its height according the text that should be displayed.
        headerSpec = .cellClass(height: { [weak self] (headerData: String) in
            guard let me = self else { return 0 }
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: me.view.frame.width - 40, height: CGFloat.greatestFiniteMagnitude))
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 17.0)
            label.text = headerData
            label.sizeToFit()
            return label.frame.size.height + 20
        })

        
        // once we specify the views, we have to provide three blocks that will be used to set up these views.
        // block used to setup the header. Header view and the header are passed as block parameters
        onConfigureHeader = { [weak self] header, headerData in
            guard let me = self else { return }
            header.configLabel(title: "headerData")
        }
        // block used to setup the section header
        onConfigureSectionHeader = { sectionHeader, sectionHeaderData in
            sectionHeader.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            sectionHeader.configLabel(title: "demo")
        }
        // block used to setup the collection view cell
        onConfigureCellForAction = { [weak self] cell, action, indexPath in
            cell.configure(simpleCourseModel: action.data ?? SimpleCourseModel.init(title: "", desc: "", imageName: ""))
        }
        onConfigureHeader = {header, headerData in
            header.configLabel(title: "demo")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
