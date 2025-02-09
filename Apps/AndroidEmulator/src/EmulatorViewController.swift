import UIKit
import Metal
import MetalKit

class EmulatorViewController: UIViewController {
    private var emulatorCore: EmulatorCore?
    private var metalView: MTKView?
    
    // UI Elements
    private var controlsView: UIView?
    private var startButton: UIButton?
    private var pauseButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupEmulator()
    }
    
    private func setupUI() {
        // Setup Metal view
        let mtkView = MTKView(frame: view.bounds)
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.backgroundColor = .black
        view.addSubview(mtkView)
        metalView = mtkView
        
        // Setup controls
        let controls = UIView(frame: CGRect(x: 0, y: view.bounds.height - 100, width: view.bounds.width, height: 100))
        controls.backgroundColor = .systemBackground.withAlphaComponent(0.8)
        view.addSubview(controls)
        controlsView = controls
        
        // Setup buttons
        let start = UIButton(type: .system)
        start.setTitle("Start", for: .normal)
        start.addTarget(self, action: #selector(startEmulator), for: .touchUpInside)
        start.frame = CGRect(x: 20, y: 20, width: 80, height: 40)
        controls.addSubview(start)
        startButton = start
        
        let pause = UIButton(type: .system)
        pause.setTitle("Pause", for: .normal)
        pause.addTarget(self, action: #selector(pauseEmulator), for: .touchUpInside)
        pause.frame = CGRect(x: 120, y: 20, width: 80, height: 40)
        controls.addSubview(pause)
        pauseButton = pause
    }
    
    private func setupEmulator() {
        emulatorCore = EmulatorCore()
    }
    
    @objc private func startEmulator() {
        emulatorCore?.startEmulation()
        startButton?.isEnabled = false
        pauseButton?.isEnabled = true
    }
    
    @objc private func pauseEmulator() {
        emulatorCore?.pauseEmulation()
        startButton?.isEnabled = true
        pauseButton?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emulatorCore?.pauseEmulation()
    }
}
