import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    @IBOutlet private var singleImageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var shareButton: UIButton!
    
    @IBAction private func didTapShareButton(_ sender: Any) {
        guard let image = singleImageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true)
    }
    
    @IBAction private func didTapBackButton (){
        dismiss(animated: true, completion: nil)
    }
    
    var imageURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        loadImage()
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
    
    private func loadImage() {
        guard let imageURL, let url = URL(string: imageURL) else { return }

        UIBlockingProgressHUD.show()

        singleImageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let value):
                let image = value.image
                self.singleImageView.image = image
                self.singleImageView.frame = CGRect(origin: .zero, size: image.size)
                self.scrollView.contentSize = image.size
                self.rescaleAndCenterImageInScrollView(image: image)
            case .failure:
                self.showError()
            }
        }
    }
    
    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage()
        })
        present(alert, animated: true)
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
