//
//  Constants.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/26/25.
//

import UIKit

// MARK: - Constants
enum Constants {

    // MARK: - UI Constants
    enum UI {

        // MARK: - Corner Radius
        enum CornerRadius {
            static let xSmall: CGFloat = 4
            static let small: CGFloat = 8
            static let medium: CGFloat = 12
            static let large: CGFloat = 16
        }

        // MARK: - Shadow
        enum Shadow {
            static let opacity: Float = 0.1
            static let radius: CGFloat = 4
            static let offset = CGSize(width: 0, height: 2)
            static let color = UIColor.black.cgColor
        }

        // MARK: - Spacing
        enum Spacing {
            static let xSmall: CGFloat = 4
            static let small: CGFloat = 8
            static let medium: CGFloat = 12
            static let large: CGFloat = 16
            static let xLarge: CGFloat = 20
            static let xxLarge: CGFloat = 32
        }

        // MARK: - Icon Size
        enum IconSize {
            static let small: CGFloat = 24
            static let medium: CGFloat = 32
            static let large: CGFloat = 48
        }

        // MARK: - Collection View
        enum CollectionView {
            enum Festival {
//                static let itemWidth: CGFloat = 280
//                static let itemHeight: CGFloat = 280
                static let defaultPlaceholderHeight: CGFloat = 100
            }

            enum Place {
                static let itemWidth: CGFloat = 160
                static let itemHeight: CGFloat = 200
                static let imageHeight: CGFloat = 100
            }

            enum Category {
                static let itemHeight: CGFloat = 80
                static let containerHeight: CGFloat = 256
                static let columnsCount = 4
                static let rowsCount = 2
                static let itemWidthFraction: CGFloat = 1.0/4.0
            }

            enum Theme {
                static let itemWidth: CGFloat = 70
                static let itemHeight: CGFloat = 90
                static let imageSize: CGFloat = 50
                static let spacing: CGFloat = 12
            }

            enum Header {
                static let height: CGFloat = 56
            }

            enum Footer {
                static let minimumHeight: CGFloat = 0.1
            }

            enum PageIndicator {
                static let overlayTopOffset: CGFloat = -35
                static let zIndex: Int = 100
                static let imagePadding: CGFloat = 8
                static let contentLeading: CGFloat = 12
                static let contentTrailing: CGFloat = 12
            }

            enum AutoScroll {
                static let timeInterval: TimeInterval = 3.0
            }

            // MARK: - PlaceDetail
            enum PlaceDetail {
                enum ImageCarousel {
                    static let height: CGFloat = 250
                    static let itemWidthFraction: CGFloat = 0.9
                    static let itemSpacing: CGFloat = 12
                }

                enum BasicInfo {
                    static let estimatedHeight: CGFloat = 120
                }

                enum Description {
                    static let estimatedHeight: CGFloat = 100
                }

                enum OperatingInfo {
                    static let estimatedHeight: CGFloat = 120
                }

                enum Location {
                    static let height: CGFloat = 200
                }

                enum NearbyPlaces {
                    static let itemWidth: CGFloat = 180
                    static let itemHeight: CGFloat = 220
                    static let itemSpacing: CGFloat = 12
                }

                enum Header {
                    static let height: CGFloat = 44
                }

                enum ContentInsets {
                    static let standard: CGFloat = 20
                    static let imageCarousel: CGFloat = 20
                }

                enum Spacing {
                    static let section: CGFloat = 20
                    static let item: CGFloat = 12
                }
            }
        }

        // MARK: - Alpha
        enum Alpha {
            static let overlay: CGFloat = 0.3
            static let secondary: CGFloat = 0.8
        }

        // MARK: - Button
        enum Button {
            static let searchHeight: CGFloat = 44
            static let cornerRadius: CGFloat = 12
        }

        // MARK: - Button Height
        enum ButtonHeight {
            static let small: CGFloat = 32
            static let medium: CGFloat = 44
            static let large: CGFloat = 56
        }

        // MARK: - Label
        enum Label {
            static let pageIndicatorHeight: CGFloat = 24
            static let pageIndicatorMinWidth: CGFloat = 48
            static let pageIndicatorBottomOffset: CGFloat = 36
        }
    }

    // MARK: - Layout Constants
    enum Layout {
        // MARK: - Padding
        static let smallPadding: CGFloat = 8
        static let mediumPadding: CGFloat = 12
        static let standardPadding: CGFloat = 16
        static let largePadding: CGFloat = 20
        static let xLargePadding: CGFloat = 24

        // MARK: - Spacing
        static let itemSpacing: CGFloat = 10
        static let sectionSpacing: CGFloat = 20
        static let sectionInset: CGFloat = 20

        // MARK: - Heights
        static let imageCarouselHeight: CGFloat = 250
        static let cellMinHeight: CGFloat = 44
    }


    // MARK: - Icon Constants
    enum Icon {

        // MARK: - Theme Icons
        enum Theme {
            static let beach = "water.waves"
            static let mountain = "mountain.2.fill"
            static let night = "moon.stars.fill"
            static let culture = "building.columns.fill"
            static let market = "cart.fill"
            static let park = "tree.fill"
            static let defaultIcon = "location.fill"
            static let placeholder = "plus.circle.fill"
            static let photoPlaceholder = "photo"
        }

        // MARK: - Area Icons
        enum Area {
            static let seoul = "building.2.fill"
            static let incheon = "airplane"
            static let daejeon = "leaf.fill"
            static let daegu = "mountains.fill"
            static let gwangju = "sun.max.fill"
            static let busan = "water.waves"
            static let ulsan = "gear"
            static let sejong = "building.columns"
            static let gyeonggi = "house.and.flag.fill"
            static let gangwon = "mountain.2.fill"
            static let chungbuk = "tree.fill"
            static let chungnam = "leaf.arrow.circlepath"
            static let gyeongbuk = "mountain.2.circle.fill"
            static let gyeongnam = "water.waves.and.arrow.down"
            static let jeonbuk = "rice"
            static let jeonnam = "sunset.fill"
            static let jeju = "tropicalstorm"
        }

        // MARK: - System Icons
        enum System {
            static let magnifyingGlass = "magnifyingglass"
            static let chevronRight = "chevron.right"
            static let location = "location"
            static let heart = "heart"
            static let heartFill = "heart.fill"
            static let star = "star"
            static let starFill = "star.fill"
        }
    }
}
