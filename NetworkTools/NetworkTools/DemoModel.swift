//
//  DemoModel.swift
//  NetworkTools
//
//  Created by LL on 2019/11/26.
//  Copyright © 2019 hxxxxs. All rights reserved.
//

class DemoModel: HandyJSON {
    required public init() {}
}

class DriverModel: DemoModel {
    //通用
    // 首页 热门司基
    var driver_id:String = ""   // 司基 Id
    var image:String = ""   // 司基头像
    var nickname:String = ""    // 司基当前昵称
    var review_nickname = ""    //  司基审核中的昵称
    var subscribe_monthly_count:String = "0"
    var subscribe_total_count:String = "0"   // 订阅人数
    var rank:String = ""
    var total_income:String = "0"    // 累计收益
    var profitAbilityRank:String = "--" // 收益能力排行

    // 首页 置顶推荐
    var account_id:String = ""
    var adjust_warehouse_times:String = "0"
    var assets_range:String = "--"    // 资产
    var fans_count:String = ""
    var is_notice_driver:Bool = false //名人堂是否已经关注
    var max_draw:String = ""
    var max_draw_percentage = ""
    var relative_index_yield:String = ""
    var return_rate:String = ""
    var select_fund_score:String = ""
    var select_time_score:String = ""
    var std_ev_score:String = ""
    var subscribe_this_month_count:String = ""
    var tag:[String] = []   // 司基标签
    var tags:[String] = []   // 司基标签
    var total_amount:String = "--"    // 订阅总油费 或 司基油费
    var earn_money = "" //  邮费
    var yield_return:String = ""
    
    // 驾驶室 - 司基信息
    var assets_unit:String = ""
    var daily_income:String = "0"    // 昨日收益
    var slogan:String = ""
    var is_getAmount:String = "0"    // 可提现金额
    var review_status: Int = 0 // 0 待审核 1 审核通过 2 审核驳回 3 修改后待审核
    var bonusTotalAmount = "" // 订阅总收益
    
    // 司基详情页
    var is_subscribed:Bool = false // 是否已订阅
    var is_noticed:Bool = false // 是否已关注
    var subscribeExpireDays:String = ""
    var subscribeExpireDaysDesc:String = ""

    // 名人堂
    var excess_return: String = ""
    var since_establish_return: String = "--" // 开车以来收益率
    var yield_return_score: String = ""
    var unit: String = ""
    var withdrawal_money:String = "" // 可提现油费
    /// 近一月新增关注人数
    var fans_monthly_count = ""
    
    /// 是否模拟数据   1:是 0:否
    var is_mock = ""
}
