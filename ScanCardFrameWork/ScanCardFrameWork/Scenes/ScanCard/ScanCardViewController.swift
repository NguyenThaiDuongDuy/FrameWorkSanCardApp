import AVKit
import UIKit
import Vision

public enum ScanMode {
    case auto
    case drawInfo
    case cardHolder
    case cardNumber
    case issueDate
    case expiryDate
    
    public static let allMode = [auto, drawInfo, cardHolder, cardNumber, issueDate, expiryDate]
    
    public var modeString: String {
        
        switch self {
        case .auto:
            return "auto"
            
        case .drawInfo:
        return "draw Info"
            
        case .cardHolder:
            return "Card Holder"
            
        case .cardNumber:
            return "Card Number"
            
        case .issueDate:
            return "Issue Date"
            
        case .expiryDate:
            return "Expiry Date"
        }
    }
}
open class ScanCardViewController: UIViewController {
    
    var scanMode: ScanMode
    var viewModel: ScanCardViewModel?
    //public weak var delegate: ScanCardViewControllerDelegate?
    
    private let scanButtonTitle = "Scan"
    private let scanNavigationTitle = "Scan Card"
    private let languages = ["En", "Vn"]
    private let numberOfComponent = 1
    
    @IBOutlet weak var liveVideoView: PreviewView!
    @IBOutlet weak var scanButton: BlueStyleButton!
    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var languagePickerView: UIPickerView!
    
    private var boundingBoxLayer: CALayer?
    private var cardRectangleObservation: VNRectangleObservation?
    private var sampleBuffer: CMSampleBuffer?
    private var recognizedStrings: [String]?
    
    private lazy var service: CameraService = {
        let service = CameraService(viewController: self)
        return service
    }()
    
    public init(scanMode: ScanMode = .cardHolder) {
        self.scanMode = scanMode
        super.init(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setLanguageForView()
        setUpNavigationController()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpLiveView()
        setUpLanguageChosenView()
    }
    
    private func setUpLanguageChosenView() {
        languagePickerView.delegate = self
        languagePickerView.dataSource = self
    }
    
    private func setUpLiveView() {
        liveVideoView.videoPreviewLayer.videoGravity = .resizeAspectFill
        liveVideoView.videoPreviewLayer.cornerRadius = 30
        liveVideoView.videoPreviewLayer.masksToBounds = true
        liveVideoView.translatesAutoresizingMaskIntoConstraints = false
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(tapLiveVideoView))
        liveVideoView.addGestureRecognizer(tapAction)
    }
    
    private func setUpNavigationController() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(),
                                                               for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    @objc func tapLiveVideoView() {
        service.session.stopRunning()
        guard let cardRectangleObservation = self.cardRectangleObservation,
              let sampleBuffer = self.sampleBuffer else { return }
        guard let imageBuffer = sampleBuffer.imageBuffer else { return }
        let cropFrame = extractPerspectiveRect(cardRectangleObservation, from: imageBuffer)
        dismiss(animated: true) {
            self.service.stopConnectCamera()
            switch self.scanMode {
            case .cardHolder, .cardNumber, .expiryDate, .issueDate:
                let scanTextView = ScanTextViewController(cardImage: cropFrame, mode: self.scanMode)
                self.navigationController?.pushViewController(scanTextView, animated: true)
            case .auto, .drawInfo:
                self.viewModel = ScanCardViewModel(image: cropFrame, scanMode: self.scanMode)
                self.viewModel?.delegate = self
                self.viewModel?.getInfoCard()
            }
        }
    }
    
    private func setLanguageForView() {
        scanButton.setTitle(Language.share.localized(string: scanButtonTitle), for: .normal)
        title = Language.share.localized(string: scanNavigationTitle)
    }
    
    @IBAction func tapScanButton(_ sender: Any) {
        requestUsingCamera { (canUse) in
            if canUse {
                DispatchQueue.main.async {
                    self.liveVideoView.videoPreviewLayer.session = self.service.session
                    self.service.startConnectCamera()
                }
            }
        }
    }
    
    func requestUsingCamera(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            Logger.log("User authorized")
            completion(true)
            
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    Logger.log("User granted")
                    completion(true)
                } else {
                    Logger.log("User not granted")
                    completion(false)
                }
            }
            
        case .denied: // The user has previously denied access.
            // Show dialog
            completion(false)
            Logger.log("User denied")
            
        case .restricted: // The user can't grant access due to restrictions.
            completion(false)
            Logger.log("User restricted")
            
        @unknown default:
            completion(false)
            Logger.log("Something came up")
        }
    }
}

extension ScanCardViewController: ScanCardModelDelegate {
    func didGetInfoCardAuto(infoCard: [String]) {
        let infoCardDataDict:[String: [String]] = ["infoCard": infoCard]
        let nameNotify = Notification.Name("infoFromScanCardViewController")
        NotificationCenter.default.post(name: nameNotify, object: nil, userInfo: infoCardDataDict)
        navigationController?.popViewController(animated: true)
    }
}

extension ScanCardViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput,
                              didOutput sampleBuffer: CMSampleBuffer,
                              from connection: AVCaptureConnection) {
        DispatchQueue.main.async {
            self.removeBoundingBox()
            ImageDetector.detectCard(sampleBuffer: sampleBuffer) { resultOfDetectCard in
                switch resultOfDetectCard {
                
                case .success(let rectangle):
                    self.drawBoundingBox(rect: rectangle)
                    self.sampleBuffer = sampleBuffer
                    self.cardRectangleObservation = rectangle
                    
                case .failure(let error):
                    Logger.log(error.localizedDescription)
                }
            }
        }
    }
    
    // Crop image in bounding box
    private func extractPerspectiveRect(_ observation: VNRectangleObservation, from buffer: CVImageBuffer) -> CIImage {
        // get the pixel buffer into Core Image
        let ciImage = CIImage(cvImageBuffer: buffer)
        
        // convert corners from normalized image coordinates to pixel coordinates
        let topLeft = observation.topLeft.convertToPixelCoordinate(to: ciImage.extent.size)
        let topRight = observation.topRight.convertToPixelCoordinate(to: ciImage.extent.size)
        let bottomLeft = observation.bottomLeft.convertToPixelCoordinate(to: ciImage.extent.size)
        let bottomRight = observation.bottomRight.convertToPixelCoordinate(to: ciImage.extent.size)
        
        // pass those to the filter to extract/rectify the image
        return ciImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: topLeft),
            "inputTopRight": CIVector(cgPoint: topRight),
            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
            "inputBottomRight": CIVector(cgPoint: bottomRight)
        ])
    }
    
    private func drawBoundingBox(rect: VNRectangleObservation) {
        let convertUIKitRect = VNImageRectForNormalizedRect(rect.boundingBox,
                                                            (Int)(liveVideoView.bounds.width),
                                                            (Int)(liveVideoView.bounds.height))
        boundingBoxLayer = CAShapeLayer()
        boundingBoxLayer?.frame = convertUIKitRect
        boundingBoxLayer?.cornerRadius = 10
        boundingBoxLayer?.opacity = 0.75
        boundingBoxLayer?.borderColor = UIColor.red.cgColor
        boundingBoxLayer?.borderWidth = 5.0
        liveVideoView.layer.addSublayer(boundingBoxLayer ?? CAShapeLayer())
    }
    
    private func removeBoundingBox() {
        boundingBoxLayer?.removeFromSuperlayer()
    }
}

extension ScanCardViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        numberOfComponent
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        languages.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int,
                           forComponent component: Int) -> NSAttributedString? {
        NSAttributedString(string: languages[row],
                           attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        Language.share.isEnglish = languages[row] == "En"
        setLanguageForView()
    }
}

class ScanCardViewModel {
    
    let maxCardNumber = 19
    let minCardNumber = 16
    var image: CIImage
    let scanMode: ScanMode
    weak var delegate: ScanCardModelDelegate?
    
    init(image: CIImage, scanMode: ScanMode) {
        self.image = image
        self.scanMode = scanMode
    }
    
    func getInfoCard() {
        let context = CIContext()
        guard let cgImage = context.createCGImage(image, from: image.extent) else {
            Logger.log("Can't created cgImage from image")
            return }
        ImageDetector.detectText(cgImage: cgImage) { (result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                
            case .success(let strings):
                self.sendInfo(info: strings)
            }
        }
    }
    
    private func sendInfo(info: [String]) {
        if self.scanMode == .auto {
            self.delegate?.didGetInfoCardAuto(infoCard: self.getInfoCardAuto(information: info))
        } else {
            self.delegate?.didGetInfoCardAuto(infoCard:info)
        }
    }
    
    
    
    func isValidCardNumber(cardNumber: String) -> Bool {
        let vowels: Set<Character> = [" "]
        var checkCardNumber = ""
        checkCardNumber = cardNumber
        checkCardNumber.removeAll(where: { vowels.contains($0) })
        
        if !checkCardNumber.isNumeric { return false }
        
        if checkCardNumber.count<minCardNumber || checkCardNumber.count>maxCardNumber {
            return false
        }
        return true
    }
    
    func isValidCardHolder(cardHolder: String) -> Bool {
        if !cardHolder.isOnlyUpCaseAndWhiteSpaceCharacter { return false }
        let nameAfterCutWhiteSpacesAndNewlines = cardHolder.components(separatedBy: .whitespacesAndNewlines)
            .filter({ !$0.isEmpty })
            .joined(separator: " ")
        return nameAfterCutWhiteSpacesAndNewlines.contains(" ")
    }
    
    func isValidIssueDate(checkIssueDate: String) -> Bool {
        let dateStringAfterFilter = String(checkIssueDate.getDateString())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        let inputDate = dateFormatter.date(from: dateStringAfterFilter)
        guard let checkInputDate = inputDate else {
            return false }
        return checkInputDate < Date()
    }
    
    func isValidExpiryDate(checkExpiryDate: String) -> Bool {
        let dateStringAfterFilter = String(checkExpiryDate.getDateString())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        let inputDate = dateFormatter.date(from: dateStringAfterFilter)
        guard let checkInputDate = inputDate else { return false }
        return checkInputDate > Date()
    }
    
    func getInfoCardAuto(information: [String]?) -> [String] {
        Logger.log(information as Any)
        var cardInfo = Card(cardHolder: "",
                            cardNumber: "",
                            issueDate: "",
                            expiryDate: "")
        guard let checkInformation = information else { return [] }
        
        for index in stride(from: checkInformation.count - 1, to: 0, by: -1) {
            
            if self.isValidCardHolder(cardHolder: checkInformation[index]) &&
                (((cardInfo.cardHolder.isEmpty))) {
                cardInfo.cardHolder = checkInformation[index]
            }
            
            if self.isValidCardNumber(cardNumber: checkInformation[index])
                && ((cardInfo.cardNumber.isEmpty)) {
                cardInfo.cardNumber = checkInformation[index]
            }
            
            if self.isValidIssueDate(checkIssueDate: checkInformation[index])
                && ((cardInfo.issueDate!.isEmpty)) {
                cardInfo.issueDate = String(checkInformation[index].getDateString())
            }
            
            if self.isValidExpiryDate(checkExpiryDate: checkInformation[index])
                && ((cardInfo.expiryDate!.isEmpty)) {
                cardInfo.expiryDate = String(checkInformation[index].getDateString())
            }
        }
        var tmp: [String] = []
        tmp.append("cardHolder: \(cardInfo.cardHolder)")
        tmp.append("cardNumber: \(cardInfo.cardNumber)")
        tmp.append("issueDate: \(cardInfo.issueDate!)")
        tmp.append("expiryDate: \(cardInfo.expiryDate!)")
        return tmp
    }
}

protocol ScanCardModelDelegate: AnyObject {
    func didGetInfoCardAuto(infoCard: [String])
}


