
import UIKit

final class FlRSecondAnimationVC: UIViewController {

    // MARK: - UI Elements

    private let iconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()

    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        if #available(iOS 13.0, *) {
            imageView.image = UIImage(systemName: "checkmark.circle.fill")
            imageView.tintColor = .systemGreen
        }
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        imageView.alpha = 0
        imageView.backgroundColor = UIColor.systemBackground
        imageView.layer.cornerRadius = 10
        
        return imageView
    }()
    
    private let circlesImageView: UIImageView = {
        let imageView = UIImageView()

        imageView.image = UIImage(resource: .circlesLoading)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = UIColor.label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        return label
    }()
    
    private let progressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        
        pv.progress = 0.0
        pv.progressTintColor = .systemBlue
        pv.trackTintColor = UIColor.systemGray4
        pv.layer.cornerRadius = 4
        pv.clipsToBounds = true
        pv.translatesAutoresizingMaskIntoConstraints = false
        
        return pv
    }()

    private lazy var fixingButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle(model?.result3?.result_fixing, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = UIColor.clear
        button.setTitleColor(UIColor.secondaryLabel, for: .normal)
        button.layer.cornerRadius = 30
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        
        return button
    }()

    // MARK: - Properties
    private var timer: Timer?
    private var currentProgress: Float = 0.0
    private let totalDuration: TimeInterval = 4.5 // Total time for the scan
    private lazy var scanStatuses = [model?.flow1?.loading_subt_1, model?.flow1?.loading_subt_2, model?.flow1?.loading_subt_3]
    private var lastStatusIndex = -1

    public var model: AuthorizationOfferModel?
    weak var delegate: SpecialAnimationDelegate?
    public var isPaid: Bool
    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(resource: .localBG)
        setupUI()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startScanningAnimation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
        timer = nil
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(circlesImageView)
        view.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        iconContainerView.addSubview(checkmarkImageView)

        view.addSubview(titleLabel)
        view.addSubview(statusLabel)
        view.addSubview(progressView)
        view.addSubview(fixingButton)
        
        titleLabel.text = model?.flow1?.loading_tl
        
        guard let img1URL = URL(string: model?.result3?.result_det_box1_img ?? "") else { return }
        
//        iconImageView.kf.setImage(with: img1URL, placeholder: UIImage(), options: [.processor(SVGImgProcessor())])
        iconImageView.kf.setImage(with: img1URL, placeholder: UIImage())
    }

    private func setupConstraints() {
        let iconSize: CGFloat = 80
        let checkmarkSize: CGFloat = 25
        let horizontalPadding: CGFloat = 50

        NSLayoutConstraint.activate([
            // Icon Container (acts as an anchor for the main icon and checkmark)
            iconContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconContainerView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -20),
            iconContainerView.widthAnchor.constraint(equalToConstant: iconSize),
            iconContainerView.heightAnchor.constraint(equalToConstant: iconSize),

            circlesImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circlesImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            circlesImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            circlesImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Main Icon
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: iconSize),

            // Checkmark Badge
            checkmarkImageView.trailingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 5),
            checkmarkImageView.bottomAnchor.constraint(equalTo: iconContainerView.bottomAnchor, constant: 5),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: checkmarkSize),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: checkmarkSize),
            
            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -25), // Slightly above center

            // Status Label
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Progress View
            progressView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding),
            progressView.heightAnchor.constraint(equalToConstant: 8),

            // Fixing Button
            fixingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            fixingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            fixingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            fixingButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Animation Logic
    private func startScanningAnimation() {
        // Reset state
        currentProgress = 0.0
        lastStatusIndex = -1
        
        let updatesPerSecond: Double = 30.0
        let increment = 1.0 / (Float(totalDuration) * Float(updatesPerSecond))

        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / updatesPerSecond, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.currentProgress += increment
            
            // Update UI based on progress
            self.updateProgressUI()
            
            if self.currentProgress >= 1.0 {
                self.currentProgress = 1.0
                self.timer?.invalidate()
                self.timer = nil
                self.showCompletionState()
            }
        }
    }
    
    private func updateProgressUI() {
        // Update progress bar
        progressView.setProgress(currentProgress, animated: true)
        
        // Update status label based on progress segments
        let statusIndex = Int(currentProgress * Float(scanStatuses.count))
        
        if statusIndex < scanStatuses.count && statusIndex != lastStatusIndex {
            statusLabel.text = scanStatuses[statusIndex]
            lastStatusIndex = statusIndex
        }
    }
    
    private func showCompletionState() {
        // Final UI update to 100%
        self.progressView.setProgress(1.0, animated: true)
        
        // Animate the transition to the "secure" state
        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseInOut, animations: {
            self.titleLabel.text = self.model?.flow1?.scr4_tl
            
            // Fade out the progress elements and the button
            self.statusLabel.alpha = 0
            self.progressView.alpha = 0
            self.fixingButton.alpha = 0
            
            // Fade in the checkmark
            self.checkmarkImageView.isHidden = false
            self.checkmarkImageView.alpha = 1
            self.checkmarkImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3) // Pop effect
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                let vc = FlRFirstAnimationVC(self.model, delegate: self.delegate, isPaid: self.isPaid)
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }) { _ in
            // Clean up the hidden views from the hierarchy
            self.statusLabel.isHidden = true
            self.progressView.isHidden = true
            self.fixingButton.isHidden = true
            
            // Animate the checkmark pop back to normal size
            UIView.animate(withDuration: 0.3) {
                self.checkmarkImageView.transform = .identity
            }
        }
    }
}
