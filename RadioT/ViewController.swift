//
//  ViewController.swift
//  RadioT
//
//  Created by Den on 24.06.17.
//  Copyright © 2017 Den. All rights reserved.
//

import UIKit
import PokeModal
import Kanna

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PokeModalDelegate  {

    @IBOutlet weak var collectionView: UICollectionView!
   
   var modal_info: PokeModal? = nil
    
    
    @IBAction func openInfoBt(_ sender: Any) {
        
        print("info")
        
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "infoC")
        self.present(secondViewController!, animated: true, completion: nil)
    }
    
    
    @IBAction func openOnlineBt(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "onlineC")
        self.present(secondViewController!, animated: true, completion: nil)
    }
   
    
    @IBAction func openNewsBt(_ sender: Any) {
        
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "newsC")
        self.present(secondViewController!, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        
        
        
       // FONT - OpenSans-Semibold
        
        
        modal_info = PokeModal(view: self.view)
       
        
        
        modal_info?.delegate = self
        
        
        
        NotificationCenter.default.addObserver(self, selector: (#selector(ViewController.upd)), name: Notification.Name("get_rss"), object: nil)
        
        
        
        
        DispatchQueue.main.async {
            ManagerData.sharedManager.getRSS()
        }
        
        
       // self.view.backgroundColor = UIColor.init(hexString: "#def2f5")
        self.collectionView.backgroundColor = UIColor.init(hexString: "#f5f6f6")
         self.collectionView?.reloadData()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func upd()  {
        
        
        DispatchQueue.main.async {
            print("reload")
            self.collectionView.reloadData()
        }
        
      
        
        
        
    }
    
    
    func pokeModalWillHide() {
        print("Hiding modal")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
 
    
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ManagerData.sharedManager.podcast.episodes.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CustomCell
        
        
        
        let index = indexPath.row
        let info = ManagerData.sharedManager.podcast.episodes[index]
        
        
        cell.titileLb.text = info["ep_title"]
        cell.pubDatelb.text = info["ep_pubDate"]
        
        
        let url = URL(string: info["ep_image"]!)
        
        print("cellll---",url)

        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                print("imgg")
                cell.ep_logo?.image = UIImage(data: data!)
                cell.ep_logo?.alpha = 1.0
                
                let data = try? Data(contentsOf: url!)
                let image = UIImage(data: data!)
                let imageView = UIImageView(image: image!)
                
                imageView.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height  - 50)
                cell.addSubview(imageView)
                
                
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.layer.zPosition = 0
                
                
                let button = UIButton(type: .system) // let preferred over var here
                button.frame = CGRect(x: imageView.frame.width - 60,
                                      y: imageView.frame.height - 30,
                                      width: 40,
                                      height: 40
                )

               
                
                
                let image1 = UIImage(named: "play")
                let imageView1 = UIImageView(image: image1!)
                
                imageView1.frame = CGRect(x: imageView.frame.width - 45,
                                          y: imageView.frame.height - 20,
                                          width: 40,
                                          height: 40 )
                
                imageView1.layer.zPosition = 1
                
               
                
                cell.addSubview(imageView1)
                
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.playTapped(tapGestureRecognizer:)))
                imageView1.isUserInteractionEnabled = true
                imageView1.addGestureRecognizer(tapGestureRecognizer)
                
            }
        }
        
       
        
        
        cell.layer.cornerRadius = 3 //set corner radius here
        
        cell.backgroundColor = UIColor.white
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CustomCell
        print("Select")
        
        let info = ManagerData.sharedManager.podcast.episodes[indexPath.row]
        
        
        
        
        modal_info?.titleText = (info["ep_title"])!
        modal_info?.contentText = ""
        
        if let doc = HTML(html: (info["ep_description"])!, encoding: .utf8) {
            for item in doc.xpath("//li") {

                if let text = item.at_xpath("a")?.text {
                    modal_info?.contentText  += text + "\n"
                }
            }
        }
        
        modal_info?.contentText  += "Темы наших слушателей" + "\n\n"
        
        
        modal_info?.contentText  += info["ep_pubDate"]! + "\n"
        
        
        let countBytes = ByteCountFormatter()
        countBytes.allowedUnits = [.useMB]
        countBytes.countStyle = .file
        let fileSize = countBytes.string(fromByteCount: Int64(info["ep_mp3_fileSize"]!)!)
        
        modal_info?.contentText  += fileSize + "\n"

        self.modal_info?.showMenu()
        
    }
    
    
    func getHoursMinutesSecondsFrom(_ seconds: Double) -> (hours: Int, minutes: Int, seconds: Int) {
        if seconds.isNaN { return (0,0,0) }
        let secs = Int(seconds)
        let hours = secs / 3600
        let minutes = (secs % 3600) / 60
        let seconds = (secs % 3600) % 60
        return (hours, minutes, seconds)
    }
    
    func formatTimeFor(seconds: Double) -> String {
        let result = getHoursMinutesSecondsFrom(seconds)
        print("result--",result)
        let hoursString = "\(result.hours)"
        var minutesString = "\(result.minutes)"
        if minutesString.characters.count == 1 {
            minutesString = "0\(result.minutes)"
        }
        var secondsString = "\(result.seconds)"
        if secondsString.characters.count == 1 {
            secondsString = "0\(result.seconds)"
        }
        var time = "\(hoursString):"
        if result.hours >= 1 {
            time.append("\(minutesString):\(secondsString)")
        }
        else {
            time = "\(minutesString):\(secondsString)"
        }
        return time
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let w = (self.view.frame.width / 2) - 15
        return CGSize(width: w, height: 150)
    }
    
    
    func playTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //_ = tapGestureRecognizer.view as! UIImageView
        
        
        //using sender, we can get the point in respect to the table view
        let tapLocation = tapGestureRecognizer.location(in: self.collectionView)
        
        //using the tapLocation, we retrieve the corresponding indexPath
        let indexPath = self.collectionView.indexPathForItem(at: tapLocation)
        
        //finally, we print out the value
        print(indexPath?.row)
        
        let cell = self.collectionView.cellForItem(at: indexPath!)
        
       
        
        print("play tab")
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "offline_player") as! OfflinePlayerConrtoller
        secondViewController.ep_index = (indexPath?.row)!
        self.present(secondViewController, animated: true, completion: nil)
        
    }

}




extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

