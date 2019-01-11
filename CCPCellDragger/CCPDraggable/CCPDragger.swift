//
//  CCPDragger.swift
//  CCPDraggableTable
//
//  Created by 储诚鹏 on 2019/1/10.
//  Copyright © 2019 储诚鹏. All rights reserved.
//

import UIKit

final class Dragger {
    
    private let draggingView = UIImageView()
    private let draggableView: UITableView
    private let effectType: EffectType
    private var data: [Any]
    
    private var displayLink: CADisplayLink?
    private var scrollSpeed: CGFloat = 0
    private var currentIndexPath: IndexPath?
    private var gesture: UILongPressGestureRecognizer?
    private var dataHandler: DataHandler?
    
    init(draggableView: UITableView, effectType: EffectType,  data: [Any], dataHandler: @escaping DataHandler) {
        self.draggableView = draggableView
        self.effectType = effectType
        self.dataHandler = dataHandler
        self.data = data
        setGesture()
    }
    
    private func setGesture() {
        let lp = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        self.gesture = lp
        draggableView.addGestureRecognizer(lp)
    }
    
    @objc private func longPress(_ lp: UILongPressGestureRecognizer) {
        let point = lp.location(in: draggableView)
        switch lp.state {
        case .began:
            willDrag(at: point)
        case .changed:()
            dragging(to: point)
        case .ended:()
            didDragged(to: point)
        default:()
        }
    }
    
    private func willDrag(at point: CGPoint) {
        guard let touchedIndexPath = draggableView.indexPathForRow(at: point) else { return }
        guard let touchedCell = draggableView.cellForRow(at: touchedIndexPath) else { return }
        currentIndexPath = touchedIndexPath
        draggableView.allowsSelection = false
        touchedCell.isHighlighted = false
        setDraggingView(createDraggingImage(in: touchedCell))
        draggingView.bounds.size = touchedCell.bounds.size
        draggingView.center = touchedCell.center
        willDragAnimation(point.y)
    }
    
    private func dragging(to point: CGPoint) {
        dragingViewMove(to: point.y)
        guard draggableView.contentSize.height > draggableView.bounds.height else { return }
        setScrollSpeed()
        displayLink?.isPaused = scrollSpeed == 0
    }
    
    private func didDragged(to point: CGPoint) {
        draggableView.allowsSelection = true
        displayLink?.isPaused = true
        dataHandler?(data)
        didDraggedAnimation()
    }
    
    private func didDraggedAnimation() {
        UIView.animate(withDuration: 0.2, animations: {
            self.effect(isBeigin: false)
            self.setDidDraggedDraggingViewFrame()
        }) { (_) in
            self.didDraggedAnimationCompletion()
        }
    }
    
    private func didDraggedAnimationCompletion() {
        draggingView.layer.shadowOpacity = 0
        NotificationCenter.default.post(name: .dragged, object: nil)
        UIView.animate(withDuration: 0.1, animations: {
            self.draggableView.reloadData()
            self.draggableView.layer.add(CATransition(), forKey: "reload")
        }) { _ in
            self.draggingView.removeFromSuperview()
        }
    }
    
    private func setDidDraggedDraggingViewFrame() {
        draggingView.frame = draggableView.rectForRow(at: currentIndexPath!)
    }
    
    private func setScrollSpeed() {
        scrollSpeed = 0
        let halfCellHeight = draggingView.bounds.height / 2
        let cellCenterY = draggingView.center.y - draggingView.bounds.minY
        if cellCenterY < halfCellHeight {
            scrollSpeed = 5 * ( cellCenterY / halfCellHeight - 1.1)
        }
        else if cellCenterY > draggableView.bounds.height - halfCellHeight  {
            scrollSpeed = 5 * ((cellCenterY - draggableView.bounds.height) / halfCellHeight + 1.1)
        }
    }
    
    private func createDraggingImage(in cell: UITableViewCell) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(cell.contentView.bounds.size, true, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        cell.layer.render(in: ctx)
        defer {
            UIGraphicsEndImageContext()
        }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    private func setDraggingView(_ image: UIImage?) {
        draggingView.image = image
        draggableView.addSubview(draggingView)
        setDraggingViewShadow()
    }
    
    private func setDraggingViewShadow() {
        draggingView.layer.shadowRadius = 4.0
        draggingView.layer.shadowOpacity = 0.25
        draggingView.layer.shadowColor = UIColor.red.cgColor
        draggingView.layer.shadowOffset = .zero
    }
    
    private func willDragAnimation(_ draggingY: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.effect(isBeigin: true)
            self.dragingViewMove(to: draggingY)
        }
    }
    
    private func effect(isBeigin: Bool) {
        if effectType == .hover {
            hoverEffect(isBeigin)
        }
        else {
            translucencyEffect(isBeigin)
        }
    }
    
    private func hoverEffect(_ isBegin: Bool) {
        draggingView.transform = isBegin ? CGAffineTransform(scaleX: 1.05, y: 1.065) : .identity
    }
    
    private func translucencyEffect(_ isBegin: Bool) {
        draggingView.alpha = isBegin ? 0.5 : 1.0
    }
    
    private func dragingViewMove(to y: CGFloat) {
        draggingView.center.y = min(max(y, draggableView.bounds.minY), draggableView.bounds.minY + draggableView.bounds.height)
        moveDummyRowIfNeed()
    }
    
    private func moveDummyRowIfNeed() {
        guard let newIndexPath = draggableView.indexPathForRow(at: draggingView.center) else { return }
        if newIndexPath == currentIndexPath! { return }
        let old = currentIndexPath!
        currentIndexPath = newIndexPath
        removeData(at: old)
        moveCell(old)
    }
    
    private func moveCell(_ old: IndexPath) {
        draggableView.beginUpdates()
        draggableView.deleteRows(at: [old], with: .top)
        draggableView.insertRows(at: [currentIndexPath!], with: .top)
        draggableView.endUpdates()
    }
    
    private func removeData(at indexPath: IndexPath) {
        data.insert(data.remove(at: indexPath.row), at: currentIndexPath!.row)
    }
    
    deinit {
        displayLink?.invalidate()
    }
}
