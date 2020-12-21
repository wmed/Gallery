import UIKit

protocol PageIndicatorDelegate: class {
    func pageIndicator(_ pageIndicator: PageIndicator, didSelect index: Int)
}

class PageIndicator: UIView {
    
    let items: [(name: String, selected: String, unselected: String)]
    var buttons: [UIButton]!
    
    //lazy var indicator: UIImageView = self.makeIndicator()
    weak var delegate: PageIndicatorDelegate?
    
    // MARK: - Initialization
    
    required init(items: [(name: String, selected: String, unselected: String)]) {
        self.items = items
        
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = bounds.size.width / CGFloat(buttons.count)
        
        for (i, button) in buttons.enumerated() {
            
            button.frame = CGRect(x: width * CGFloat(i),
                                  y: 0,
                                  width: width,
                                  height: bounds.size.height)
        }
        
        //    indicator.frame.size = CGSize(width: width / 1.5, height: 4)
        //    indicator.frame.origin.y = bounds.size.height - indicator.frame.size.height
        //
        //    if indicator.frame.origin.x == 0 {
        //      select(index: 0)
        //    }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
    
    // MARK: - Setup
    
    func setup() {
        buttons = items.map {
            let button = self.makeButton($0)
            addSubview(button)
            
            return button
        }
        
        //addSubview(indicator)
    }
    
    // MARK: - Controls
    
    func makeButton(_ title: (name:String, selected:String, unselected:String)) -> UIButton {
        let button = UIButton(type: .custom)
        //button.setTitle("", for: UIControlState())
        button.setImage(UIImage(named: title.unselected), for: .normal)
        button.setImage(UIImage(named: title.selected), for: .selected)
        //button.setTitleColor(Config.PageIndicator.textColor, for: UIControlState())
        //button.setTitleColor(UIColor.gray, for: .highlighted)
        button.backgroundColor = Config.PageIndicator.backgroundColor
        button.addTarget(self, action: #selector(buttonTouched(_:)), for: .touchUpInside)
        //button.titleLabel?.font = buttonFont(false)
        
        return button
    }
    
    func makeIndicator() -> UIImageView {
        let imageView = UIImageView(image: GalleryBundle.image("gallery_page_indicator"))
        
        return imageView
    }
    
    // MARK: - Action
    
    @objc func buttonTouched(_ button: UIButton) {
        let index = buttons.firstIndex(of: button) ?? 0
        delegate?.pageIndicator(self, didSelect: index)
        select(index: index)
   
        UIView.animate(withDuration: 0.15, animations: {
            button.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            UIView.animate(withDuration: 0.15, animations: {
                button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }, completion: { _ in
                UIView.animate(withDuration: 0.075, animations: {
                    button.transform = .identity
                })
            })
        }
        
    }
    
    // MARK: - Logic
    
    func select(index: Int, animated: Bool = true) {
        for (i, b) in buttons.enumerated() {
            let info = items[i]
            b.setImage(UIImage(named: i == index ? info.selected : info.unselected), for: .normal)
        }
    }
    
    // MARK: - Helper
    
    func buttonFont(_ selected: Bool) -> UIFont {
        return selected ? Config.Font.Main.bold.withSize(14) : Config.Font.Main.regular.withSize(14)
    }
}
