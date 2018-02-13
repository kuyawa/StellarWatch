//
//  InterfaceController.swift
//  StellarWatch WatchKit Extension
//
//  Created by Laptop on 2/12/18.
//  Copyright © 2018 Armonia. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    var ticker  = Ticker()
    var coin    = Coin()
    var updated = Date()
    
    @IBOutlet var textPrice  : WKInterfaceLabel!
    @IBOutlet var textVolume : WKInterfaceLabel!
    @IBOutlet var textMarket : WKInterfaceLabel!
    
    @IBOutlet var imageLeft  : WKInterfaceImage!
    @IBOutlet var imageRight : WKInterfaceImage!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        //print("AWAKE")
        getTicker()
    }
    
    override func willActivate() {
        super.willActivate()
        let elapsed = updated.addingTimeInterval(60) // 1 min
        //print("Elapsed?\n  \(updated)\n  \(elapsed)\n  \(Date())")
        if elapsed < Date() {
            getTicker()
        }
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        // This method is called when watch view controller is no longer visible
    }
    
    func getTicker() {
        //print("Fetching ticker...")
        let api = "https://api.coinmarketcap.com/v1/ticker/stellar/"
        let url = URL(string: api)
        
        updated = Date()
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            if error != nil {
                self.textPrice.setText("ERROR")
                self.textVolume.setText("TRY LATER")
                self.textMarket.setText("NO INTERNET")
                print("Error fetching API")
                print(error ?? "?")
                return
            }
            
            if let text = String(data: data!, encoding: .utf8) {
                //print("Parsing json: ", text)
                //self.updated = Date()
                self.ticker  = Ticker(json: text)
                self.coin = self.ticker.getCoin("XLM") ?? Coin()
                //self.ticker.show()
                //self.ticker.show2()
                DispatchQueue.main.async {
                    self.textPrice.setText(self.coin.priceUsd.format(4, 4))
                    self.textVolume.setText("VOL: " + self.coin.volumeUsd.toMillions())
                    self.textMarket.setText("CAP: " + self.coin.marketUsd.toMillions())
                    if self.coin.change01h > 0 {
                        self.imageLeft.setImageNamed("arrowup")
                        self.imageRight.setImageNamed("arrowup")
                    } else {
                        self.imageLeft.setImageNamed("arrowdn")
                        self.imageRight.setImageNamed("arrowdn")
                    }
                }
            } else {
                self.textPrice.setText("ERROR")
                self.textVolume.setText("TRY LATER")
                self.textMarket.setText("BAD RESPONSE")
                print("Error parsing JSON")
                print(error ?? "?")
            }
        }
        task.resume()
    }
    
}

// END
