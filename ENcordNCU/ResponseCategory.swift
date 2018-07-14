//
//  ResponseCategory.swift
//  Rec Walker
//
//  Created by BnLab on 2017/10/31.
//  Copyright © 2017年 BnLab. All rights reserved.
//

import UIKit

class ResponseCategory: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    
    let list = ["Science","Nature","Life","Joke","News","Others"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        if segue.identifier == "responsecategory"{
            let index = table.indexPathForSelectedRow?.row
            let vc = segue.destination as! ResponseSelect
            vc.bartitle = list[index!]
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
