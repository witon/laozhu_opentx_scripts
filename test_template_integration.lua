-- 简单的集成测试，验证模板加载和选项生成
-- 模拟 EdgeTX API（用于测试环境）
if not LZ_runModule then
    function LZ_runModule(path)
        return dofile(path)
    end
end

-- 测试 ThermalGlider 模板
print("=== 测试 ThermalGlider 模板 ===")
local template = LZ_runModule("LAOZHU/ModelTPL/ThermalGlider.lua")

-- 测试 genOptions()
print("\n1. 测试 genOptions():")
local options = template.genOptions()
for i = 1, #options do
    print(string.format("  选项 %d: %s (配置键: %s)", i, options[i].label, options[i].cfgKey))
    print(string.format("    可选值: %s", table.concat(options[i].values, ", ")))
end

-- 测试 genChannelList()
print("\n2. 测试 genChannelList():")
local testCases = {
    {pType=0, tType=0, fCount=0, desc="F3K + V尾 + 无襟翼"},
    {pType=0, tType=1, fCount=2, desc="F3K + 十字尾 + 2襟翼"},
    {pType=1, tType=0, fCount=3, desc="F5J + V尾 + 3襟翼"},
}

for _, tc in ipairs(testCases) do
    local channels = template.genChannelList(tc.pType, tc.tType, tc.fCount)
    print(string.format("  %s:", tc.desc))
    print(string.format("    舵面: %s", table.concat(channels, ", ")))
end

print("\n=== 测试完成 ===")
