import UIKit

class FeedListViewController: UITableViewController, XMLParserDelegate, UISearchResultsUpdating, UISearchBarDelegate {

    var myFeed : NSArray = []
    var feedImgs: [AnyObject] = []
    var url: URL!
    var text: String!
    let searchController = UISearchController()
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        self.tableView.dataSource = self
        self.tableView.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        loadData()
    }

    @IBAction func refreshFeed(_ sender: Any) {

        loadData()
    }
    
    func loadData() {
        url = URL(string: "https://www.news.google.com/rss")!
        loadRss(url);
    }
    func loadData2(_ s: String) {
       url = URL(string: "https://news.google.com/rss/search?q="+s)!
       loadRss(url);
   }
    
    func loadRss(_ data: URL) {
        let myParser : XmlParserManager = XmlParserManager().initWithURL(data) as! XmlParserManager
       
        feedImgs = myParser.img as [AnyObject]
        myFeed = myParser.feeds
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
       text = searchController.searchBar.text!
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadData2(text)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openPage" {
            let indexPath: IndexPath = self.tableView.indexPathForSelectedRow!
            let selectedFURL: String = (myFeed[indexPath.row] as AnyObject).object(forKey: "link") as! String

            // Instance of our feedpageviewcontrolelr.
            let fiwvc: FeedItemWebViewController = segue.destination as! FeedItemWebViewController
            fiwvc.selectedFeedURL = selectedFURL as String
        }
    }

    // MARK: - Table view data source.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myFeed.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let cellBGColorView = UIView()
        var image: UIImage!
        if feedImgs.count > indexPath.row {
            let cellImageLayer: CALayer?  = cell.imageView?.layer
            let url = NSURL(string:feedImgs[indexPath.row] as! String)
            let data = NSData(contentsOf:url! as URL)
            image = UIImage(data:data! as Data)
            image = resizeImage(image: image!, toTheSize: CGSize(width: 70, height: 70))
            cellImageLayer!.cornerRadius = 35
            cellImageLayer!.masksToBounds = true
            cellBGColorView.backgroundColor = .black
        }
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(white: 1, alpha: 0)
        } else {
            cell.backgroundColor = UIColor(white: 1, alpha: 0.1)
        }
        cell.imageView?.image = image
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.detailTextLabel?.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = cellBGColorView
        cell.textLabel?.text = (myFeed.object(at: indexPath.row) as AnyObject).object(forKey: "title") as? String
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.detailTextLabel?.text = (myFeed.object(at: indexPath.row) as AnyObject).object(forKey: "pubDate") as? String
        cell.detailTextLabel?.textColor = UIColor.white

        return cell
    }


    func resizeImage(image:UIImage, toTheSize size:CGSize)->UIImage{

        let scale = CGFloat(max(size.width/image.size.width,
                                size.height/image.size.height))
        let width:CGFloat  = image.size.width * scale
        let height:CGFloat = image.size.height * scale;

        let rr:CGRect = CGRect(x: 0, y: 0, width: width, height: height)

        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        image.draw(in: rr)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage!
    }
}
