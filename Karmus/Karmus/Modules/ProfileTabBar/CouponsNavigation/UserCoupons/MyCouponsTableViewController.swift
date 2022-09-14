//
//  MyCouponsTableViewController.swift
//  Karmus
//
//  Created by VironIT on 9/13/22.
//

import UIKit
import KeychainSwift

final class MyCouponsTableViewController: UITableViewController {

    // MARK: - Private Properties
    
    private var coupons = [UserCouponInfoModel]()
    private var noActiveCouponsLabel: UILabel!
    private var mainActivityIndicatorView: UIActivityIndicatorView!
    private var profileID = KeychainSwift.shared.get(ConstantKeys.currentProfile)!
    private var profileType = KeychainSwift.shared.get(ConstantKeys.profileType)!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        startSettings()
        getCoupons()
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        noActiveCouponsLabel = nil
        mainActivityIndicatorView = nil
    }

    // MARK: - Private Properties
    
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
        noActiveCouponsLabel.text = "Нет активных купонов"
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
        
        FireBaseDataBaseManager.getProfileCoupons(profileID) { [weak self] coupons in
            
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCouponTVCell", for: indexPath)
        
        let coupon = coupons[indexPath.row]
        
        (cell as? FillMyCouponProtocol)?.fillCoupon(
            photo: coupon.sponsorPhoto,
            code: coupon.code,
            title: coupon.name,
            sponsorName: coupon.sponsorName,
            login: coupon.sponsorLogin)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let couponID = coupons[indexPath.row].id
        let code = coupons[indexPath.row].code
        
        if editingStyle == .delete {
            
            tableView.beginUpdates()
            coupons.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            noActiveCouponsLabel.isHidden = !coupons.isEmpty
            tableView.endUpdates()
        }
        
        FireBaseDataBaseManager.removeCoupon(profileID: profileID, couponID: couponID, code: code)
        
    }
    
    

}
