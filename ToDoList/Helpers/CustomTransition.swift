import UIKit

final class CustomTransition: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let isPresenting = fromVC.presentedViewController == toVC
        var initialFrame = CGRect.zero
        var finalTransform = CGAffineTransform.identity
        
        if isPresenting {
            let containerView = transitionContext.containerView
            let finalFrame = transitionContext.finalFrame(for: toVC)
            var snapshotView: UIView?
            
            if let navController = fromVC as? UINavigationController, let listVC = navController.viewControllers.first as? TodoListViewController {
                if let selectedCell = listVC.selectedCell {
                    let cellRect = selectedCell.bounds
                    initialFrame = selectedCell.convert(cellRect, to: containerView)
                    let scaleX = initialFrame.width / finalFrame.width
                    let scaleY = initialFrame.height / finalFrame.height
                    finalTransform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                    snapshotView = selectedCell.snapshotView(afterScreenUpdates: false)
                    snapshotView?.frame = initialFrame
                    containerView.addSubview(snapshotView!)
                }
            }
            
            toVC.view.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            toVC.view.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
            containerView.addSubview(toVC.view)
            
            UIView.animate(withDuration: 0.5, animations: {
                snapshotView?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: { _ in
                snapshotView?.removeFromSuperview()
                toVC.view.alpha = 1
                UIView.animate(withDuration: self.transitionDuration(using: transitionContext) / 2, animations: {
                    toVC.view.transform = finalTransform
                }, completion: { _ in
                    UIView.animate(withDuration: self.transitionDuration(using: transitionContext) / 2, animations: {
                        toVC.view.transform = .identity
                        toVC.view.frame = finalFrame
                    }, completion: { _ in
                        transitionContext.completeTransition(true)
                    })
                })
            })
        } else {
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                fromVC.view.alpha = 0
                toVC.view.frame = transitionContext.containerView.bounds
            }) { _ in
                fromVC.view.alpha = 1
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}
