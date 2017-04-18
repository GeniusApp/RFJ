//
//  InfoRViewController.swift
//  rfj
//
//  Created by Gonçalo Girão on 18/04/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

import UIKit

class InfoRViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var infoRTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        infoRTableView.delegate = self
        infoRTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CellComment"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell?
        return cell!
    }

}
