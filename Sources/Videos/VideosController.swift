import UIKit
import Photos
import AVKit

class VideosController: UIViewController {
    
    lazy var dropdownController: DropdownController = self.makeDropdownController()
    lazy var gridView: GridView = self.makeGridView()
    lazy var videoBox: VideoBox = self.makeVideoBox()
    
    var items: [Video] = []
    let library = VideosLibrary()
    var selectedAlbum: Album?
    let once = Once()
    let cart: Cart
    
    // MARK: - Init
    
    public required init(cart: Cart) {
        self.cart = cart
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    // MARK: - Setup
    
    func setup() {
        
        view.backgroundColor = UIColor(red: 20/255, green: 25/255, blue: 30/255, alpha: 1.0)
        
        view.addSubview(gridView)
        
        addChildViewController(dropdownController)
        gridView.insertSubview(dropdownController.view, belowSubview: gridView.topView)
        dropdownController.didMove(toParentViewController: self)
        
        [videoBox].forEach {
            gridView.bottomView.addSubview($0)
        }
        
        gridView.g_pinEdges()
        
        dropdownController.view.g_pin(on: .left)
        dropdownController.view.g_pin(on: .right)
        dropdownController.view.g_pin(on: .height, constant: -52) // subtract gridView.topView height
        
        dropdownController.expandedTopConstraint = dropdownController.view.g_pin(on: .top, view: gridView.topView, on: .bottom, constant: 1)
        dropdownController.expandedTopConstraint?.isActive = false
        dropdownController.collapsedTopConstraint = dropdownController.view.g_pin(on: .top, on: .bottom)
        
        videoBox.g_pin(size: CGSize(width: 56, height: 56))
        videoBox.g_pin(on: .centerY)
        videoBox.g_pin(on: .left, constant: 28)
        
        gridView.closeButton.addTarget(self, action: #selector(closeButtonTouched(_:)), for: .touchUpInside)
        gridView.doneButton.addTarget(self, action: #selector(doneButtonTouched(_:)), for: .touchUpInside)
        gridView.arrowButton.addTarget(self, action: #selector(arrowButtonTouched(_:)), for: .touchUpInside)
        gridView.cancelButton.addTarget(self, action: #selector(cancelButtonTouched(_:)), for: .touchUpInside)
        
        gridView.collectionView.dataSource = self
        gridView.collectionView.delegate = self
        gridView.collectionView.register(VideoCell.self, forCellWithReuseIdentifier: String(describing: VideoCell.self))

    }
    
    // MARK: - Action
    
    @objc func closeButtonTouched(_ button: UIButton) {
        EventHub.shared.close?()
    }
    
    @objc func doneButtonTouched(_ button: UIButton) {
        //EventHub.shared.doneTouched?()
        EventHub.shared.doneWithVideos?()
    }
    
    @objc func cancelButtonTouched(_ button: UIButton) {
        cart.video = nil
        
        refreshView()
        configureFrameViews()
    }
    
    @objc func arrowButtonTouched(_ button: ArrowButton) {
        dropdownController.toggle()
        button.toggle(dropdownController.expanding)
    }
    
    // MARK: - Logic
    
    func show(album: Album) {
        gridView.arrowButton.updateText(album.collection.localizedTitle ?? "")
        items = album.videoItems
        gridView.collectionView.reloadData()
        gridView.collectionView.g_scrollToTop()
        gridView.emptyView.isHidden = !items.isEmpty
    }
    
    func refreshSelectedAlbum() {
        if let selectedAlbum = selectedAlbum {
            selectedAlbum.reload()
            show(album: selectedAlbum)
        }
    }
    
    // MARK: - View
    
    func refreshView() {
        if let selectedItem = cart.video {
            videoBox.imageView.g_loadImage(selectedItem.asset)
        } else {
            videoBox.imageView.image = nil
        }
        
        let hasVideo = (cart.video != nil)
        gridView.bottomView.g_fade(visible: hasVideo)
        UIView.animate(withDuration: 0.3) {
        self.gridView.collectionView.g_updateBottomInset(hasVideo ? self.gridView.bottomView.frame.size.height : 0)
        }
    }
    
    // MARK: - Controls
    
    func makeDropdownController() -> DropdownController {
        let controller = DropdownController()
        controller.delegate = self
        controller.mediaType = .video
        return controller
    }
    
    
    func makeGridView() -> GridView {
        let view = GridView()
        view.bottomView.alpha = 0
        
        return view
    }
    
    func makeVideoBox() -> VideoBox {
        let videoBox = VideoBox()
        videoBox.delegate = self
        
        return videoBox
    }
    
    
    //    func makeInfoLabel() -> UILabel {
    //        let label = UILabel()
    //        label.textColor = UIColor.white
    //        label.font = Config.Font.Text.regular.withSize(12)
    //        label.text = String(format: "Gallery.Videos.MaxiumDuration".g_localize(fallback: "FIRST %d SECONDS"),
    //                            (Int(Config.VideoEditor.maximumDuration)))
    //
    //        return label
    //    }
    
    
    
}


extension VideosController: PageAware {
    
    func reloadContent() {
        refreshSelectedAlbum()
        
    }
    func pageDidShow() {
        once.run {
            library.reload {
                self.gridView.loadingIndicator.stopAnimating()
                //self.items = self.library.items
                self.gridView.emptyView.isHidden = true
                
                self.dropdownController.albums = self.library.albums
                self.dropdownController.tableView.reloadData()
                
                if let album = self.library.albums.first {
                    self.selectedAlbum = album
                    self.show(album: album)
                }else{
                    self.gridView.emptyView.isHidden = false
                }
            }
        }
    }
    
}

extension VideosController: DropdownControllerDelegate {
    
    func dropdownController(_ controller: DropdownController, didSelect album: Album) {
        selectedAlbum = album
        show(album: album)
        
        dropdownController.toggle()
        gridView.arrowButton.toggle(controller.expanding)
    }
}

extension VideosController: VideoBoxDelegate {
    
    func videoBoxDidTap(_ videoBox: VideoBox) {
        cart.video?.fetchPlayerItem { item in
            guard let item = item else { return }
            
            DispatchQueue.main.async {
                let controller = AVPlayerViewController()
                let player = AVPlayer(playerItem: item)
                controller.player = player
                
                self.present(controller, animated: true) {
                    player.play()
                }
            }
        }
    }
}

extension VideosController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("video library item count \(items.count)")
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: VideoCell.self), for: indexPath)
            as! VideoCell
        let item = items[(indexPath as NSIndexPath).item]
        
        cell.configure(item)
        cell.frameView.label.isHidden = true
        configureFrameView(cell, indexPath: indexPath)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = (collectionView.bounds.size.width - (Config.Grid.Dimension.columnCount - 1) * Config.Grid.Dimension.cellSpacing)
            / Config.Grid.Dimension.columnCount
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[(indexPath as NSIndexPath).item]
        
        if let selectedItem = cart.video , selectedItem == item {
            cart.video = nil
        } else {
            cart.video = item
        }
        
        refreshView()
        configureFrameViews()
    }
    
    func configureFrameViews() {
        for case let cell as VideoCell in gridView.collectionView.visibleCells {
            if let indexPath = gridView.collectionView.indexPath(for: cell) {
                configureFrameView(cell, indexPath: indexPath)
            }
        }
    }
    
    func configureFrameView(_ cell: VideoCell, indexPath: IndexPath) {
        let item = items[(indexPath as NSIndexPath).item]
        
        if let selectedItem = cart.video , selectedItem == item {
            cell.frameView.g_quickFade()
        } else {
            cell.frameView.alpha = 0
        }
    }
}
