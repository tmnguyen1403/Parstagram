//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Tom Riddle on 10/20/20.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MessageInputBarDelegate {
 

  @IBOutlet weak var tableView: UITableView!
  let commentBar = MessageInputBar()
  var showCommentBar = false
  var refreshControl : UIRefreshControl!
  var posts = [PFObject]() //create an empty array of PFObject
  var selectedPost: PFObject!
  let LIMIT_POST:Int = 20
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    commentBar.inputTextView.placeholder = "Add a comment..."
    commentBar.sendButton.title = "Post"
    commentBar.delegate = self
    
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.keyboardDismissMode = .interactive
    //refresh
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(onRefresh(_:)), for: .valueChanged)
    tableView.insertSubview(refreshControl, at: 0)
  
    let center = NotificationCenter.default
    center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  @objc
  func keyboardWillBeHidden(note: Notification) {
    commentBar.inputTextView.text = nil
    showCommentBar = false
    becomeFirstResponder()
  }
    
  override var inputAccessoryView: UIView? {
      return commentBar
  }
  
  override var canBecomeFirstResponder: Bool {
    return showCommentBar
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    getPosts()
  }
  
  func getPosts() {
    let query = PFQuery(className: "Post")
    query.includeKeys(["author", "comments", "comments.author"])
    query.limit = LIMIT_POST
    
    query.findObjectsInBackground { (posts, error) in
      if let posts = posts{
        print("onRefresh get new posts");
        self.posts = posts
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
        
      }
      else if let error = error {
        print("Error getPoss \(error.localizedDescription)")
        self.displayError(error: error, "getPosts")
      }
    }
    self.tableView.reloadData()
  }
  
  @IBAction func onLogout(_ sender: Any) {
    PFUser.logOutInBackground { (error) in
      if let error = error {
        print("Error Logout \(error.localizedDescription)")
        self.displayError(error: error, "logout")
      }
      else {
        print("logout successfully")
        NotificationCenter.default.post(name: NSNotification.Name("logout"), object: nil)
      }
    }
  }
  
  
  @objc
  func onRefresh(_ refreshControl: UIRefreshControl) {
    print("onRefresh method");
    getPosts()
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return posts.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let post = posts[section]
    let comments = (post["comments"] as? [PFObject]) ?? []
    
    //+1 for post
    //+1 for add comment
    
    return comments.count + 2
  }
  
  func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
    //create the comment
    let comment = PFObject(className: "Comments")
    
    comment["text"] = inputBar.inputTextView.text
    comment["post"] = selectedPost
    comment["author"] = PFUser.current()!

    selectedPost.add(comment, forKey: "comments")

    selectedPost.saveInBackground { (success, error) in
      if success {
        print("Comment saved")
        self.tableView.reloadData()
      } else {
        print("Error saving comment")
      }
    }
    //clear and dismiss the inputBar
    commentBar.inputTextView.text = nil
    showCommentBar = false
    becomeFirstResponder()
    commentBar.inputTextView.resignFirstResponder()
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let post = posts[indexPath.section]
    let comments = (post["comments"] as? [PFObject]) ?? []
    //return a post cell
    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
      let user = post["author"] as!PFUser
      cell.usernameLabel.text = user.username
      cell.captionLabel.text = post["caption"] as! String
      
      let imageFile = post["image"] as! PFFileObject
      let urlString = imageFile.url!
      let url = URL(string: urlString)!
      
      cell.photoView.af.setImage(withURL: url)
      return cell

    } else if indexPath.row <= comments.count {
      //return a comment cell
      let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell

      let comment = comments[indexPath.row - 1]

      cell.commentLabel.text = (comment["text"] as? String) ?? "No comment"

      let user = comment["author"] as! PFUser
      cell.nameLabel.text = user.username

      return cell
    } else {
      //return an "add comment cell"
      let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!

      return cell
    }
  }
  
  //add comment when select post
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let post = posts[indexPath.section]
    
    let comments = (post["comments"] as? [PFObject]) ?? []
    
    if indexPath.row == comments.count + 1 {
      selectedPost = post
      showCommentBar = true
      becomeFirstResponder()
      commentBar.inputTextView.becomeFirstResponder()
    }

  }

  func displayError(error: Error, _ performAction: String) {
    //prepare message
    let title = "Error \(performAction)"
    let message = "Something when wrong while \(performAction): \(error.localizedDescription)"
    //render error
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default)
    alertController.addAction(OKAction)
    present(alertController, animated: true, completion: nil)
  }
}
