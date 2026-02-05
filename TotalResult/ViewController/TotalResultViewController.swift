//
//  TotalResultViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//

import Foundation
import UIKit
import SnapKit

final class TotalResultViewController: UIViewController {

    private let result: Result

    private enum Row: Int, CaseIterable {
        case amountPerPerson
        case totalBill
        case totalTip
        case bill
        case tip
        case split

        var title: String {
            switch self {
            case .amountPerPerson: return "每人金額"
            case .totalBill:       return "總金額（含小費）"
            case .totalTip:        return "小費總額"
            case .bill:            return "原始帳單金額"
            case .tip:             return "小費設定"
            case .split:           return "分攤人數"
            }
        }

        func value(from result: Result) -> String {
            switch self {
            case .amountPerPerson:
                return result.amountPerPerson.currencyFormatted
            case .totalBill:
                return result.totalBill.currencyFormatted
            case .totalTip:
                return result.totalTip.currencyFormatted
            case .bill:
                return result.bill.currencyFormatted
            case .tip:
                return result.tip.stringValue.isEmpty ? "無" : result.tip.stringValue
            case .split:
                return "\(result.split)"
            }
        }
    }

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .clear
        table.register(AmountPerPersonCell.self, forCellReuseIdentifier: AmountPerPersonCell.reuseId)
        table.register(TotalBillCell.self, forCellReuseIdentifier: TotalBillCell.reuseId)
        table.register(TotalTipCell.self, forCellReuseIdentifier: TotalTipCell.reuseId)
        table.register(BillCell.self, forCellReuseIdentifier: BillCell.reuseId)
        table.register(TipCell.self, forCellReuseIdentifier: TipCell.reuseId)
        table.register(SplitCell.self, forCellReuseIdentifier: SplitCell.reuseId)
        table.showsVerticalScrollIndicator = false
        return table
    }()

    init(result: Result) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Total Result"
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension TotalResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = Row(rawValue: indexPath.row) else { return UITableViewCell() }

        switch row {
        case .amountPerPerson:
            let cell = tableView.dequeueReusableCell(withIdentifier: AmountPerPersonCell.reuseId, for: indexPath) as! AmountPerPersonCell
            cell.configure(with: result)
            return cell
        case .totalBill:
            let cell = tableView.dequeueReusableCell(withIdentifier: TotalBillCell.reuseId, for: indexPath) as! TotalBillCell
            cell.configure(with: result)
            return cell
        case .totalTip:
            let cell = tableView.dequeueReusableCell(withIdentifier: TotalTipCell.reuseId, for: indexPath) as! TotalTipCell
            cell.configure(with: result)
            return cell
        case .bill:
            let cell = tableView.dequeueReusableCell(withIdentifier: BillCell.reuseId, for: indexPath) as! BillCell
            cell.configure(with: result)
            return cell
        case .tip:
            let cell = tableView.dequeueReusableCell(withIdentifier: TipCell.reuseId, for: indexPath) as! TipCell
            cell.configure(with: result)
            return cell
        case .split:
            let cell = tableView.dequeueReusableCell(withIdentifier: SplitCell.reuseId, for: indexPath) as! SplitCell
            cell.configure(with: result)
            return cell
        }
    }
}

extension TotalResultViewController: UITableViewDelegate {}

// MARK: - Cells

final class AmountPerPersonCell: UITableViewCell {
    static let reuseId = "AmountPerPersonCell"

    func configure(with result: Result) {
        var content = defaultContentConfiguration()
        content.text = "每人金額"
        content.textProperties.font = ThemeFont.demiBold(Ofsize: 18)
        content.secondaryText = result.amountPerPerson.currencyFormatted
        content.secondaryTextProperties.font = ThemeFont.bold(Ofsize: 28)
        content.secondaryTextProperties.color = ThemeColor.primary
        contentConfiguration = content
        selectionStyle = .none
    }
}

final class TotalBillCell: UITableViewCell {
    static let reuseId = "TotalBillCell"

    func configure(with result: Result) {
        var content = defaultContentConfiguration()
        content.text = "總金額（含小費）"
        content.textProperties.font = ThemeFont.regular(Ofsize: 16)
        content.secondaryText = result.totalBill.currencyFormatted
        content.secondaryTextProperties.font = ThemeFont.demiBold(Ofsize: 18)
        contentConfiguration = content
        selectionStyle = .none
    }
}

final class TotalTipCell: UITableViewCell {
    static let reuseId = "TotalTipCell"

    func configure(with result: Result) {
        var content = defaultContentConfiguration()
        content.text = "小費總額"
        content.textProperties.font = ThemeFont.regular(Ofsize: 16)
        content.secondaryText = result.totalTip.currencyFormatted
        content.secondaryTextProperties.font = ThemeFont.demiBold(Ofsize: 18)
        contentConfiguration = content
        selectionStyle = .none
    }
}

final class BillCell: UITableViewCell {
    static let reuseId = "BillCell"

    func configure(with result: Result) {
        var content = defaultContentConfiguration()
        content.text = "原始帳單金額"
        content.textProperties.font = ThemeFont.regular(Ofsize: 16)
        content.secondaryText = result.bill.currencyFormatted
        content.secondaryTextProperties.font = ThemeFont.regular(Ofsize: 16)
        contentConfiguration = content
        selectionStyle = .none
    }
}

final class TipCell: UITableViewCell {
    static let reuseId = "TipCell"

    func configure(with result: Result) {
        var content = defaultContentConfiguration()
        content.text = "小費設定"
        content.textProperties.font = ThemeFont.regular(Ofsize: 16)
        let text = result.tip.stringValue.isEmpty ? "無" : result.tip.stringValue
        content.secondaryText = text
        content.secondaryTextProperties.font = ThemeFont.demiBold(Ofsize: 16)
        content.secondaryTextProperties.color = ThemeColor.secondary
        contentConfiguration = content
        selectionStyle = .none
    }
}

final class SplitCell: UITableViewCell {
    static let reuseId = "SplitCell"

    func configure(with result: Result) {
        var content = defaultContentConfiguration()
        content.text = "分攤人數"
        content.textProperties.font = ThemeFont.regular(Ofsize: 16)
        content.secondaryText = "\(result.split) 人"
        content.secondaryTextProperties.font = ThemeFont.demiBold(Ofsize: 18)
        contentConfiguration = content
        selectionStyle = .none
    }
}
