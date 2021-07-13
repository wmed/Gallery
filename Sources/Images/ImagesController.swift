import UIKit
import Photos

class ImagesController: UIViewController {
    
    lazy var dropdownController: DropdownController = self.makeDropdownController()
    lazy var gridView: GridView = self.makeGridView()
    lazy var stackView: StackView = self.makeStackView()
    
    var items: [Image] = []
    let library = ImagesLibrary()
    var selectedAlbum: Album?
    let once = Once()
    let cart: Cart
    
    var imageSelectState = GallerySelectState.single
    
    // MARK: - Init
    
    public required init(cart: Cart) {
        self.cart = cart
        super.init(nibName: nil, bundle: nil)
        cart.delegates.add(self)
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
        view.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        
        view.addSubview(gridView)
        
        addChild(dropdownController)
        gridView.insertSubview(dropdownController.view, belowSubview: gridView.topView)
        dropdownController.didMove(toParent: self)
        
        gridView.bottomView.addSubview(stackView)
        
        gridView.g_pinEdges()
        
        dropdownController.view.g_pin(on: .left)
        dropdownController.view.g_pin(on: .right)
        dropdownController.view.g_pin(on: .height, constant: -52) // subtract gridView.topView height
        
        dropdownController.expandedTopConstraint = dropdownController.view.g_pin(on: .top, view: gridView.topView, on: .bottom, constant: 1)
        dropdownController.expandedTopConstraint?.isActive = false
        dropdownController.collapsedTopConstraint = dropdownController.view.g_pin(on: .top, on: .bottom)
        
        stackView.g_pin(on: .centerY, constant: -4)
        stackView.g_pin(on: .left, constant: 28)
        stackView.g_pin(size: CGSize(width: 56, height: 56))
        
        gridView.closeButton.setTitleColor(nil, for: .normal)
        //gridView.closeButton.setTitle("BATCH", for: .normal)
        gridView.closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        gridView.closeButton.addTarget(self, action: #selector(closeButtonTouched(_:)), for: .touchUpInside)
        gridView.doneButton.addTarget(self, action: #selector(doneButtonTouched(_:)), for: .touchUpInside)
        gridView.arrowButton.addTarget(self, action: #selector(arrowButtonTouched(_:)), for: .touchUpInside)
        gridView.cancelButton.addTarget(self, action: #selector(cancelButtonTouched(_:)), for: .touchUpInside)
        gridView.batchExportButton.addTarget(self, action: #selector(batchButtonTouched), for: .touchUpInside)
        stackView.addTarget(self, action: #selector(stackViewTouched(_:)), for: .touchUpInside)
        
        gridView.collectionView.dataSource = self
        gridView.collectionView.delegate = self
        gridView.collectionView.register(ImageCell.self, forCellWithReuseIdentifier: String(describing: ImageCell.self))
    }
    
    // MARK: - Action
    
    @objc func closeButtonTouched(_ button: UIButton) {
//        if Config.Grid.imageLimit == Config.Grid.imageDefaultLimit{
//            gridView.closeButton.setTitleColor(.orange, for: .normal)
//
//            Config.Grid.imageLimit = Config.Grid.imageBatchLimit
//            EventHub.shared.batchOn?()
//        }else{
//            EventHub.shared.batchOff?()
//            gridView.closeButton.setTitleColor(.white, for: .normal)
//            Config.Grid.imageLimit = Config.Grid.imageDefaultLimit
//            if cart.images.count > 1{
//                cart.images = []
//
//                refreshView()
//                configureFrameViews()
//            }
//        }
        EventHub.shared.close?()
    }
    
    @objc func batchButtonTouched(_ button:UIButton) {
        imageSelectState = imageSelectState == .single ? .batch : .single
        updateImagesSelected(state: imageSelectState)
        
    }
    
    func updateImagesSelected(state:GallerySelectState){
        if imageSelectState == .batch{
            gridView.doneButton.setTitle("Batch Export", for: .normal)
            gridView.batchExportButton.tintColor = .orange
            
            Config.Grid.imageLimit = Config.Grid.imageBatchLimit
            EventHub.shared.batchOn?()
        } else {
            gridView.doneButton.setTitle("Next", for: .normal)
            EventHub.shared.batchOff?()
            gridView.batchExportButton.tintColor = .white
            Config.Grid.imageLimit = Config.Grid.imageDefaultLimit
            if cart.images.count > 1{
                cart.images = []
                refreshView()
                configureFrameViews()
            }
        }
    }
    
    
    
    @objc func doneButtonTouched(_ button: UIButton) {
        EventHub.shared.doneWithImages?()
    }
    
    @objc func arrowButtonTouched(_ button: ArrowButton) {
        dropdownController.toggle()
        button.toggle(dropdownController.expanding)
    }
    
    @objc func stackViewTouched(_ stackView: StackView) {
        EventHub.shared.stackViewTouched?()
    }
    
    @objc func cancelButtonTouched(_ button: UIButton) {
        
        for image in cart.images{
            cart.remove(image)
        }
        
        refreshView()
        configureFrameViews()
    }
    // MARK: - Logic
    
    func show(album: Album) {
        gridView.arrowButton.updateText(album.collection.localizedTitle ?? "")
        items = album.photoItems
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
        let hasImages = !cart.images.isEmpty
        gridView.bottomView.g_fade(visible: hasImages)
        UIView.animate(withDuration: 0.3) {
             self.gridView.collectionView.g_updateBottomInset(hasImages ? self.gridView.bottomView.frame.size.height : 0)
        }
    }
    
    // MARK: - Controls
    
    func makeDropdownController() -> DropdownController {
        let controller = DropdownController()
        controller.delegate = self
        controller.mediaType = .image
        
        return controller
    }
    
    func makeGridView() -> GridView {
        let view = GridView()
        view.bottomView.alpha = 0
        
        return view
    }
    
    func makeStackView() -> StackView {
        let view = StackView()
        
        return view
    }
}

extension ImagesController: PageAware {
    
    func reloadContent() {
        refreshSelectedAlbum()
        
    }
    
    func pageDidShow() {
        gridView.mixtapeButton.isHidden = true
        updateImagesSelected(state: imageSelectState)
        once.run {
            library.reload {
                self.gridView.loadingIndicator.stopAnimating()
                self.dropdownController.albums = self.library.albums
                self.dropdownController.tableView.reloadData()
                
                if let album = self.library.albums.first {
                    self.selectedAlbum = album
                    self.show(album: album)
                }
            }
        }
    }
}

extension ImagesController: CartDelegate {
    func cart(_ cart: Cart, didAdd video: Video) {
        
    }
    
    func cart(_ cart: Cart, didRemove video: Video) {
        
    }
    
    
    func cart(_ cart: Cart, didAdd image: Image, newlyTaken: Bool) {
        stackView.reload(cart.images, added: true)
        refreshView()
        
        if newlyTaken {
            refreshSelectedAlbum()
        }
    }
    
    func cart(_ cart: Cart, didRemove image: Image) {
        stackView.reload(cart.images)
        refreshView()
    }
    
    func cartDidReload(_ cart: Cart) {
        stackView.reload(cart.images)
        refreshView()
        refreshSelectedAlbum()
    }
}

extension ImagesController: DropdownControllerDelegate {
    
    func dropdownController(_ controller: DropdownController, didSelect album: Album) {
        selectedAlbum = album
        show(album: album)
        
        dropdownController.toggle()
        gridView.arrowButton.toggle(controller.expanding)
    }
}

extension ImagesController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCell.self), for: indexPath)
            as! ImageCell
        let item = items[(indexPath as NSIndexPath).item]
        
        cell.configure(item)
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
        
        if cart.images.contains(item) {
            cart.remove(item)
        } else {
            
//            for image in cart.images{
//                cart.remove(image)
//            }
            
            for (index, image) in cart.images.enumerated(){
                if index == Config.Grid.imageLimit - 1 {
                    cart.remove(image)
                }
                
            }
            
            if Config.Grid.imageLimit == 0 || Config.Grid.imageLimit > cart.images.count{
                cart.add(item)
            }
        }
        
        configureFrameViews()
    }
    
    func configureFrameViews() {
        for case let cell as ImageCell in gridView.collectionView.visibleCells {
            if let indexPath = gridView.collectionView.indexPath(for: cell) {
                configureFrameView(cell, indexPath: indexPath)
            }
        }
    }
    
    func configureFrameView(_ cell: ImageCell, indexPath: IndexPath) {
//        let item = items[(indexPath as NSIndexPath).item]
//
//        if let index = cart.images.index(of: item) {
//            cell.frameView.g_quickFade()
//            //cell.frameView.label.text = "\(index + 1)"
//        } else {
//            cell.frameView.alpha = 0
//        }
        let item = items[(indexPath as NSIndexPath).item]
        
        if let index = cart.images.firstIndex(of: item) {
            cell.frameView.g_quickFade()
            cell.frameView.label.isHidden = false
            cell.frameView.label.text = "\(index + 1)"
            if Config.Grid.imageLimit == 1{
                cell.frameView.indexView?.isHidden = true
            }else{
                cell.frameView.indexView?.isHidden = false
            }
            
        } else {
            cell.frameView.alpha = 0
        }
        
    }
}
