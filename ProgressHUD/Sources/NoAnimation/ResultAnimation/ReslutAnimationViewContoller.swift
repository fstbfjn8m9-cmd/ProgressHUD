
import UIKit

public class ReslutAnimationViewContoller: UIViewController, SpecialAnimationDelegate {
    public func buttonTapped(isResult: Bool, fl1IsSecond: Bool?, premium: SubscriptionModel?) {
        delegate?.buttonTapped(isResult: isResult, fl1IsSecond: nil, premium: nil)
    }
    
    private let isVerySmallDevice = UIScreen.main.nativeBounds.height <= 1136
    
    public func eventsFunc(event: EventsName) {
        delegate?.eventsFunc(event: event)
    }
    
//    public func buttonTapped(isResult: Bool) {
//        delegate?.buttonTapped(isResult: isResult, fl1IsSecond: nil)
//    }
    
    public func scanButtonTapped() {}
    
    private let resultView = ResultAnimationView.instanceFromNib()
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .label
        button.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    public var model: AuthorizationOfferModel?
    public var isPaid: Bool {
        didSet {
            resultView.setup(with: model, isTarifPaidAndActive: isPaid)
        }
    }
    
    weak var delegate: SpecialAnimationDelegate?
    
    public init(_ model: AuthorizationOfferModel? = nil, isPaid: Bool, delegate: SpecialAnimationDelegate?) {
        self.model = model
        self.delegate = delegate
        self.isPaid = isPaid
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(resource: .localBG)
        
        if !ProgressHUD.shared.isShow {
            if let secureView = SecureField().secureContainer {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    let containerView = UIView()
                    
                    containerView.backgroundColor = UIColor(resource: .localBG)
                    containerView.addSubview(secureView)
                    secureView.addSubview(resultView)
                    secureView.snp.makeConstraints({$0.edges.equalToSuperview()})
                    self.view.addSubview(containerView)
                    
                    containerView.snp.makeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                    
                    resultView.snp.makeConstraints { make in
                        make.center.equalToSuperview()
                        make.height.equalTo(1032)
                        make.leading.trailing.equalToSuperview().inset(100)
                    }
                } else {
                    let scrollView = UIScrollView()
                    
                    scrollView.backgroundColor = UIColor(resource: .localBG)
                    scrollView.isScrollEnabled = true
                    scrollView.showsVerticalScrollIndicator = false
                    view.addSubview(scrollView)
                    scrollView.addSubview(secureView)
                    secureView.addSubview(resultView)
                    
                    scrollView.snp.makeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                    
                    secureView.snp.makeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                    
                    resultView.snp.makeConstraints { make in
                        make.edges.equalToSuperview()
                        make.width.equalTo(scrollView)
                    }
                }
            } else {
                // Fallback if secureView is nil
                if UIDevice.current.userInterfaceIdiom == .pad {
                    let containerView = UIView()
                    
                    containerView.backgroundColor = UIColor(resource: .localBG)
                    self.view.addSubview(containerView)
                    containerView.addSubview(resultView)
                    
                    containerView.snp.makeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                    
                    resultView.snp.makeConstraints { make in
                        make.center.equalToSuperview()
                        make.height.equalTo(1032)
                        make.leading.trailing.equalToSuperview().inset(100)
                    }
                } else {
                    let scrollView = UIScrollView()
                    
                    scrollView.backgroundColor = UIColor(resource: .localBG)
                    scrollView.isScrollEnabled = true
                    scrollView.showsVerticalScrollIndicator = false
                    view.addSubview(scrollView)
                    scrollView.addSubview(resultView)
                    
                    scrollView.snp.makeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                    
                    resultView.snp.makeConstraints { make in
                        make.edges.equalToSuperview()
                        make.width.equalTo(scrollView)
                    }
                }
            }
        } else {
            if UIDevice.current.userInterfaceIdiom == .pad {
                let containerView = UIView()
                
                containerView.backgroundColor = UIColor(resource: .localBG)
                self.view.addSubview(containerView)
                containerView.addSubview(resultView)
                
                containerView.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                
                resultView.snp.makeConstraints { make in
                    make.center.equalToSuperview()
                    make.height.equalTo(1032)
                    make.leading.trailing.equalToSuperview().inset(100)
                }
            } else {
                let scrollView = UIScrollView()
                
                scrollView.backgroundColor = UIColor(resource: .localBG)
                scrollView.isScrollEnabled = true
                scrollView.showsVerticalScrollIndicator = false
                view.addSubview(scrollView)
                scrollView.addSubview(resultView)
                
                scrollView.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                
                resultView.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                    make.width.equalTo(scrollView)
                }
            }
        }
        navigationController?.isNavigationBarHidden = true
        
        // Добавляем кнопку закрытия после всех view, чтобы она была наверху
        if ProgressHUD.shared.isXmarkShow {
            view.addSubview(closeButton)
            view.bringSubviewToFront(closeButton)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                closeButton.widthAnchor.constraint(equalToConstant: 30),
                closeButton.heightAnchor.constraint(equalToConstant: 30)
            ])
        }
        
        resultView.tariffButtonTapped = { [weak self] in
            guard let self else { return }
            
            //            let vc = SuperAnimationViewController(price: nil, delegate: self)
            //
            //            vc.modalPresentationStyle = .fullScreen
            //
            //            self.navigationController?.present(vc, animated: true)
            self.delegate?.buttonTapped(isResult: true, fl1IsSecond: nil, premium: nil)
        }
        
        resultView.openSheetVCTapped = { [weak self] in
            guard let self else { return }
            
            let vc = SheetViewController(model?.sheet, delegate: self.delegate) {
                self.resultView.setup(with: self.model, isTarifPaidAndActive: self.isPaid)
            }
            
            vc.modalPresentationStyle = .overCurrentContext
            self.navigationController?.present(vc, animated: false)
        }
        
        resultView.sendEvent = { [weak self] event in
            self?.delegate?.eventsFunc(event: event)
        }
        
        resultView.showStatistView = { [weak self] in
            guard let self else { return }
            
            let statisticsView = StatsView()
            statisticsView.setup(with: model, isPaid: isPaid)
            statisticsView.show(in: self)
        }
        
        resultView.scanButtonTaped = { [weak self] in
            guard let self, let gap = model?.gap else { return }
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            if isPaid {
                let vc = NewAnimationOneViewController(model: gap.objecs[1],
                                                       title: gap.titleDeep,
                                                       isFromRsult: true,
                                                       delegate: self.delegate)
                self.navigationController?.pushViewController(vc, animated: true)
                self.delegate?.scanButtonTapped()
            } else {
                switch gap.orderIndex {
                case 0:
                    self.delegate?.buttonTapped(isResult: true, fl1IsSecond: nil, premium: nil)
                    return
//                case 2:
//                    let vc = NewAnimationTwoViewController(model: gap.objecs[1], alertModel: gap.objecs[0], title: gap.title, delegate: self.delegate)
//                    self.navigationController?.pushViewController(vc, animated: true)
//                    self.delegate?.scanButtonTapped()
//                case 3:
//                    let vc = NewAnimationThreeViewController(model: gap.objecs[2], alertModel: gap.objecs[0], title: gap.title, delegate: self.delegate)
//                    self.navigationController?.pushViewController(vc, animated: true)
//                    self.delegate?.scanButtonTapped()
//                case 4:
//                    let vc = NewAnimationFourViewController(model: gap.objecs[3], alertModel: gap.objecs[0], title: gap.titleTwo, delegate: self.delegate)
//                    self.navigationController?.pushViewController(vc, animated: true)
//                    self.delegate?.scanButtonTapped()
                default:
                    let vc = NewAnimationOneViewController(model: gap.objecs[0], title: gap.title, isFromRsult: false, delegate: self.delegate)
                    self.navigationController?.pushViewController(vc, animated: true)
                    self.delegate?.scanButtonTapped()
                    
                }
            }
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        eventsFunc(event: .specialOffer5Show)
        resultView.setup(with: model, isTarifPaidAndActive: isPaid)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        resultView.timerBzz?.invalidate()
    }
    
    @objc private func closeButtonTapped() {
        // Уведомляем делегата о закрытии
        delegate?.eventsFunc(event: .resultScreenDismissed)
        
        // Закрываем весь navigation controller
        if let navigationController = self.navigationController {
            navigationController.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

final class SecureField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.isSecureTextEntry = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var secureContainer: UIView? {
        let secureView = self.subviews.filter({ subview in
            type(of: subview).description().contains("CanvasView")
        }).first
        secureView?.translatesAutoresizingMaskIntoConstraints = false
        secureView?.isUserInteractionEnabled = true
        
        return secureView
    }
    
    override var canBecomeFirstResponder: Bool {false}
    override func becomeFirstResponder() -> Bool {false}
}
