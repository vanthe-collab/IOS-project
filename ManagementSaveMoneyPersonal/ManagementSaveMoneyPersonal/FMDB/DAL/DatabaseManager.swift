//
//  DatabaseManager.swift
//  ManagementSaveMoneyPersonal
//
//  Created by vanthe on 21/05/2026.
//

import UIKit
import OSLog

class MyDatabase {
    //tao bien co the su dung ben ngoai thong qua no
    static let shared = MyDatabase()
    //MARK: Cac thuoc tinh chung cua co so du lieu
    private let DB_NAME = "database_manager.sqlite"
    private let DB_PATH:String?
    private let db:FMDatabase?
    //MARK: cac thuoc tinh cua bag du lieu
    //1. Bang du lieu giao dich
    private let TRANSACTION_TABLE_NAME = "transactions"
    private let TRANSACTION_ID = "id"
    private let TRANSACTION_TITLE = "title"
    private let TRANSACTION_AMOUNT = "amount"
    private let TRANSACTION_TYPE = "type"
    private let TRANSACTION_DATE = "date"
    
    //MARK: Dinh nghia cac ham premitives cho tang co so du lieu
    private init(){
        let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)
        DB_PATH = directories[0] + "/" + DB_NAME
        
        db = FMDatabase(path: DB_PATH)
        if let db = db {
            if db.open(){
                print("Mo database thanh cong tai \(String(describing: DB_PATH))")
                createTable()
                db.close()
            }else{
                print("Khoi tao database ko thanh cong")
            }
        }
    }
    //MARK: Dinh nghia cac API lay ra
    //Khoi tao cac bang du lieu
    private func createTable(){
        if let safeDB = db {
            if !safeDB.tableExists(TRANSACTION_TABLE_NAME) {
                let sql = "CREATE TABLE \(TRANSACTION_TABLE_NAME) (" +
                "\(TRANSACTION_ID) TEXT PRIMARY KEY, " +
                "\(TRANSACTION_TITLE) TEXT, " +
                "\(TRANSACTION_AMOUNT) REAL, " +
                "\(TRANSACTION_TYPE) INTEGER, " +
                "\(TRANSACTION_DATE) REAL)"
                        
                if safeDB.executeUpdate(sql, withArgumentsIn: []) {
                    print("Da tao bang thanh cong")
                }
            }
        } else {
            print("Lỗi: Database chưa được khởi tạo, không thể tạo bảng!")
        }
    }
    //Khoi tao ham them giao dich
    func insertTable(transaction: Transaction) {
        // 1. Kiểm tra xem db có tồn tại không
        if let safeDB = db {
            // 2. Kiểm tra xem có mở được không
            if safeDB.open() {
                let typeInt = (transaction.type == .income) ? 1 : 0
                let dateDouble = transaction.date.timeIntervalSince1970
                    
                let sql = "INSERT INTO \(TRANSACTION_TABLE_NAME) (\(TRANSACTION_ID), \(TRANSACTION_TITLE), \(TRANSACTION_AMOUNT), \(TRANSACTION_TYPE), \(TRANSACTION_DATE)) VALUES (?, ?, ?, ?, ?)"
                
                if safeDB.executeUpdate(sql, withArgumentsIn: [transaction.id, transaction.title, transaction.amount, typeInt, dateDouble]) {
                        print("Đã lưu xuống Database: \(transaction.title)")
                }
                safeDB.close()
                } else {
                    print("Lỗi: Không thể mở Database để thêm dữ liệu!")
                }
            } else {
            print("Lỗi: Database chưa được khởi tạo!")
        }
    }
    
    //khoi tao ham lay tat ca giao dich
    func getAllTransactions() -> [Transaction] {
        var list: [Transaction] = []
        // 1. Kiểm tra xem db có tồn tại không
            if let safeDB = db {
                // 2. Kiểm tra xem có mở được không
                if safeDB.open() {
                    let sql = "SELECT * FROM \(TRANSACTION_TABLE_NAME) ORDER BY \(TRANSACTION_DATE) DESC"
                
                    do {
                        let rs = try safeDB.executeQuery(sql, values: nil)
                        while rs.next() {
                            // Đọc dữ liệu lên
                            let id = rs.string(forColumn: TRANSACTION_ID) ?? ""
                            let title = rs.string(forColumn: TRANSACTION_TITLE) ?? ""
                            let amount = rs.double(forColumn: TRANSACTION_AMOUNT)
                            let typeInt = Int(rs.int(forColumn: TRANSACTION_TYPE))
                            let dateDouble = rs.double(forColumn: TRANSACTION_DATE)
                            
                            // Ép ngược kiểu lại cho giống với Model
                            let type: TransactionType = (typeInt == 1) ? .income : .expense
                            let date = Date(timeIntervalSince1970: dateDouble)
                            let item = Transaction(id: id, title: title, amount: amount, type: type, date: date)
                            
                            //Thêm vào list
                            list.append(item)
                        }
                    } catch {
                        print("Lỗi đọc dữ liệu: \(error.localizedDescription)")
                    }
                    
                    safeDB.close()
                    
                } else {
                    print("Lỗi: Không thể mở cửa kho Database để đọc!")
                }
            } else {
            print("Lỗi: Database chưa được khởi tạo!")
        }
            
        return list
    }
    //Khoi tao ham sua giao dich
    func updateTable(transaction: Transaction){
        if let safeDb = db{
            if safeDb.open(){
                //ép kiểu biến enum type qua Int
                let typeInt = (transaction.type == .income) ? 1 : 0
                let dateDouble = transaction.date.timeIntervalSince1970
                
                let sql = "UPDATE \(TRANSACTION_TABLE_NAME) SET \(TRANSACTION_TITLE) = ?, \(TRANSACTION_AMOUNT) = ?, \(TRANSACTION_TYPE) = ?, \(TRANSACTION_DATE) = ? WHERE \(TRANSACTION_ID) = ?"
                if safeDb.executeUpdate(sql, withArgumentsIn:   [transaction.title,transaction.amount,typeInt,dateDouble, transaction.id]){
                    print("Đã cập nhật \(TRANSACTION_TITLE)")
                }
                safeDb.close()
            }
        }
        
    }
    //khoi tao ham xoa giao dich
    func delete(id: String){
        if let safeDb = db{
            if safeDb.open(){
                let sql = "DELETE FROM \(TRANSACTION_TABLE_NAME) WHERE \(TRANSACTION_ID) = ?"
                        
                if safeDb.executeUpdate(sql, withArgumentsIn: [id]) {
                    print("Đã xóa khỏi ổ cứng giao dịch có ID: \(id)")
                }
                safeDb.close()
            }
        }
        
    }
}

