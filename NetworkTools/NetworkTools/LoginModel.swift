//
//  LoginModel.swift
//  NetworkTools
//
//  Created by LL on 2019/11/25.
//  Copyright © 2019 hxxxxs. All rights reserved.
//

import HandyJSON

struct ProductIndexModel: HandyJSON {
    var banners:[ProductBannerModel] = []
    var menu:ProductMenuModel = ProductMenuModel()
    var info_list:[ProductInfoModel] = []
}

struct ProductBannerModel: HandyJSON {
    var adv_desc:String = ""
    var picture:String = ""
    var url:String = ""
}

struct ProductMenuModel: HandyJSON {
    var huoqi_url:String = ""
    var dingtou_url:String = ""
    var chaoshi_url:String = ""
    var xuetang_url:String = ""
    var youxuan_url:String = ""
    var kaihu_url:String = ""
    var pingtai_url:String = ""
}

struct ProductInfoModel: HandyJSON {
    var publish_time:String = ""
    var publish_media:String = ""
    var title:String = ""
    var content:String = ""
    // 本地属性
    var isDisplay:Bool = false
}
