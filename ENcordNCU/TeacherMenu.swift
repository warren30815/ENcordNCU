//
//  TeacherMenu.swift
//  Rec Walker
//
//  Created by BnLab on 2017/9/30.
//  Copyright © 2017年 BnLab. All rights reserved.
//

import UIKit

class TeacherMenu: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var table: UITableView!
    
    var ID = [Int]()
    var list = [String]()
    var content = [String]()
    var path = "http://140.115.152.223:7000/api/"
    var username: String!
    var token: String!
    var bartitle: String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadJsonWithURL()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username = UserDefaults.standard.object(forKey: "account") as! String
        token = "Token " + (UserDefaults.standard.object(forKey: "token") as! String)
        UserDefaults.standard.set(bartitle, forKey: "Teachercategory")
        // Do any additional setup after loading the view.
    }
    
    func downloadJsonWithURL() {
        path = "http://140.115.152.223:7000/api/"
        path = path + bartitle + "/"
        ID.removeAll()
        list.removeAll()
        content.removeAll()
        self.navigationItem.title = bartitle
        let request = NSMutableURLRequest(url: NSURL(string: path)! as URL)
        request.httpMethod = "GET"
        request.addValue(token, forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        session.dataTask(with: request as URLRequest ) { (data, response, error) in
            guard let data = data else {
                print("Error \(error!)")
                return
            }
            // Read the JSON
            do {
                // Parse the JSON
                let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSArray
                if jsonDictionary.count < 1{
                    let alert = UIAlertController(title: "尚未出任何作業", message: "點擊右上角＋號出新作業", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }else{
                    for i in 0...(jsonDictionary.count - 1){
                        let origin = jsonDictionary[i] as? NSDictionary
                        let author = origin?.value(forKey: "author") as! String
                        if author == self.username{
                            let ID = origin?.value(forKey: "id")
                            let hw = origin?.value(forKey: "topic")
                            let content = origin?.value(forKey: "content")
                            self.ID.append(ID as! Int)
                            self.list.append(hw as! String)
                            self.content.append(content as! String)
                        }
                    }
                }
            }catch{
                print("bad things happened")
            }
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }.resume()
        
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = list[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "teacherclass"{
            let index = table.indexPathForSelectedRow?.row
            let vc = segue.destination as! SummitedHw
            vc.classname = list[index!]
            vc.ID = ID[index!]
            UserDefaults.standard.set(content[index!], forKey: "Teacherhwcontent")
        }
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
