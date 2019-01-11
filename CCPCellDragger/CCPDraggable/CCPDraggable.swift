//
//  CCPDraggable.swift
//  CCPDraggableTable
//
//  Created by 储诚鹏 on 2019/1/10.
//  Copyright © 2019 储诚鹏. All rights reserved.
//

import UIKit

public struct ChangeIndexPath {
    let old: IndexPath
    let new: IndexPath
}

public typealias DataHandler = ([Any]) -> ()

enum EffectType {
    case hover
    case translucency
}

public final class CCPDragger {
    fileprivate let base: UITableView
    init(_ base: UITableView) {
        self.base = base
    }
}

protocol CCPDraggable {
    associatedtype CCPDraggableType
    var ccp: CCPDraggableType { get }
}

extension CCPDraggable where Self: UITableView {
    var ccp: CCPDragger {
        return CCPDragger(self)
    }
}

extension CCPDragger {
    func enable(effectType: EffectType, datas: [Any], dataHandler: @escaping DataHandler) {
        if base.dragger != nil { return }
        base.dragger = Dragger(draggableView: base, effectType: effectType, data: datas, dataHandler: dataHandler)
    }
}

let tableDraggerKey = UnsafeRawPointer(bitPattern: "ccpdraggable_tableDraggerKey".hashValue)!

extension UITableView: CCPDraggable {
    var dragger: Dragger? {
        set {
            objc_setAssociatedObject(self, tableDraggerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, tableDraggerKey) as? Dragger
        }
    }
}

extension Notification.Name {
    static let dragged = Notification.Name("CCPDragger_Dragged")
}



