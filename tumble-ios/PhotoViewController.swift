//
//  PhotoViewController.swift
//  
//
//  Created by Zachary West Guo on 9/15/16.
//
//
import UIKit
import AFNetworking

import UIKit

class PhotoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UIScrollViewDelegate {
    
    var posts: [NSDictionary] = [];
    var isMoreDataLoading = false;
    var loadingMoreView:InfiniteScrollActivityView?

    @IBOutlet var tableView: UITableView!
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                
                // ... Code to load more results ...
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()

                loadMoreData();
            }
            
        }
    }
    func loadMoreData() {

    // ... Create the NSURLRequest (myRequest) ...
    let url = NSURL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
    let request = NSURLRequest(URL: url!)

    // Configure session so that completion handler is executed on main UI thread
    let session = NSURLSession(
        configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
        delegate:nil,
        delegateQueue:NSOperationQueue.mainQueue()
    )

    let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
        completionHandler: { (data, response, error) in    

            // Update flag
            self.isMoreDataLoading = false

            if let data = data {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data, options:[]) as? NSDictionary {
                    print("responseDictionary: \(responseDictionary)")
                    
                    // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                    // This is how we get the 'response' field
                    let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                    
                    // This is where you will store the returned array of posts in your posts property
                    self.posts += responseFieldDictionary["posts"] as! [NSDictionary]
                    
                }
            }

            
            self.loadingMoreView!.stopAnimating()
                
            // Reload the tableView now that there is new data
            self.tableView.reloadData()
        });
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 240;
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        let url = NSURL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
          completionHandler: { (data, response, error) in
            if let data = data {
              if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                data, options:[]) as? NSDictionary {
                  print("responseDictionary: \(responseDictionary)")

                  // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                  // This is how we get the 'response' field
                  let responseFieldDictionary = responseDictionary["response"] as! NSDictionary

                  // This is where you will store the returned array of posts in your posts property
                  self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                  self.tableView.reloadData()

              }
            }
        });
        
        task.resume()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        // Do any additional setup after loading the view.
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        let url = NSURL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = NSURLRequest(URL: url!)
    


        // ... Create the NSURLRequest (myRequest) ...

        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )

        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (data, response, error) in

            // ... Use the new data to update the data source ...
            
            // Reload the tableView now that there is new data
            self.tableView.reloadData()

            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()	
        });
        task.resume()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PhotoCell") as! PhotoCell
        let post = posts[indexPath.row]
        
        //let timestamp = post["timestamp"] as? String
        
        if let photos = post.valueForKeyPath("photos") as? [NSDictionary] {
            // photos is NOT nil, go ahead and access element 0 and run the code in the curly braces
            
            let imageUrlString = photos[0].valueForKeyPath("original_size.url") as? String
            if let imageUrl = NSURL(string: imageUrlString!) {
                // NSURL(string: imageUrlString!) is NOT nil, go ahead and unwrap it and assign it to imageUrl and run the code in the curly braces
             
                
                 cell.postImage.setImageWithURL(imageUrl)
            } else {
                // NSURL(string: imageUrlString!) is nil. Good thing we didn't try to unwrap it!
            }
            
            
        } else {
            // photos is nil. Good thing we didn't try to unwrap it!
        }
        
        
        // Configure YourCustomCell using the outlets that you've defined.
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var vc = segue.destinationViewController as! PhotoDetailsViewController
        
        var indexPath = tableView.indexPathForCell(sender as! PhotoCell)
        
        let post = posts[indexPath!.row]
        
        //let timestamp = post["timestamp"] as? String
        
        if let photos = post.valueForKeyPath("photos") as? [NSDictionary] {
            // photos is NOT nil, go ahead and access element 0 and run the code in the curly braces
            
            let imageUrlString = photos[0].valueForKeyPath("original_size.url") as? String
            if let imageUrl = NSURL(string: imageUrlString!) {
                // NSURL(string: imageUrlString!) is NOT nil, go ahead and unwrap it and assign it to imageUrl and run the code in the curly braces
                
                vc.photoUrl = imageUrl
            } else {
                // NSURL(string: imageUrlString!) is nil. Good thing we didn't try to unwrap it!
            }
            
            
        } else {
            // photos is nil. Good thing we didn't try to unwrap it!
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
