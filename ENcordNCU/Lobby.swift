//
//  Saloon.swift
//  Rec Walker
//
//  Created by BnLab on 2017/9/23.
//  Copyright © 2017年 BnLab. All rights reserved.
//

import UIKit

class Lobby: UIViewController,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var bulletin: UITableView!

    var string = ["感謝下載ENcord","我們終於完工拉～","ENcord希望能帶給大家練習口說的機會","我以為會有人幫我們處理上架呢","結果只是我以為"]
    let path = "http://140.115.152.223:7000/api/User/"
    var token: String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadJsonWithURL()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        token = "Token " + (UserDefaults.standard.object(forKey: "token") as! String)
    }
    
    func downloadJsonWithURL() {
        let request = NSMutableURLRequest(url: NSURL(string: path)! as URL)
        request.httpMethod = "GET"
        request.addValue(token, forHTTPHeaderField:"Authorization")
        let session = URLSession.shared
        session.dataTask(with: request as URLRequest ) { (data, response, error) in

            // Read the JSON
            do {
                // Parse the JSON
                let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray
                let origin = jsonDictionary[0] as? NSDictionary
                let fullname = origin?.value(forKey: "fullname") as! String
                DispatchQueue.main.async {
                    self.navigationItem.title = "歡迎👏 " + fullname
                }
            } catch {
                print("bad things happened")
            }
        }.resume()
        
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return string.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = bulletin.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = string[indexPath.row]
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
