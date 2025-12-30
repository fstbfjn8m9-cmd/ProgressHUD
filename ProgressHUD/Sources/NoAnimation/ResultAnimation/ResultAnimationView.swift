

import UIKit
import Lottie
import AudioToolbox

protocol InstanceFromNibProtocol {
    associatedtype InstanceFromNibType: UIView
    static func instanceFromNib() -> InstanceFromNibType
}

extension InstanceFromNibProtocol {
    static func instanceFromNib() -> InstanceFromNibType {
        let loadedNib = Bundle.module.loadNibNamed(InstanceFromNibType.className, owner: self, options: nil)
        
        return loadedNib?.first as! InstanceFromNibType
    }
}

extension UIView {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}

class ResultAnimationView: UIView, InstanceFromNibProtocol {
    typealias InstanceFromNibType = ResultAnimationView
    
    private let isSmallDevice = UIScreen.main.nativeBounds.height <= 1334
    private let isVerySmallDevice = UIScreen.main.nativeBounds.height <= 1136
    private let isMiniScreen = UIScreen.main.nativeBounds.height > 2208 && UIScreen.main.nativeBounds.height <= 2340
    private let isPlusScreenDevice = UIScreen.main.nativeBounds.height == 2208
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var animationTitle: UILabel!
    @IBOutlet weak var animationSubtitle: UILabel!
    @IBOutlet weak var bannerContainer: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var topConst: NSLayoutConstraint!
    @IBOutlet weak var inactiveImageView: UIImageView!
    
    @IBOutlet weak var lhConst: NSLayoutConstraint!
    @IBOutlet weak var lwConst: NSLayoutConstraint!
    @IBOutlet weak var subTop: NSLayoutConstraint!
    @IBOutlet weak var animTop: NSLayoutConstraint!
    @IBOutlet weak var bannerTop: NSLayoutConstraint!
    @IBOutlet weak var stackheigt: NSLayoutConstraint!
    @IBOutlet weak var stackWidth: NSLayoutConstraint!
    @IBOutlet weak var circularLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var circularTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var circularBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var circularTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bannerHeight: NSLayoutConstraint!
    private let bannerView = SpinnerView.instanceFromNib()
    private var model: AuthorizationOfferModel?
    private var isTarifPaidAndActive: Bool?
    private var couter = 0
    private var progress: Float = 0
    @IBOutlet weak var circularProgress: CircularProgressView!
    private let statsViewButton = CustomStatsButton()
    
    private var timer: Timer?
    var timerBzz: Timer?
    
    var tariffButtonTapped: (() -> Void)?
    var openSheetVCTapped: (() -> Void)?
    var sendEvent: ((EventsName) -> Void)?
    var scanButtonTaped: (() -> Void)?
    var showStatistView: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
            subtitleLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
            animationTitle.font = UIFont.systemFont(ofSize: 30, weight: .bold)
            lhConst.constant = 420
            lwConst.constant = 420
            circularLeadingConstraint.constant = 72
            circularTopConstraint.constant = 72
            circularBottomConstraint.constant = -72
            circularTrailingConstraint.constant = -72
            bannerHeight.constant = 421
            inactiveImageView.contentMode = .scaleToFill
            stackheigt.constant = 215
            stackWidth.constant = 192
            topConst.constant = 10
            bannerTop.constant = 0
            
            layoutIfNeeded()
        } else {
            bannerHeight.constant = 380
            
            if isVerySmallDevice {
                bannerHeight.constant = 500
                stackheigt.constant = 130
                stackWidth.constant = 130
                topConst.constant = 15
                subTop.constant = 5
                animTop.constant = 0
                bannerTop.constant = 0
                lhConst.constant = 250
                lwConst.constant = 250
                circularLeadingConstraint.constant = 42
                circularTopConstraint.constant = 42
                circularBottomConstraint.constant = -42
                circularTrailingConstraint.constant = -42
                inactiveImageView.contentMode = .scaleAspectFit
                titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
                subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                animationTitle.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                
                layoutIfNeeded()
            } else if isSmallDevice {
                stackheigt.constant = 130
                stackWidth.constant = 130
                topConst.constant = 4
                subTop.constant = -2
                animTop.constant = -8
                bannerTop.constant = -10
                lhConst.constant = 248
                lwConst.constant = 248
                circularLeadingConstraint.constant = 41
                circularTopConstraint.constant = 41
                circularBottomConstraint.constant = -41
                circularTrailingConstraint.constant = -41
                inactiveImageView.contentMode = .scaleAspectFit
                
                titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
                subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                bringSubviewToFront(subtitleLabel)
                animationTitle.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                
                layoutIfNeeded()
            } else if isPlusScreenDevice {
                topConst.constant = 5
                subTop.constant = -2
                
                titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
                subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                bringSubviewToFront(subtitleLabel)
                layoutIfNeeded()
            } else if isMiniScreen {
                topConst.constant = 0
                subTop.constant = 3
                layoutIfNeeded()
            } else {
                topConst.constant = 10
                subTop.constant = 7
                layoutIfNeeded()
            }
        }
        
        circularProgress.configureProgressViewToBeCircular()
        inactiveImageView.backgroundColor = .clear
        inactiveImageView.image = UIImage(resource: .inActiveSub)
        
        circularProgress.setProgressColor = UIColor().hexStringToUIColor(hex: "#65D65C")
        circularProgress.setTrackColor = UIColor(displayP3Red: 205.0/255.0, green: 247.0/255.0, blue: 212.0/255.0, alpha: 1.0)
        
        bannerContainer.addSubview(statsViewButton)
        bannerContainer.addSubview(bannerView)
        
        statsViewButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
        
        bannerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(statsViewButton.snp.top).offset(-5)
        }
        
        bannerView.tariffButtonTapped = { [weak self] in
            self?.tariffButtonTapped?()
        }
        
        bannerView.progressSwitchTapped = { [weak self] isOn in
            self?.setup(with: self?.model, isTarifPaidAndActive: self?.isTarifPaidAndActive ?? false)
        }
        
        bannerView.goEvent = { [weak self] event in
            self?.sendEvent?(event)
        }
        
        bannerView.openSheetVCTapped = { [weak self] in
            self?.openSheetVCTapped?()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(scanButtonTap))
        
        stackView.addGestureRecognizer(tap)
    }
    
    func setup(with model: AuthorizationOfferModel?, isTarifPaidAndActive: Bool) {
        self.isTarifPaidAndActive = isTarifPaidAndActive
        self.model = model
//        bannerView.setup(with: model, isPaid: isTarifPaidAndActive)
        bannerView.setup(with: model, isPaid: isTarifPaidAndActive, isFullActive: Storage.isAllFeaturesEnabled)
        backgroundColor = UIColor(resource: .localBG)
//        animationView.backgroundColor = .white
        animationView.backgroundColor = UIColor(resource: .localBG)
        bringSubviewToFront(titleLabel)
        
        statsViewButton.setup(with: model) { [weak self] in
            self?.showStatistView?()
        }
        
        if isTarifPaidAndActive {
            if Storage.isAllFeaturesEnabled, Storage.featuresStates.count == 4 {
                let attributedStrOne = NSMutableAttributedString(string: String(model?.scn?.subtitle_anim_compl?.dropLast(2) ?? ""), attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor().hexStringToUIColor(hex: "#000000"),
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 18 : (isSmallDevice ? (isVerySmallDevice ? 8 : 9) : 12), weight: .medium)
                ])
                let attributedStrTwo = NSMutableAttributedString(string: (model?.gap?.titleDeep ?? localizeText(forKey: .subsActive)), attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor().hexStringToUIColor(hex: "#65D65C"),
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 21 : (isSmallDevice ? (isVerySmallDevice ? 10 : 11) : 14), weight: .bold)
                ])
                attributedStrOne.append(attributedStrTwo)
                
                inactiveImageView.isHidden = true
                subtitleLabel.text = model?.scn?.subtitle_compl
                iconImageView.image = UIImage(resource: .vector)
                titleLabel.text = String(format: model?.scn?.title_compl ?? "", model?.scn?.title_on ?? localizeText(forKey: .subsOn))
                animationSubtitle.attributedText = attributedStrOne
                animationTitle.text = model?.scn?.title_anim_compl
                animationTitle.textColor = UIColor().hexStringToUIColor(hex: "#000000")
                
                guard let url = URL(string: model?.scn?.anim_done ?? "") else { return }
                
                animationView.isHidden = false
                if Constants.isDarkMode {
                    let bundle = Bundle.module
                    animationView.animation = LottieAnimation.named("protectedNew2")
                    animationView.play()
                } else {
                    LottieAnimation.loadedFrom(url: url, closure: { [weak self] animation in
                        self?.animationView.animation = animation
                        self?.animationView.play()
                    }, animationCache: DefaultAnimationCache.sharedCache)
                }
                
                
                circularLeadingConstraint.constant = UIDevice.current.userInterfaceIdiom == .pad ? 60 : (isSmallDevice ? (isVerySmallDevice ? 36 : 35) : 35)
                circularTopConstraint.constant = UIDevice.current.userInterfaceIdiom == .pad ? 60 : (isSmallDevice ? (isVerySmallDevice ? 36 : 35) : 35)
                circularBottomConstraint.constant = UIDevice.current.userInterfaceIdiom == .pad ? -60 : (isSmallDevice ? (isVerySmallDevice ? -35 : -34) : -35)
                circularTrailingConstraint.constant = UIDevice.current.userInterfaceIdiom == .pad ? -60 : (isSmallDevice ? (isVerySmallDevice ? -35 : -34) : -35)
                layoutIfNeeded()
            } else {
                let attributedStrOne = NSMutableAttributedString(string: String(model?.scn?.subtitle_anim_compl?.dropLast(2) ?? ""), attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor.label /*UIColor().hexStringToUIColor(hex: "#000000")*/,
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 18 : (isSmallDevice ? (isVerySmallDevice ? 10 : 11) : 12), weight: .medium)
                ])
                let attributedStrTwo = NSMutableAttributedString(string: "\n" + (model?.gap?.titleDeep ?? localizeText(forKey: .subsActive)), attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor().hexStringToUIColor(hex: "#65D65C"),
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 21 : (isSmallDevice ? (isVerySmallDevice ? 12 : 13) : 14), weight: .bold)
                ])
                attributedStrOne.append(attributedStrTwo)
                
                animationView.isHidden = true
                inactiveImageView.isHidden = false
                animationTitle.text = model?.scn?.title_anim_unp
                subtitleLabel.text = model?.scn?.subtitle_unp
                iconImageView.image = UIImage(resource: .inVector)
                titleLabel.text = String(format: model?.scn?.title_compl ?? "", model?.scn?.disabled ?? localizeText(forKey: .subsDis))
                animationSubtitle.attributedText = attributedStrOne
                animationTitle.textColor = UIColor.label
                
                circularLeadingConstraint.constant = UIDevice.current.userInterfaceIdiom == .pad ? 72 : (isSmallDevice ? (isVerySmallDevice ? 42 : 41) : 30)
                circularTopConstraint.constant = UIDevice.current.userInterfaceIdiom == .pad ? 72 : (isSmallDevice ? (isVerySmallDevice ? 42 : 41) : 30)
                circularBottomConstraint.constant = UIDevice.current.userInterfaceIdiom == .pad ? -72 : (isSmallDevice ? (isVerySmallDevice ? -42 : -41) : -30)
                circularTrailingConstraint.constant = UIDevice.current.userInterfaceIdiom == .pad ? -72 : (isSmallDevice ? (isVerySmallDevice ? -42 : -41) : -30)
                layoutIfNeeded()
            }
            
            circularProgress.isHidden = false
            progress = 0
            
            let totalFeatures = 4
            let trueCount = Storage.featuresStates.values.filter { $0 }.count
            let progress = Float(trueCount) / Float(totalFeatures)

            circularProgress.setProgressWithAnimation(duration: 0.7, value: progress)
        } else {
            bannerView.setup(with: model, isPaid: isTarifPaidAndActive, isFullActive: false)
            let attributedStrOne = NSMutableAttributedString(string: String(model?.scn?.subtitle_anim_compl?.dropLast(2) ?? ""), attributes: [
                NSAttributedString.Key.foregroundColor: UIColor().hexStringToUIColor(hex: "#000000"),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: (isSmallDevice ? (isVerySmallDevice ? 10 : 11) : 12), weight: .medium)
            ])
            let attributedStrTwo = NSMutableAttributedString(string: "\n" + (model?.gap?.titleDeep ?? localizeText(forKey: .subsActive)), attributes: [
                NSAttributedString.Key.foregroundColor: UIColor().hexStringToUIColor(hex: "#E74444"),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: (isSmallDevice ? (isVerySmallDevice ? 12 : 13) : 14), weight: .bold)
            ])
            attributedStrOne.append(attributedStrTwo)
            
            circularProgress.isHidden = true
            titleLabel.text = String(format: model?.scn?.title_compl ?? "", model?.scn?.disabled ?? localizeText(forKey: .subsDis))
            subtitleLabel.text = model?.scn?.subtitle_unp
            animationTitle.text = model?.scn?.title_anim_unp
            animationSubtitle.attributedText = attributedStrOne
            animationView.isHidden = true
            inactiveImageView.isHidden = false
            iconImageView.image = UIImage(resource: .inVector)
        }
    }
    
    @objc func bzzz() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    @objc func scanButtonTap() {
        scanButtonTaped?()
    }
}

final class Storage {
    static var featuresStates: [Int: Bool] {
        get {
            if let data = UserDefaults.standard.object(forKey: "featuresStates") as? Data,
               let value = try? JSONDecoder().decode([Int: Bool].self, from: data) {
                
                return value
            }
            
            return [:]
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: "featuresStates")
            }
        }
    }
    
    static var isAllFeaturesEnabled: Bool {
        featuresStates.values.allSatisfy { $0 == true }
    }
    
    static var isMscActive: Bool? {
        get {
            let castedValue = UserDefaults.standard.object(forKey: "isMscActive")
            
            return castedValue as? Bool
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isMscActive")
        }
    }
    
    static var lastDate: Date? {
        get {
            let castedValue = UserDefaults.standard.object(forKey: "lastDate")
            
            return castedValue as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastDate")
        }
    }
    
    static var toggleState: Bool? {
        get {
            let castedValue = UserDefaults.standard.object(forKey: "toggleState")
            
            return castedValue as? Bool
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "toggleState")
        }
    }
}
