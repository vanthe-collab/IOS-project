import UIKit

class ViewController: UIViewController {
    //MARK: - IBOutlets
    
    @IBOutlet weak var lblMonthYear: UILabel!
    @IBOutlet weak var lblExpend: UILabel!
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var lblIncome: UILabel!
    @IBOutlet weak var lblNganSach: UILabel!
    @IBOutlet weak var lblConLai: UILabel!
    //white UIView
    @IBOutlet weak var budgetProgressView: UIProgressView!
    @IBOutlet weak var lblRemaining: UILabel!
    @IBOutlet weak var bottomWhiteView: UIView!
    
    // Danh sách
    @IBOutlet weak var transactionTableView: UITableView!
    @IBOutlet weak var emptyStateViewStackView: UIStackView!
    
    //Button
    @IBOutlet weak var btnAddTransaction: UIButton!
    
    //MARK: tao bien ngay thang hiện tại
    var selectedDay = Date()
    
    //bien luu so tien nguoi dung nhap
    var soTienNhap: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateMonthYear()
    }
    // Hàm này để làm đẹp UI
    func setupUI() {
            // 1. Bo 2 góc trên của View trắng
            bottomWhiteView.layer.cornerRadius = 20
            bottomWhiteView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
            // 2. Làm tròn nút dấu "+" (Giả sử nút của bạn có Width/Height là 60 trong Storyboard)
            btnAddTransaction.layer.cornerRadius = 30
            btnAddTransaction.layer.masksToBounds = true
    }
    
    //Ham cap nhat chu ngay thang lable lblMonthYear
    func updateMonthYear(){
        let calendar = Calendar.current
        let monthCalendar = calendar.component(.month, from: selectedDay)
        let yearCalendar = calendar.component(.year, from: selectedDay)
        
        lblMonthYear.text = "tháng \(monthCalendar) \(yearCalendar)"
    }
    
    //MARK: Ham xu ly nut thang tiep theo
    @IBAction func btnNextMonthYear(_ sender: UIButton) {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDay){
            selectedDay = newDate
            updateMonthYear()
        }
    }
    //MARK: Ham xu ly nut thang trước đó
    @IBAction func btnPreviousMonthYear(_ sender: UIButton) {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDay){
            selectedDay = newDate
            updateMonthYear()
        }
    } 
        
    //MARK: tinh toan lai thanh progressBar
    func updateProgressBarUI(){
        //tinh số tiền đã tiêu
        var tienTieuHao : Double = 0
        /*for item in transactions {
            tienTieuHao += item
        }*/
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        //kiem tra so xem nguoi dung nhap chua
        if soTienNhap <= 0{
            lblNganSach.text = "Thiết lập ngân sách hàng tháng"
            lblConLai.isHidden = true
            lblRemaining.isHidden = true
        }else
        {
            //nguoi dung da nhap roi thay text hien lable
            lblConLai.isHidden = false
            lblRemaining.isHidden = false
            
            //chuyển số vừa nhập sang string
            let DaNhap = formatter.string(from: NSNumber(value: soTienNhap)) ?? "0"
            lblNganSach.text = "Thu nhập hàng tháng: \(DaNhap) đ"
            
            //tính số tiền còn lại
            let soTienConLai = soTienNhap - tienTieuHao
            let soTienConLaiStr = formatter.string(from: NSNumber(value: soTienConLai)) ?? "0"
            
            //kiểm tra số tiền còn lại là âm hay dương
            if(soTienConLai >= 0){
                lblRemaining.text = "+\(soTienConLaiStr)"
            }else {
                lblRemaining.text = "-\(soTienConLaiStr)"
            }
            
            //setup cho progressBar đổi màu
            let ratio = Float(tienTieuHao/soTienNhap)
            budgetProgressView.progress = min(ratio,1.0)
            
            //đổi màu cho progressBar nếu xài lố
            budgetProgressView.progressTintColor = ratio > 1.0 ? .systemRed : .systemBlue
        }
    }
    //MARK: Bắt sự kiện cho progressBar
    
    @IBAction func progressTapped(_ sender: UITapGestureRecognizer) {
        //hiển thị hộp thoại
        let alert = UIAlertController(title: "Thu nhập hàng tháng",
                                      message: "Nhập số tiền ngân sách cho tháng này",
                                      preferredStyle: .alert)
        // Thêm ô nhập liệu (TextField) vào Alert
        alert.addTextField { textField in
            textField.placeholder = "Ví dụ: 10000000"
            textField.keyboardType = .numberPad // chỉ hiện bàn phím số
    
                    // Nếu đã có số cũ thì hiện ra luôn
            if self.soTienNhap > 0 {
                textField.text = String(format: "%.0f", self.soTienNhap)
            }
        }
        // Nút "Xác nhận"
        let confirmAction = UIAlertAction(title: "Xác nhận", style: .default) { _ in
            if let tf = alert.textFields?.first, let text = tf.text, let amount = Double(text) {
                    self.soTienNhap = amount
                self.updateProgressBarUI() // Cập nhật lại thanh Bar và Label
            }
        }
        // Nút "Hủy"
        let cancelAction = UIAlertAction(title: "Hủy", style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}

