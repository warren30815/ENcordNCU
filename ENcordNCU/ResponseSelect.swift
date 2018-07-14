//
//  ResponseSelect.swift
//  Rec Walker
//
//  Created by BnLab on 2017/10/31.
//  Copyright © 2017年 BnLab. All rights reserved.
//

import UIKit

class ResponseSelect: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    
    var bartitle: String!
    var list = [String]()
    var practiceID = [String]()
    var commentID = [String]()
    var teacheraudio = [String]()
    var score = [String]()
    var path = "http://140.115.152.223:7000/api/Teacherresponse/"
    var username: String!
    var token: String!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadJsonWithURL()
    }
    
    func downloadJsonWithURL() {
        path = "http://140.115.152.223:7000/api/Teacherresponse/"
        path = path + bartitle + "/"
        list.removeAll()
        practiceID.removeAll()
        commentID.removeAll()
        teacheraudio.removeAll()
        score.removeAll()
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
                    let alert = UIAlertController(title: "尚未有任何回應", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }else{
                    for i in 0...(jsonDictionary.count - 1){
                        let origin = jsonDictionary[i] as? NSDictionary
                        let user = origin?.value(forKey: "target") as! String
                        if user == self.username{
                            let practiceID = origin?.value(forKey: "practice_id") as! String
                            let practicename = origin?.value(forKey: "practice_name") as! String
                            let commentID = origin?.value(forKey: "comment_id") as! String
                            let teacheraudio = origin?.value(forKey: "teacher_reaudio") as! String
                            let score = origin?.value(forKey: "score") as! String
                            self.practiceID.append(practiceID)
                            self.list.append(practicename)
                            self.commentID.append(commentID)
                            self.teacheraudio.append(teacheraudio)
                            self.score.append(score)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = bartitle
        username = UserDefaults.standard.object(forKey: "account") as! String
        token = "Token " + (UserDefaults.standard.object(forKey: "token") as! String)
        // Do any additional setup after loading the view.
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
        if segue.identifier == "responseselect"{
            let index = table.indexPathForSelectedRow?.row
            let vc = segue.destination as! Response
            vc.practice_id = practiceID[index!]
            vc.comment_id = commentID[index!]
            vc.category = self.bartitle
            vc.bartitle = list[index!]
            vc.teacheraudio = teacheraudio[index!]
            vc.score = score[index!]
        }
    }

    @IBAction func unwind(for segue: UIStoryboardSegue){
        
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
