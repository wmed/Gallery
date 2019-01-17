import UIKit


class FrameView: UIView {
    
    public lazy var label: UILabel = self.makeLabel()
    lazy var gradientLayer: CAGradientLayer = self.makeGradientLayer()
    public var indexView: UIView?

    public let indexLabel:UILabel = UILabel()
    
    
    // MARK: - Initialization
    public convenience init(frame: CGRect, isMultiSelect:Bool){
        self.init(frame: frame)
        multiSelectSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setup() {
        layer.addSublayer(gradientLayer)
        layer.borderColor = Config.Grid.FrameView.borderColor.cgColor
        layer.borderWidth = 3
        
        //addSubview(label)
        //label.g_pinCenter()
    }
    
    private func multiSelectSetup(){
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = Config.Grid.FrameView.borderColor
        addSubview(view)
        view.g_pin(size: CGSize(width: 24, height: 24))
        view.g_pin(on: .top, constant:8)
        view.g_pin(on: .trailing, constant:-8)
        
        view.addSubview(label)
        
        indexView = view
        
        label.g_pinCenter()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
    }
    
    // MARK: - Controls
    
    private func makeLabel() -> UILabel {
        let label = UILabel()
        label.font = Config.Font.Main.regular.withSize(9)
        label.textColor = .white
        label.text = ""
        return label
    }
    
    private func makeGradientLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = [
            Config.Grid.FrameView.fillColor.withAlphaComponent(0.25).cgColor,
            Config.Grid.FrameView.fillColor.withAlphaComponent(0.4).cgColor
        ]
        
        return layer
    }
}
