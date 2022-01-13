import UIKit
import RxSwift

/**
 The view which displays the list of campaigns. It is configured in the storyboard (Main.storyboard). The corresponding
 view controller is the `CampaignsListingViewController`.
 */
class CampaignListingView: UICollectionView {

    /**
     A strong reference to the view's data source. Needed because the view's dataSource property from UIKit is weak.
     */
    @IBOutlet var strongDataSource: UICollectionViewDataSource!

    /**
     Displays the given campaign list.
     */
    func display(campaigns: [Campaign]) {
        let campaignDataSource = ListingDataSource(campaigns: campaigns)
        dataSource = campaignDataSource
        delegate = campaignDataSource
        strongDataSource = campaignDataSource
        reloadData()
    }

    struct Campaign {
        let name: String
        let description: String
        let moodImage: Observable<UIImage>
    }

    /**
     All the possible cell types that are used in this collection view.
     */
    enum Cells: String {

        /** The cell which is used to display the loading indicator. */
        case loadingIndicatorCell

        /** The cell which is used to display a campaign. */
        case campaignCell
    }
}


/**
 The data source for the `CampaignsListingView` which is used to display the list of campaigns.
 */
class ListingDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    /** The campaigns that need to be displayed. */
    let campaigns: [CampaignListingView.Campaign]

    /**
     Designated initializer.

     - Parameter campaign: The campaigns that need to be displayed.
     */
    init(campaigns: [CampaignListingView.Campaign]) {
        self.campaigns = campaigns
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return campaigns.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let campaign = campaigns[indexPath.item]
        let reuseIdentifier =  CampaignListingView.Cells.campaignCell.rawValue
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if let campaignCell = cell as? CampaignCell {
            campaignCell.moodImage = campaign.moodImage
            campaignCell.name = campaign.name
            campaignCell.descriptionText = campaign.description
        } else {
            assertionFailure("The cell should a CampaignCell")
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let reuseIdentifier =  CampaignListingView.Cells.campaignCell.rawValue
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        return size(collectionView, cell, indexPath)
        //CGSize(width: collectionView.frame.size.width, height: 450)
    }

}



/**
 The data source for the `CampaignsListingView` which is used while the actual contents are still loaded.
 */
class LoadingDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = CampaignListingView.Cells.loadingIndicatorCell.rawValue
        return collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                  for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

extension ListingDataSource {
    func size(_ collectionView: UICollectionView,_ cell: UICollectionViewCell, _ index: IndexPath) -> CGSize {
        let campaign = campaigns[index.item]
        let width = collectionView.frame.size.width
        let margin = LayoutMargin.leadingMargin + LayoutMargin.trailingMargin
        if let campaignCell = cell as? CampaignCell {
            let titleAttribute = [NSAttributedString.Key.font: campaignCell.nameLabel.font]
            let titleString = NSAttributedString.init(string: campaign.name, attributes: titleAttribute)
            
            let titleHeight = titleString.boundingRect(with: CGSize(width: width - CGFloat(margin), height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil).size.height
            
            let descriptionAttribute = [NSAttributedString.Key.font: campaignCell.descriptionLabel.font]

            let descriptionString = NSAttributedString.init(string: campaign.description, attributes: descriptionAttribute)
            
            let descriptionHeight = descriptionString.boundingRect(with: CGSize(width: width - CGFloat(margin), height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil).size.height
            let ratio = CGFloat((campaignCell.imageView.frame.size.width)) / CGFloat((campaignCell.imageView.frame.size.height))
            let newHeight = width / CGFloat(ratio)
            let finalHeight = newHeight + descriptionHeight + titleHeight + CGFloat(LayoutMargin.heightMargin)
            return CGSize(width: width, height: finalHeight)
        }

        let defaultSize = CGSize(width: width, height: 450)
        return defaultSize
    }

}
