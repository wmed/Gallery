import UIKit
import Photos

class GridView: UIView {
    
    // MARK: - Initialization
    
    lazy var topView: UIView = self.makeTopView()
    lazy var bottomView: UIView = self.makeBottomView()
    lazy var bottomBlurView: UIVisualEffectView = self.makeBottomBlurView()
    lazy var arrowButton: ArrowButton = self.makeArrowButton()
    lazy var collectionView: UICollectionView = self.makeCollectionView()
    lazy var closeButton: UIButton = self.makeCloseButton()
    lazy var videoBatchButton: UIButton = self.makeVideoBatchButton()
    lazy var settingButton: UIButton = self.makeSettingsButton()
    lazy var doneButton: UIButton = self.makeDoneButton()
    lazy var cancelButton = makeCancelButton()
    lazy var emptyView: UIView = self.makeEmptyView()
    lazy var loadingIndicator: UIActivityIndicatorView = self.makeLoadingIndicator()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        loadingIndicator.startAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setup() {
        [collectionView, bottomView, topView, emptyView, loadingIndicator].forEach {
            addSubview($0)
        }
        
        [closeButton, arrowButton, settingButton, videoBatchButton].forEach {
            topView.addSubview($0)
        }
        
        [bottomBlurView, doneButton, cancelButton].forEach {
            bottomView.addSubview($0 as! UIView)
        }
        
        Constraint.on(
            topView.leftAnchor.constraint(equalTo: topView.superview!.leftAnchor),
            topView.rightAnchor.constraint(equalTo: topView.superview!.rightAnchor),
            topView.heightAnchor.constraint(equalToConstant: 40),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingIndicator.superview!.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingIndicator.superview!.centerYAnchor)
        )
        
        if #available(iOS 11, *) {
            Constraint.on(
                topView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
            )
        } else {
            Constraint.on(
                topView.topAnchor.constraint(equalTo: topView.superview!.topAnchor)
            )
        }
        
//        bottomView.g_pin(on: .bottom, view: topView, on: .bottom, constant:0)
//        bottomView.g_pin(height: 80)
//        bottomView.g_pin(on:.leading, view: topView, on: .leading, constant:0)
//        bottomView.g_pin(on:.trailing, view: topView, on: .trailing, constant:0)
        
        bottomView.g_pinDownward()
        bottomView.g_pin(height: 80)
        
        emptyView.g_pinEdges(view: collectionView)
        
        collectionView.g_pinDownward()
        collectionView.g_pin(on: .top, view: topView, on: .bottom, constant: 1)
        
        bottomBlurView.g_pinEdges()
        
        closeButton.g_pin(on: .top)
        closeButton.g_pin(on: .left)
        closeButton.g_pin(size: CGSize(width: 80, height: 40))
        
        videoBatchButton.g_pin(on: .top)
        videoBatchButton.g_pin(on: .leading, view: closeButton, on: .trailing, constant: 5)
        videoBatchButton.g_pin(size: CGSize(width: 80, height: 40))
        
        arrowButton.g_pinCenter()
        arrowButton.g_pin(height: 40)
        
        doneButton.g_pin(on: .centerY)
        doneButton.g_pin(width: 90)
        doneButton.g_pin(on: .right, constant: -1)
        
        cancelButton.g_pin(on: .centerY)
        cancelButton.g_pin(width: 90)
        cancelButton.g_pin(on:.trailing, view: doneButton, on: .leading, constant:-15)
    }
    
    // MARK: - Controls
    
    private func makeTopView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        
        return view
    }
    
    private func makeBottomView() -> UIView {
        let view = UIView()
        
        return view
    }
    
    private func makeBottomBlurView() -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        
        return view
    }
    
    private func makeArrowButton() -> ArrowButton {
        let button = ArrowButton()
        button.layoutSubviews()
        
        return button
    }
    
    private func makeGridView() -> GridView {
        let view = GridView()
        
        return view
    }
    
    private func makeCloseButton() -> UIButton {
        let button = UIButton(type: .custom)
        //button.setImage(GalleryBundle.image("gallery_close")?.withRenderingMode(.alwaysTemplate), for: UIControl.State())
        button.tintColor = Config.Grid.CloseButton.tintColor
        //button.setTitle("MIXTAPE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitle(Config.Grid.CloseButton.buttonName, for: .normal)
        return button
    }
    
    private func makeVideoBatchButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.tintColor = Config.Grid.VideoBatch.tintColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitle(Config.Grid.VideoBatch.buttonName, for: .normal)
        return button
    }
    
    private func makeSettingsButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor(red: 1.0, green: 110/225, blue: 64/255, alpha: 1.0), for: UIControl.State())
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        button.titleLabel?.font = Config.Font.Text.regular.withSize(14)
        button.setTitle("Settings", for: .normal)
        return button
    }
    
    
    private func makeDoneButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor(red: 1.0, green: 110/225, blue: 64/255, alpha: 1.0), for: UIControl.State())
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        button.titleLabel?.font = Config.Font.Text.regular.withSize(14)
        button.setTitle("Gallery.Done".g_localize(fallback: "Next"), for: UIControl.State())
        return button
    }
    
    private func makeCancelButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor.lightGray, for: UIControl.State())
        button.titleLabel?.font = Config.Font.Text.regular.withSize(14)
        button.setTitle("Gallery.Done".g_localize(fallback: "Cancel"), for: UIControl.State())
        return button
    }
//    
//    private func makeSizeButton() -> UIButton {
//        let button = UIButton(type: .system)
//        button.setTitleColor(UIColor.lightGray, for: UIControlState())
//        button.titleLabel?.font = Config.Font.Text.regular.withSize(14)
//        let vidSize = VideoSize.tvPortrait3x4
//        button.setTitle(, for: UIControlState())
//        return button
//    }
//    
    
    private func makeCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.white
        
        return view
    }
    
    private func makeEmptyView() -> EmptyView {
        let view = EmptyView()
        view.isHidden = true
        
        return view
    }
    
    private func makeLoadingIndicator() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.color = .gray
        view.hidesWhenStopped = true
        
        return view
    }
}
