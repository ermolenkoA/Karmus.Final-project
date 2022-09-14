//
//  AllCouponsTableViewController.swift
//  Karmus
//
//  Created by VironIT on 9/13/22.
//

import UIKit
import KeychainSwift

final class AllCouponsTableViewController: UITableViewController {
    
    // MARK: - Private Properties
    
    private var coupons = [CouponInfoModel]()
    private var noActiveCouponsLabel: UILabel!
    private var mainActivityIndicatorView: UIActivityIndicatorView!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        startSettings()
        getCoupons()
    
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        noActiveCouponsLabel = nil
        mainActivityIndicatorView = nil
    }
    
     // MARK: - Private functions
    
    private func startSearching() {
        mainActivityIndicatorView.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    private func stopSearching() {
        mainActivityIndicatorView.stopAnimating()
        view.isUserInteractionEnabled = true
    }
    
    private func startSettings() {
    
        let navBarHeight = navigationController!.navigationBar.frame.height
        let tabBarHeight = tabBarController!.tabBar.frame.height
        let frame = view.frame.height - navBarHeight - tabBarHeight
        
        noActiveCouponsLabel = .init(frame: CGRect(x: 0,
                                                   y: frame/2 - 15,
                                                   width: view.frame.width,
                                                   height: 30))
        noActiveCouponsLabel.text = "Нет доступных купонов"
        noActiveCouponsLabel.textAlignment = .center
        noActiveCouponsLabel.font = .systemFont(ofSize: 20)
        noActiveCouponsLabel.isHidden = true
        
        mainActivityIndicatorView = .init(frame: CGRect(x: 0,
                                                        y: frame/2 - 15,
                                                        width: view.frame.width,
                                                        height: 30))
        mainActivityIndicatorView.hidesWhenStopped = true
        mainActivityIndicatorView.color = .label
        mainActivityIndicatorView.style = .large
        mainActivityIndicatorView.stopAnimating()
        
        view.addSubview(noActiveCouponsLabel)
        view.addSubview(mainActivityIndicatorView)
        
    }
    
    private func getCoupons() {
        
        startSearching()
        noActiveCouponsLabel.isHidden = true
        
        FireBaseDataBaseManager.getActiveCoupons { [weak self] coupons in
            
            if coupons.isEmpty {
                self?.noActiveCouponsLabel.isHidden = false
            } 
            
            self?.coupons = coupons
            self?.tableView.reloadData()
            self?.stopSearching()
        }
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        coupons.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "allCouponsTVCell", for: indexPath)
        
        let coupon = coupons[indexPath.row]
        
        (cell as? FillCouponProtocol)?.fillCoupon(
            photo: coupon.sponsorPhoto,
            title: coupon.name,
            sponsorName: coupon.sponsorName,
            login: coupon.sponsorLogin)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let coupon = coupons[indexPath.row]
        
        var alert: UIAlertController! = .init(title: coupon.name,
                                              message: coupon.description,
                                              preferredStyle: .alert)
        
        if KeychainSwift.shared.get(ConstantKeys.profileType)! != FBProfileTypes.sponsor {
            
            let sumbitButton = UIAlertAction(title: "Приобрести", style: .default) { [weak self] _ in
                
                guard let profileID = KeychainSwift.shared.get(ConstantKeys.currentProfile) else {
                    return
                }
                
                self?.startSearching()
                
                FireBaseDataBaseManager.buyCoupon(profileID: profileID, couponID: coupon.id) { [weak self] code, errorText in
                    
                    self?.startSearching()
                    
                    guard errorText == nil else{
                        showAlert("Ошибка", errorText, where: self)
                        self?.stopSearching()
                        return
                    }
                    
                    showAlert("Покупка завершена успешно!", "Ваш код: \(code!)", where: self)
                    self?.stopSearching()
                }
                
            }
            
            alert.addAction(sumbitButton)
        }
        
        
        let backButton = UIAlertAction(title: "Вернуться", style: .default) { _ in
            alert = nil
        }
        
        alert.addAction(backButton)
        alert.view.tintColor = .black
        present(alert, animated: true)
        
    }
    

    @IBAction func didTapCouponButton(_ sender: UIButton) {
        
        let storyboard = KeychainSwift.shared.get(ConstantKeys.profileType)! != FBProfileTypes.sponsor
            ? UIStoryboard(name: StoryboardNames.myCouponsScreen, bundle: nil)
            : UIStoryboard(name: StoryboardNames.createCouponsScreen, bundle: nil)
        
        let newVC = storyboard.instantiateInitialViewController()!
        
        navigationController?.pushViewController(newVC, animated: true)
    }
    
    @IBAction func reloadData(_ sender: UIButton) {
        getCoupons()
    }
    
}
