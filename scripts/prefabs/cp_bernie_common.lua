-- 定义一个包含函数的表
local fn = {}

-- 检查leader（领导者）的疯狂状态
fn.isleadercrazy = function(inst, leader)
    -- 检查领导者是否疯狂，或者激活了某些技能且理智低于一定百分比
    if (leader.components.sanity:IsCrazy() or
        (leader.components.sanity:GetPercent() < TUNING.SKILLS.WILLOW_BERNIESANITY_1 and leader.components.skilltreeupdater:IsActivated("willow_berniesanity_1")) or 
        (leader.components.sanity:GetPercent() < TUNING.SKILLS.WILLOW_BERNIESANITY_2 and leader.components.skilltreeupdater:IsActivated("willow_berniesanity_2"))) then
        return true
    end
    return false
end

-- 定义一些常量
local HOTHEAD_ACTIVTE_DIST = 20*40 -- 激活范围
local HOTHEAD_MUST_TAGS = { "_combat", "hostile" } -- 必须包含的标签
local HOTHEAD_CANT_TAGS = { "INLIMBO", "player", "companion" } -- 不能包含的标签
local HOTHEAD_ONEOF_TAGS = { "brightmare", "lunar_aligned", "shadow_aligned", "shadow" } -- 至少包含一个的标签

-- 检查是否有敌对目标在范围内
fn.hotheaded = function(inst, player)
    local x, y, z = inst.Transform:GetWorldPosition() -- 获取实体的位置
    if player.components.skilltreeupdater:IsActivated("willow_bernieai") then -- 检查技能是否激活
        local targets = TheSim:FindEntities(x, y, z, HOTHEAD_ACTIVTE_DIST, HOTHEAD_MUST_TAGS, HOTHEAD_CANT_TAGS, HOTHEAD_ONEOF_TAGS) -- 查找范围内的实体
        if #targets > 0 then -- 如果找到了目标
            return true
        end
    end
    return false
end

-- 返回包含函数的表
return fn
