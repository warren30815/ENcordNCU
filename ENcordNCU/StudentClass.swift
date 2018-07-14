//
//  StudentClass.swift
//  Rec Walker
//
//  Created by BnLab on 2017/9/30.
//  Copyright © 2017年 BnLab. All rights reserved.
//

import UIKit

class StudentClass: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var Teachername = [String]()
    var Practicename = [String]()
    var ID = [Int]()
    var demand = [String]()
    var content = [String]()
    var example_audio = [String]()
    var example_url = [String]()
    var bartitle: String!
    var path = "http://140.115.152.223:7000/api/"
    var token: String!
    
    @IBOutlet weak var table: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadJsonWithURL()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = bartitle
        token = "Token " + (UserDefaults.standard.object(forKey: "token") as! String)
        UserDefaults.standard.set(bartitle, forKey: "StudentCategory")
        // Do any additional setup after loading the view.
    }
    
    func downloadJsonWithURL() {
        path = "http://140.115.152.223:7000/api/"
        path = path + bartitle + "/"
        Teachername.removeAll()
        Practicename.removeAll()
        ID.removeAll()
        demand.removeAll()
        content.removeAll()
        example_audio.removeAll()
        example_url.removeAll()
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
                    let alert = UIAlertController(title: "尚未有任何練習", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }else{
                    for i in 0...(jsonDictionary.count - 1){
                        let origin = jsonDictionary[i] as? NSDictionary
                        let name = origin?.value(forKey: "author")
                        let ID = origin?.value(forKey: "id")
                        let hw = origin?.value(forKey: "topic")
                        let demand = origin?.value(forKey: "demand")
                        let content = origin?.value(forKey: "content")
                        let audio = origin?.value(forKey: "example_audio") as! String
                        let example_url = origin?.value(forKey: "example_url") as! String
                        self.Teachername.append(name as! String)
                        self.ID.append(ID as! Int)
                        self.Practicename.append(hw as! String)
                        self.demand.append(demand as! String)
                        self.content.append(content as! String)
                        self.example_audio.append(audio)
                        self.example_url.append(example_url)
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
        return Practicename.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StudentClassCell
        cell.name.text = Teachername[indexPath.row]
        cell.homework.text = Practicename[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "studentpractice"{
            let index = table.indexPathForSelectedRow?.row
            let vc = segue.destination as! StudentPractice
            vc.name = Practicename[index!]
            vc.practice_id = ID[index!]
            vc.demand = demand[index!]
            vc.content = content[index!]
            vc.example_audio = example_audio[index!]
            vc.example_url = example_url[index!]
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
