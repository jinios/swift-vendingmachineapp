//
//  ViewController.swift
//  VendingMachineApp
//
//  Created by YOUTH on 2018. 3. 20..
//  Copyright © 2018년 JINiOS. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var vending: (DefaultMode & AdminMode & UserMode)?

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet var moneyButtons: [UIButton]!
    @IBOutlet weak var bananamilkStock: UILabel!
    @IBOutlet weak var chocomilkStock: UILabel!
    @IBOutlet weak var coffeeStock: UILabel!
    @IBOutlet weak var dolcelatteStock: UILabel!
    @IBOutlet weak var energydrinkStock: UILabel!
    @IBOutlet weak var softdrinkStock: UILabel!
    @IBOutlet var buyButtons: [UIButton]!

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.vending != nil {
            self.setIntroView()
        } else {
            self.vending = VendingMachine(stockItems: AdminController().setVendingMachineStock(unit: 1))
        }
    }

    private func setMoneyButtonsUI() {
        for button in self.moneyButtons {
            button.layer.cornerRadius = 5.0
        }
    }

    private func setBalanceLabelUI() {
        self.balanceLabel.clipsToBounds = true
        self.balanceLabel.layer.cornerRadius = 5.0
    }

    private func setBuyButtonsUI() {
        for button in self.buyButtons {
            button.layer.cornerRadius = 5.0
        }
    }

    private func setIntroView() {
        self.updateItemNumber()
        self.setBalance()
        self.previousHistoryLog()
        self.setMoneyButtonsUI()
        self.setBalanceLabelUI()
        self.setBuyButtonsUI()
        NotificationCenter.default.addObserver(self, selector: #selector(didChangedBalance), name: .changedBalance, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeItemNumber(_:)), name: .changedItemNumber, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBuy), name: .updatePurchaseLog, object: nil)
    }

    @objc private func didChangeItemNumber(_ notification: Notification) {
        self.updateItemNumber()
    }

    @objc private func didChangedBalance(_ notification: Notification) {
        self.setBalance()
    }

    @objc private func didBuy() {
        self.updatePurchasedItemView(self.vending!.lastPurchasedItem())
    }

    @IBAction func buyButtonTouched(_ sender: UIButton) {
        guard let item = try? vending!.buy(itemCode: sender.tag) else { return }
    }

    @IBAction func addBalance(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            vending?.addBalance(money: ValidMoney.thousand.cash)
        case 1:
            vending?.addBalance(money: ValidMoney.fiveThousand.cash)
        default:
            vending?.addBalance(money: ValidMoney.zero.cash)
        }
    }

    private func updateItemNumber() {
        guard let vending = self.vending else { return }
        self.bananamilkStock.text = String(amountFormat: vending.howMany(of: BananaMilk()))
        self.chocomilkStock.text = String(amountFormat: vending.howMany(of: ChocoMilk()))
        self.coffeeStock.text = String(amountFormat: vending.howMany(of: Coffee()))
        self.dolcelatteStock.text = String(amountFormat: vending.howMany(of: DolceLatte()))
        self.energydrinkStock.text = String(amountFormat: vending.howMany(of: EnergyDrink()))
        self.softdrinkStock.text = String(amountFormat: vending.howMany(of: SoftDrink()))
    }

    private func setBalance() {
        guard let balance = vending?.showBalance else { return }
        self.balanceLabel.text = String(balanceFormat: balance())
        self.balanceLabel.adjustsFontSizeToFitWidth = true
        self.balanceLabel.textAlignment = .center
    }

    private func previousHistoryLog() {
        let list = (self.vending?.purchaseLog())!
        guard !(list.isEmpty) else {
            return
        }
        let historyImages = HistoryImageMaker().previousHistoryLog(log: list)
        historyImages.forEach( {self.view.addSubview($0)} )
    }

    private func updatePurchasedItemView(_ willPrint: (item: Beverage, index: Int?)) {
        guard let index = willPrint.index else {
            return
        }
        let purchasedItemImage = HistoryImageMaker().updatePurchasedItemView((willPrint.item, index))
        self.view.addSubview(purchasedItemImage)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moveToAdminView" {
            if let nextVC = segue.destination as? AdminViewController {
                nextVC.vending = self.vending
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

