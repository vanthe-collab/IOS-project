//
//  DataTransaction.swift
//  ManagementSaveMoneyPersonal
//
//  Created by vanthe on 13/05/2026.
//

import Foundation

//Phân loại khoản tiền
enum TransactionType{
    case income //Tiền thu nhập
    case expense //Tiền tiêu
}

class Transaction{
    var id: String
    var title: String
    var amount: Double
    var type: TransactionType
    var date: Date
    
    init(id: String, title: String, amount: Double, type: TransactionType, date: Date) {
        self.id = id
        self.title = title
        self.amount = amount
        self.type = type
        self.date = date
    }
}
