import UIKit

final class SingleImageViewController: UIViewController {
    @IBOutlet private var singleImageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var shareButton: UIButton!
    
    @IBAction private func didTapShareButton(_ sender: Any) {
        guard let image else {return}
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    @IBAction private func didTapBackButton (){
        dismiss(animated: true, completion: nil)
    }
    
    var image: UIImage? {
        didSet{
            guard isViewLoaded, let image else {return}
            singleImageView.image = image
            singleImageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        guard let image else {return}
        singleImageView.image = image
        singleImageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage){
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        centerImageInScrollView()
    }
    
    private func centerImageInScrollView() {
        let visibleRectSize = scrollView.bounds.size
        let imageSize = singleImageView.frame.size
        let hInset = max((visibleRectSize.width - imageSize.width) / 2, 0)
        let vInset = max((visibleRectSize.height - imageSize.height) / 2, 0)
        scrollView.contentInset = UIEdgeInsets(
            top: vInset,
            left: hInset,
            bottom: vInset,
            right: hInset
        )
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        singleImageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView){
        centerImageInScrollView()
    }
}
