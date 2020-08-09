//
//  ViewController.swift
//  AnimateTableViewHeader
//
//  Created by Thanh Nguyen Xuan on 8/9/20.
//  Copyright © 2020 Thanh Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var searchTextFieldTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var chatButton: UIButton!
    @IBOutlet private weak var headerHeightConstraint: NSLayoutConstraint!

    // MARK: Properties
    private let maxHeaderHeight: CGFloat = 88.0
    private let minHeaderHeight: CGFloat = 44.0
    private var previousScrollOffset: CGFloat = 0.0

    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        headerHeightConstraint.constant = maxHeaderHeight
        self.updateHeader()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: Methods

    private func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
        // Calculate height của scroll view khi header view bị collapse đến min height
        let scrollViewMaxHeight = scrollView.frame.height + headerHeightConstraint.constant - minHeaderHeight
        // Đảm bảo khi header bị collapse đến min height thì scroll view vẫn scroll được
        return scrollView.contentSize.height > scrollViewMaxHeight
    }

    private func setScrollPosition(_ position: CGFloat) {
        tableView.contentOffset = CGPoint(x: tableView.contentOffset.x, y: position)
    }

    private func scrollViewDidStopScrolling() {
        let range = maxHeaderHeight - minHeaderHeight
        let midPoint = minHeaderHeight + range / 2

        if headerHeightConstraint.constant > midPoint {
            // Expand header
            expandHeader()
        } else {
            // Collapse header
            collapseHeader()
        }
    }

    private func collapseHeader() {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = self.minHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }

    private func expandHeader() {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = self.maxHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }

    private func updateHeader() {
        // Tính khoảng cách giữa 2 value max và min height
        let range = maxHeaderHeight - minHeaderHeight
        // Tính khoảng offset hiện tại với min height
        let openAmount = headerHeightConstraint.constant - minHeaderHeight
        // Tính tỉ lệ phần trăm để animate, thay đổi UI element
        let percentage = openAmount / range
        // Tính constant của trailing constraint cần thay đổi
        let trailingRange = view.frame.width - chatButton.frame.minX

        // Animate UI theo tỉ lệ tính được
        searchTextFieldTrailingConstraint.constant = trailingRange * (1.0 - percentage) + 8
        logoImageView.alpha = percentage
    }
}

// MARK: UITableViewDataSource methods
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        cell.textLabel?.text = "This is cell \(indexPath.row)"
        return cell
    }
}

// MARK: UITableViewDataSource methods
extension ViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y - previousScrollOffset

        // Điểm giới hạn trên cùng của scroll view
        let absoluteTop: CGFloat = 0.0
        // Điểm giới hạn dưới cùng của scroll view
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height

        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom

        guard canAnimateHeader(scrollView) else {
            return
        }

        // Implement logic để animate header
        var newHeight = headerHeightConstraint.constant
        if isScrollingDown {
            newHeight = max(minHeaderHeight, headerHeightConstraint.constant - abs(scrollDiff))
        } else if isScrollingUp {
            newHeight = min(maxHeaderHeight, headerHeightConstraint.constant + abs(scrollDiff))
        }

        if newHeight != self.headerHeightConstraint.constant {
            headerHeightConstraint.constant = newHeight
            updateHeader()
            setScrollPosition(previousScrollOffset)
        }

        previousScrollOffset = scrollView.contentOffset.y
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Kết thúc scroll
        scrollViewDidStopScrolling()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // Kết thúc scroll
            scrollViewDidStopScrolling()
        }
    }
}

