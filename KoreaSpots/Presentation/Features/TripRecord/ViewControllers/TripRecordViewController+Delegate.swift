//
//  TripRecordViewController+Delegate.swift
//  KoreaSpots
//
//  Created by YoungJin on 11/12/25.
//

// 역할: 컬렉션뷰 스와이프 삭제, 연/월 테이블뷰 DataSource·Delegate
// 의존: TripRecordView(calendarView, listView)
// 사용처: TripRecordViewController

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

// MARK: - UICollectionViewDelegate

extension TripRecordViewController: UICollectionViewDelegate {
    // Trailing swipe actions (left swipe)
    func collectionView(
        _ collectionView: UICollectionView,
        trailingSwipeActionsConfigurationForItemAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard collectionView == tripRecordView.listView.collectionView,
              let trip = listDataSource?.itemIdentifier(for: indexPath) else {
            return nil
        }

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "삭제"
        ) { [weak self] _, _, completion in
            self?.showDeleteConfirmation(for: trip)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false

        return configuration
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate (Year TableViews)

extension TripRecordViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Both year table views use availableYears
        if tableView == tripRecordView.yearTableView || tableView == tripRecordView.calendarView.yearTableView {
            return availableYears.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // List filter year table view
        if tableView == tripRecordView.yearTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "YearCell", for: indexPath)
            let year = availableYears[indexPath.row]

            cell.textLabel?.text = "\(year)년"
            cell.textLabel?.font = FontManager.body
            cell.textLabel?.textAlignment = .center
            cell.backgroundColor = .white
            cell.selectionStyle = .default

            // 현재 선택된 년도 표시
            if year == tripRecordView.selectedYear {
                cell.backgroundColor = UIColor.primary.withAlphaComponent(0.1)
                cell.textLabel?.textColor = .primary
                cell.textLabel?.font = FontManager.bodyBold
            } else {
                cell.textLabel?.textColor = .label
            }

            return cell
        }

        // Calendar year table view
        if tableView == tripRecordView.calendarView.yearTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "YearCell", for: indexPath)
            let year = availableYears[indexPath.row]

            cell.textLabel?.text = "\(year)년"
            cell.textLabel?.font = FontManager.body
            cell.textLabel?.textAlignment = .center
            cell.backgroundColor = .white
            cell.selectionStyle = .default

            // 현재 선택된 년도 표시
            let currentYear = Calendar.current.component(.year, from: tripRecordView.calendarView.currentMonth)
            if year == currentYear {
                cell.backgroundColor = UIColor.primary.withAlphaComponent(0.1)
                cell.textLabel?.textColor = .primary
                cell.textLabel?.font = FontManager.bodyBold
            } else {
                cell.textLabel?.textColor = .label
            }

            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // List filter year selection
        if tableView == tripRecordView.yearTableView {
            let selectedYear = availableYears[indexPath.row]
            tripRecordView.hideYearDropdown()
            reactor?.action.onNext(.selectFilterYear(selectedYear))
        }

        // Calendar year selection
        if tableView == tripRecordView.calendarView.yearTableView {
            let selectedYear = availableYears[indexPath.row]
            let calendar = Calendar.current
            let currentMonth = calendar.component(.month, from: tripRecordView.calendarView.currentMonth)

            var components = DateComponents()
            components.year = selectedYear
            components.month = currentMonth
            components.day = 1

            if let selectedDate = calendar.date(from: components) {
                tripRecordView.calendarView.moveCalendar(to: selectedDate)
                reactor?.action.onNext(.selectMonth(selectedDate))
                tripRecordView.calendarView.hideYearDropdown()
                tripRecordView.calendarView.yearTableView.reloadData()
            }
        }
    }
}
