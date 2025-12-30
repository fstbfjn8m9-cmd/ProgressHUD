
import UIKit
import ScreenShield

public final class FlRFirstAnimationVC: UIViewController {

    // MARK: - UI Elements

    private let titleCont: UIView = {
        let titleCont = UIView()
        
        titleCont.backgroundColor = UIColor(resource: .localRContainer)
        titleCont.layer.cornerRadius = 40
        titleCont.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        titleCont.backgroundColor = UIColor(resource: .resultContainerNew)
        titleCont.translatesAutoresizingMaskIntoConstraints = false
        
        return titleCont
    }()
            
    private let headerIconImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()

        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = UIColor.label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    private let lastScanLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private let protectionSwitch = UISwitch()
    
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
    weak var delegate: SpecialAnimationDelegate?
    public var isPaid: Bool {
        didSet {
            checkToggleState()
        }
    }
    
    public init(_ model: AuthorizationOfferModel? = nil, delegate: SpecialAnimationDelegate?, isPaid: Bool) {
        self.model = model
        self.delegate = delegate
        self.isPaid = isPaid
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.systemGroupedBackground

        setupUI()
        configureLastScanDate()
        setupCloseButton()
        
        if !ProgressHUD.shared.isShow {
            ScreenShield.shared.protect(view: self.titleCont)
            ScreenShield.shared.protect(view: self.headerIconImageView)
            ScreenShield.shared.protect(view: self.titleLabel)
            ScreenShield.shared.protect(view: self.lastScanLabel)
            ScreenShield.shared.protect(view: self.protectionSwitch)
            ScreenShield.shared.protectFromScreenRecording()
        }
    }
    
    private func setupCloseButton() {
        guard ProgressHUD.shared.isXmarkShow else { return }
        
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
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    private func checkToggleState() {
        if isPaid, let state = Storage.toggleState {
            protectionSwitch.isOn = state
        } else {
            protectionSwitch.isOn = false
        }
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.addSubview(titleCont)
        titleCont.addSubview(headerIconImageView)
        titleCont.addSubview(titleLabel)
        titleCont.addSubview(lastScanLabel)
        view.addSubview(mainStackView)

        let protectionRow = createRealtimeProtectionRow()
        let systemRow = createSystemRow()
        let sepereatorView = UIView()
        
        sepereatorView.backgroundColor = .gray
        
        NSLayoutConstraint.activate([
            sepereatorView.heightAnchor.constraint(equalToConstant: 1),
        ])
        
        mainStackView.addArrangedSubview(protectionRow)
        mainStackView.addArrangedSubview(sepereatorView)
        mainStackView.addArrangedSubview(systemRow)

        setupConstraints()
        
        guard let img1URL = URL(string: model?.result3?.result_img ?? "") else { return }
        
        headerIconImageView.kf.setImage(with: img1URL, placeholder: UIImage())
        
        titleLabel.text = model?.result3?.result_tl
        lastScanLabel.text = model?.result3?.result_subt
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header Section
            titleCont.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            titleCont.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            titleCont.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            
            headerIconImageView.topAnchor.constraint(equalTo: titleCont.topAnchor, constant: 65),
            headerIconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerIconImageView.widthAnchor.constraint(equalToConstant: 66),
            headerIconImageView.heightAnchor.constraint(equalToConstant: 66),

            titleLabel.topAnchor.constraint(equalTo: headerIconImageView.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            lastScanLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            lastScanLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lastScanLabel.bottomAnchor.constraint(equalTo: titleCont.bottomAnchor, constant: -25),
            
            // Main Stack View for Rows
            mainStackView.topAnchor.constraint(equalTo: titleCont.bottomAnchor, constant: 25),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    /// Configures the 'Last scan' date label with a locale-aware date format.
    private func configureLastScanDate() {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .short // Automatically handles locale (e.g., M/d/yy for US, d/M/yy for UK)
        dateFormatter.timeStyle = .none
        let todayString = dateFormatter.string(from: Storage.lastDate ?? Date())
        lastScanLabel.text = "Last scan: \(todayString)"
    }

    // MARK: - Row Creation Helpers

    private func createRealtimeProtectionRow() -> UIView {
        // Container for the row
        let container = UIView()
        container.backgroundColor = .clear // White in light, dark gray in dark
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false

        // Icon
        let iconView = UIImageView()
        iconView.layer.cornerRadius = 8
        iconView.translatesAutoresizingMaskIntoConstraints = false

        guard let img4URL = URL(string: model?.result3?.result_box2_img1 ?? "") else { return UIView() }
        
        iconView.kf.setImage(with: img4URL, placeholder: UIImage())
        
        // Labels
        let title = UILabel()
        title.text = model?.result3?.result_box2_tl
        title.font = .systemFont(ofSize: 17, weight: .semibold)
        title.textColor = .label
        
        let subtitle = UILabel()
        subtitle.text = model?.result3?.result_box2_subt
        subtitle.font = .systemFont(ofSize: 12, weight: .regular)
        subtitle.textColor = .secondaryLabel
        subtitle.numberOfLines = 2
        
        let labelStack = UIStackView(arrangedSubviews: [title, subtitle])
        labelStack.axis = .vertical
        labelStack.spacing = 2
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        
//        protectionSwitch.isOn = isPaid
        checkToggleState()
        protectionSwitch.addTarget(self, action: #selector(protectionSwitchChanged(_:)), for: .valueChanged)
        protectionSwitch.translatesAutoresizingMaskIntoConstraints = false

        // Add subviews to container
        container.addSubview(iconView)
        container.addSubview(labelStack)
        container.addSubview(protectionSwitch)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),

            labelStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            labelStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            labelStack.trailingAnchor.constraint(equalTo: protectionSwitch.leadingAnchor, constant: -8),
            
            protectionSwitch.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            protectionSwitch.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            // Set container height
            container.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        return container
    }

    private func createSystemRow() -> UIView {
        // Container for the row
        let container = UIView()
        container.backgroundColor = .clear
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false

        // Icon
        let iconView = UIImageView()
        iconView.tintColor = .systemGray
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        guard let img1URL = URL(string: model?.result3?.result_det_box1_img ?? "") else { return UIView() }
        
//        iconView.kf.setImage(with: img1URL, placeholder: UIImage(), options: [.processor(SVGImgProcessor())])
        iconView.kf.setImage(with: img1URL, placeholder: UIImage())
        
        // Label
        let title = UILabel()
        title.text = model?.pushTitle
        title.font = .systemFont(ofSize: 17, weight: .semibold)
        title.textColor = .label
        title.translatesAutoresizingMaskIntoConstraints = false
        
        // Scan Now Button
        let scanNowButton = UIButton(type: .system)
        let chevronImage = UIImage(systemName: "chevron.right")
        scanNowButton.setImage(chevronImage, for: .normal)
        scanNowButton.setTitle(model?.result3?.result_scan_now, for: .normal) // Note the space for padding
        scanNowButton.titleLabel?.font = .systemFont(ofSize: 17)
        scanNowButton.semanticContentAttribute = .forceRightToLeft // Puts image on the right
        scanNowButton.tintColor = .systemBlue
        scanNowButton.addTarget(self, action: #selector(scanNowTapped), for: .touchUpInside)
        scanNowButton.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(iconView)
        container.addSubview(title)
        container.addSubview(scanNowButton)
        
        // Make the whole container tappable
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(scanNowTapped))
        container.addGestureRecognizer(tapGesture)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44),
            
            title.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            title.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            scanNowButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            scanNowButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            // Set container height
            container.heightAnchor.constraint(equalToConstant: 70)
        ])

        return container
    }

    // MARK: - Actions

    @objc private func protectionSwitchChanged(_ sender: UISwitch) {
        guard !isPaid else {
            Storage.toggleState = sender.isOn
            
            return
        }
                
        self.delegate?.buttonTapped(isResult: true, fl1IsSecond: false, premium: nil)
        sender.setOn(false, animated: true)
    }

    @objc private func scanNowTapped() {
        let systemScanVC = FlRSecondAnimationVC(model, delegate: delegate, isPaid: isPaid)
        
        Storage.lastDate = Date()
        navigationController?.pushViewController(systemScanVC, animated: true)
    }
}
