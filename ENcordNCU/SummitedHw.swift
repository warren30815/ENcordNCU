//
//  SummitedHw.swift
//  Rec Walker
//
//  Created by BnLab on 2017/9/30.
//  Copyright © 2017年 BnLab. All rights reserved.
//

import UIKit

class SummitedHw: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var path = "http://140.115.152.223:7000/api/Studentresponse/"
    var list = [String]()
    var audio = [String]()
    var classname: String!
    var ID: Int!
    var StudentResponseID = [Int]()
    var category: String!
    var token: String!
    
    @IBOutlet weak var table: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadJsonWithURL()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = classname
        UserDefaults.standard.set(classname, forKey: "practicename")
        category = UserDefaults.standard.object(forKey: "Teachercategory") as! String
        token = "Token " + (UserDefaults.standard.object(forKey: "token") as! String)
        UserDefaults.standard.set(ID, forKey: "TeacherPracticeID")
        // Do any additional setup after loading the view.
    }
    
    func downloadJsonWithURL() {
        path = "http://140.115.152.223:7000/api/Studentresponse/"
        path = path + category + "/"
        list.removeAll()
        audio.removeAll()
        StudentResponseID.removeAll()
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
                    let alert = UIAlertController(title: "還沒有人繳交喔~", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil
                    ))
                    self.present(alert, animated: true, completion: nil)
                }else{
                    for i in 0...(jsonDictionary.count - 1){
                        let origin = jsonDictionary[i] as? NSDictionary
                        let practice_id = origin?.value(forKey: "practice_id") as! String
                            if practice_id == String(self.ID){
                                let student = origin?.value(forKey: "student")
                                let audio = origin?.value(forKey: "audio")
                                
                                let studentid = origin?.value(forKey: "id")
                                self.list.append(student as! String)
                                self.audio.append(audio as! String)
                            
                        self.StudentResponseID.append(studentid as! Int)
                        }
                    }
                }
            } catch {
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "submittedhw"{
            let des = segue.destination as! StudentHW
            let index = table.indexPathForSelectedRow?.row
            des.audio = audio[index!]
            des.topic = list[index!]
            des.student_id = StudentResponseID[index!]
        }
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
