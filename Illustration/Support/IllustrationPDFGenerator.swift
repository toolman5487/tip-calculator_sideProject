//
//  IllustrationPDFGenerator.swift
//  tip-calculator
//

import UIKit

enum IllustrationPDFGenerator {

    private static let pageWidth: CGFloat = 595.2
    private static let pageHeight: CGFloat = 841.8
    private static let margin: CGFloat = 40
    private static let contentWidth: CGFloat = pageWidth - margin * 2
    private static let sectionSpacing: CGFloat = 28
    private static let cardCornerRadius: CGFloat = 10
    private static let barChartHeight: CGFloat = 120
    private static let tableRowHeight: CGFloat = 26
    private static let footerHeight: CGFloat = 40
    private static let maxContentY: CGFloat = pageHeight - margin - footerHeight

    private static let titleFont = UIFont.boldSystemFont(ofSize: 24)
    private static let sectionFont = UIFont.boldSystemFont(ofSize: 16)
    private static let bodyFont = UIFont.systemFont(ofSize: 14)
    private static let captionFont = UIFont.systemFont(ofSize: 12)
    private static let kpiTitleFont = UIFont.systemFont(ofSize: 12, weight: .medium)
    private static let kpiValueFont = UIFont.boldSystemFont(ofSize: 18)

    static func generate(
        kpiCardItems: [KPICardItem],
        timeChartData: [TrendChartItem],
        locationStats: [LocationStatItem],
        selectedTimeFilter: IllustrationTimeFilterOption
    ) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let trendColor = trendColor(for: kpiCardItems.first { $0.title == "個人消費總和" }?.trend)

        return renderer.pdfData { pdfCtx in
            let pageCtx = PageContext(
                pdfContext: pdfCtx,
                selectedTimeFilter: selectedTimeFilter,
                maxContentY: maxContentY,
                footerY: pageHeight - margin - 24,
                margin: margin
            )
            pdfCtx.beginPage()

            var y = margin
            y = drawHeader(ctx: pdfCtx.cgContext, selectedTimeFilter: selectedTimeFilter, startY: y)
            y += sectionSpacing

            y = drawKPICards(ctx: pdfCtx.cgContext, items: kpiCardItems, startY: y)
            y += sectionSpacing

            y = drawTimeChartSection(pageCtx: pageCtx, data: timeChartData, barColor: trendColor, startY: y)
            y += sectionSpacing

            y = drawLocationSection(pageCtx: pageCtx, items: Array(locationStats.prefix(15)), startY: y)

            drawFooter(ctx: pdfCtx.cgContext, y: pageHeight - margin - 24, pageNum: pageCtx.pageNumber)
        }
    }

    // MARK: - Pagination

    fileprivate static func drawFooter(ctx: CGContext, y: CGFloat, pageNum: Int = 1) {
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let dateStr = "產生時間：\(formatter.string(from: Date()))"
        let attr: [NSAttributedString.Key: Any] = [
            .font: captionFont,
            .foregroundColor: UIColor(white: 0.6, alpha: 1)
        ]
        dateStr.draw(at: CGPoint(x: margin, y: y), withAttributes: attr)
        if pageNum > 1 {
            let pageStr = "第 \(pageNum) 頁"
            let pageAttr: [NSAttributedString.Key: Any] = [
                .font: captionFont,
                .foregroundColor: UIColor(white: 0.6, alpha: 1)
            ]
            let pageW = pageStr.size(withAttributes: pageAttr).width
            pageStr.draw(at: CGPoint(x: pageWidth - margin - pageW, y: y), withAttributes: pageAttr)
        }
    }

    fileprivate static func drawContinuationHeader(ctx: CGContext, selectedTimeFilter: IllustrationTimeFilterOption, startY: CGFloat) -> CGFloat {
        let attr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor(white: 0.5, alpha: 1)
        ]
        "統計報表（續） · \(selectedTimeFilter.title)".draw(at: CGPoint(x: margin, y: startY), withAttributes: attr)
        return startY + 28
    }

    // MARK: - Header

    private static func drawHeader(ctx: CGContext, selectedTimeFilter: IllustrationTimeFilterOption, startY: CGFloat) -> CGFloat {
        let headerBg = UIColor(white: 0.96, alpha: 1)
        let headerRect = CGRect(x: 0, y: 0, width: pageWidth, height: startY + 52)
        ctx.setFillColor(headerBg.cgColor)
        ctx.fill(headerRect)

        var y = startY + 16

        let titleAttr: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor(white: 0.15, alpha: 1)
        ]
        "統計報表".draw(at: CGPoint(x: margin, y: y), withAttributes: titleAttr)
        y += 28

        let badgeAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: ThemeColor.selected
        ]
        selectedTimeFilter.title.draw(at: CGPoint(x: margin, y: y), withAttributes: badgeAttr)

        return startY + 52
    }

    // MARK: - KPI Cards

    private static func drawKPICards(ctx: CGContext, items: [KPICardItem], startY: CGFloat) -> CGFloat {
        let cardCount = min(3, items.count)
        guard cardCount > 0 else { return startY }

        let gap: CGFloat = 12
        let cardWidth = (contentWidth - gap * CGFloat(cardCount - 1)) / CGFloat(cardCount)
        let cardHeight: CGFloat = 70
        let y = startY

        for i in 0..<cardCount {
            let item = items[i]
            let x = margin + CGFloat(i) * (cardWidth + gap)
            let rect = CGRect(x: x, y: y, width: cardWidth, height: cardHeight)

            let path = UIBezierPath(roundedRect: rect, cornerRadius: cardCornerRadius)
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()

            ctx.setStrokeColor(UIColor(white: 0.88, alpha: 1).cgColor)
            ctx.setLineWidth(1)
            ctx.addPath(path.cgPath)
            ctx.strokePath()

            let pad: CGFloat = 12
            var cardY = y + pad

            let titleAttr: [NSAttributedString.Key: Any] = [
                .font: kpiTitleFont,
                .foregroundColor: UIColor(white: 0.45, alpha: 1)
            ]
            let titleSize = item.title.size(withAttributes: titleAttr)
            item.title.draw(in: CGRect(x: x + pad, y: cardY, width: cardWidth - pad * 2, height: titleSize.height), withAttributes: titleAttr)
            cardY += titleSize.height + 6

            var valueText = item.actualValue
            if let trend = item.trend {
                valueText += " \(trendSymbol(trend))"
            }
            let trendColor = trendColor(for: item.trend)
            let valueAttr: [NSAttributedString.Key: Any] = [
                .font: kpiValueFont,
                .foregroundColor: trendColor
            ]
            valueText.draw(in: CGRect(x: x + pad, y: cardY, width: cardWidth - pad * 2, height: 24), withAttributes: valueAttr)
        }

        return y + cardHeight
    }

    // MARK: - Time Chart Section (Bar Chart + Table)

    private static func drawTimeChartSection(pageCtx: PageContext, data: [TrendChartItem], barColor: UIColor, startY: CGFloat) -> CGFloat {
        let ctx = pageCtx.pdfContext.cgContext
        var y = startY

        let sectionAttr: [NSAttributedString.Key: Any] = [
            .font: sectionFont,
            .foregroundColor: UIColor(white: 0.2, alpha: 1)
        ]
        "消費趨勢".draw(at: CGPoint(x: margin, y: y), withAttributes: sectionAttr)
        y += 24

        let hasChartData = !data.isEmpty && data.contains { $0.totalAmount > 0 }
        if hasChartData {
            pageCtx.ensureSpace(y: &y, height: barChartHeight + 28)
            let maxAmount = max(1, data.map(\.totalAmount).max() ?? 1)
            let barCount = data.count
            let barGap: CGFloat = barCount > 1 ? 6 : 0
            let barWidth = barCount > 0 ? (contentWidth - CGFloat(barCount - 1) * barGap) / CGFloat(barCount) : 20
            let maxBarHeight: CGFloat = 80

            for (i, item) in data.enumerated() {
                let ratio = CGFloat(item.totalAmount / maxAmount)
                let barHeight = max(4, maxBarHeight * ratio)
                let barX = margin + CGFloat(i) * (barWidth + barGap)
                let barY = y + barChartHeight - 20 - barHeight

                let barRect = CGRect(x: barX, y: barY, width: barWidth, height: barHeight)
                let path = UIBezierPath(roundedRect: barRect, cornerRadius: 4)
                ctx.setFillColor(barColor.cgColor)
                ctx.addPath(path.cgPath)
                ctx.fillPath()

                let labelAttr: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor(white: 0.5, alpha: 1)
                ]
                let truncated = String(item.label.prefix(8))
                let labelW = truncated.size(withAttributes: labelAttr).width
                truncated.draw(at: CGPoint(x: barX + (barWidth - labelW) / 2, y: y + barChartHeight - 16), withAttributes: labelAttr)
            }
            y += barChartHeight + 28
        }

        let col1W = contentWidth * 0.5
        let col2W = contentWidth - col1W
        let headerBg = UIColor(white: 0.94, alpha: 1)
        let headerAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: UIColor(white: 0.35, alpha: 1)
        ]
        let cellAttr: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: UIColor(white: 0.25, alpha: 1)
        ]

        pageCtx.ensureSpace(y: &y, height: tableRowHeight)
        ctx.setFillColor(headerBg.cgColor)
        ctx.fill(CGRect(x: margin, y: y, width: col1W, height: tableRowHeight))
        ctx.fill(CGRect(x: margin + col1W, y: y, width: col2W, height: tableRowHeight))
        "期間".draw(in: CGRect(x: margin + 10, y: y + 6, width: col1W - 20, height: tableRowHeight - 12), withAttributes: headerAttr)
        "金額".draw(in: CGRect(x: margin + col1W + 10, y: y + 6, width: col2W - 20, height: tableRowHeight - 12), withAttributes: headerAttr)
        y += tableRowHeight

        for (i, item) in data.enumerated() {
            let didBreak = pageCtx.ensureSpace(y: &y, height: tableRowHeight)
            if didBreak {
                ctx.setFillColor(headerBg.cgColor)
                ctx.fill(CGRect(x: margin, y: y, width: col1W, height: tableRowHeight))
                ctx.fill(CGRect(x: margin + col1W, y: y, width: col2W, height: tableRowHeight))
                "期間".draw(in: CGRect(x: margin + 10, y: y + 6, width: col1W - 20, height: tableRowHeight - 12), withAttributes: headerAttr)
                "金額".draw(in: CGRect(x: margin + col1W + 10, y: y + 6, width: col2W - 20, height: tableRowHeight - 12), withAttributes: headerAttr)
                y += tableRowHeight
            }
            if i % 2 == 1 {
                ctx.setFillColor(UIColor(white: 0.98, alpha: 1).cgColor)
                ctx.fill(CGRect(x: margin, y: y, width: contentWidth, height: tableRowHeight))
            }
            item.label.draw(in: CGRect(x: margin + 10, y: y + 6, width: col1W - 20, height: tableRowHeight - 12), withAttributes: cellAttr)
            item.totalAmount.currencyAbbreviatedFormatted.draw(in: CGRect(x: margin + col1W + 10, y: y + 6, width: col2W - 20, height: tableRowHeight - 12), withAttributes: cellAttr)
            y += tableRowHeight
        }
        return y
    }

    // MARK: - Location Section

    private static func drawLocationSection(pageCtx: PageContext, items: [LocationStatItem], startY: CGFloat) -> CGFloat {
        let ctx = pageCtx.pdfContext.cgContext
        var y = startY

        let sectionAttr: [NSAttributedString.Key: Any] = [
            .font: sectionFont,
            .foregroundColor: UIColor(white: 0.2, alpha: 1)
        ]
        "消費地區".draw(at: CGPoint(x: margin, y: y), withAttributes: sectionAttr)
        y += 24

        let col1W = contentWidth * 0.65
        let col2W = contentWidth - col1W
        let headerBg = UIColor(white: 0.94, alpha: 1)
        let headerAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: UIColor(white: 0.35, alpha: 1)
        ]
        let cellAttr: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: UIColor(white: 0.25, alpha: 1)
        ]

        pageCtx.ensureSpace(y: &y, height: tableRowHeight)
        ctx.setFillColor(headerBg.cgColor)
        ctx.fill(CGRect(x: margin, y: y, width: col1W, height: tableRowHeight))
        ctx.fill(CGRect(x: margin + col1W, y: y, width: col2W, height: tableRowHeight))
        "地區".draw(in: CGRect(x: margin + 10, y: y + 6, width: col1W - 20, height: tableRowHeight - 12), withAttributes: headerAttr)
        "筆數".draw(in: CGRect(x: margin + col1W + 10, y: y + 6, width: col2W - 20, height: tableRowHeight - 12), withAttributes: headerAttr)
        y += tableRowHeight

        for (i, item) in items.enumerated() {
            let didBreak = pageCtx.ensureSpace(y: &y, height: tableRowHeight)
            if didBreak {
                ctx.setFillColor(headerBg.cgColor)
                ctx.fill(CGRect(x: margin, y: y, width: col1W, height: tableRowHeight))
                ctx.fill(CGRect(x: margin + col1W, y: y, width: col2W, height: tableRowHeight))
                "地區".draw(in: CGRect(x: margin + 10, y: y + 6, width: col1W - 20, height: tableRowHeight - 12), withAttributes: headerAttr)
                "筆數".draw(in: CGRect(x: margin + col1W + 10, y: y + 6, width: col2W - 20, height: tableRowHeight - 12), withAttributes: headerAttr)
                y += tableRowHeight
            }
            if i % 2 == 1 {
                ctx.setFillColor(UIColor(white: 0.98, alpha: 1).cgColor)
                ctx.fill(CGRect(x: margin, y: y, width: contentWidth, height: tableRowHeight))
            }
            item.name.draw(in: CGRect(x: margin + 10, y: y + 6, width: col1W - 20, height: tableRowHeight - 12), withAttributes: cellAttr)
            String(item.count).draw(in: CGRect(x: margin + col1W + 10, y: y + 6, width: col2W - 20, height: tableRowHeight - 12), withAttributes: cellAttr)
            y += tableRowHeight
        }
        return y
    }

    // MARK: - Footer

    private static func drawFooter(ctx: CGContext, y: CGFloat) {
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let dateStr = "產生時間：\(formatter.string(from: Date()))"
        let attr: [NSAttributedString.Key: Any] = [
            .font: captionFont,
            .foregroundColor: UIColor(white: 0.6, alpha: 1)
        ]
        dateStr.draw(at: CGPoint(x: margin, y: y), withAttributes: attr)
    }

    // MARK: - Helpers

    private static func trendSymbol(_ trend: KPITrend) -> String {
        switch trend {
        case .up: return "↑"
        case .down: return "↓"
        case .equal: return "→"
        }
    }

    private static func trendColor(for trend: KPITrend?) -> UIColor {
        switch trend {
        case .up: return ThemeColor.trendUp
        case .down: return ThemeColor.trendDown
        case .equal, .none: return ThemeColor.trendFlat
        }
    }
}

private final class PageContext {
    let pdfContext: UIGraphicsPDFRendererContext
    let selectedTimeFilter: IllustrationTimeFilterOption
    var pageNumber: Int = 1
    let maxContentY: CGFloat
    let footerY: CGFloat
    let margin: CGFloat

    init(
        pdfContext: UIGraphicsPDFRendererContext,
        selectedTimeFilter: IllustrationTimeFilterOption,
        maxContentY: CGFloat,
        footerY: CGFloat,
        margin: CGFloat
    ) {
        self.pdfContext = pdfContext
        self.selectedTimeFilter = selectedTimeFilter
        self.maxContentY = maxContentY
        self.footerY = footerY
        self.margin = margin
    }

    @discardableResult
    func ensureSpace(y: inout CGFloat, height: CGFloat) -> Bool {
        guard y + height > maxContentY else { return false }
        IllustrationPDFGenerator.drawFooter(
            ctx: pdfContext.cgContext,
            y: footerY,
            pageNum: pageNumber
        )
        pdfContext.beginPage()
        pageNumber += 1
        y = margin
        y = IllustrationPDFGenerator.drawContinuationHeader(
            ctx: pdfContext.cgContext,
            selectedTimeFilter: selectedTimeFilter,
            startY: y
        )
        return true
    }
}
