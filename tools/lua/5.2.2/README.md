# 项目内 Lua 5.2.2（macOS）

本目录下的 `lua` 可执行文件与 CI 使用的版本一致（Lua 5.2.2），便于在本机跑单元测试时对齐解释器行为。

当前仅包含 **macOS** 构建（Apple Silicon 与 Intel）。Windows 预编译二进制尚未纳入仓库；在 Windows 上请暂时使用自行安装的 Lua 5.2 与 LuaRocks 运行 `lua test/test.lua`。

## 二进制说明

| 路径 | 架构 | 构建方式 |
|------|------|----------|
| `darwin-arm64/lua` | arm64 | 官方源码包 `lua-5.2.2.tar.gz`，`make macosx` |
| `darwin-x86_64/lua` | x86_64 | 同上，在 Rosetta 下 `arch -x86_64 make macosx` |

源码：<https://www.lua.org/ftp/lua-5.2.2.tar.gz>

若从网上下载的 macOS 二进制被标记隔离导致无法执行，可对本仓库内自编译的 `lua` 忽略；若自行替换为第三方二进制，可执行：`xattr -d com.apple.quarantine path/to/lua`。

## 单元测试与 LuaRocks

`test/test.lua` 依赖 luarocks 安装的 `luaunit` 与 `lua-mock`（与 `.github/workflows/main.yml` 一致）。请先安装 LuaRocks，然后安装与 CI 相同的测试依赖：

```sh
luarocks install luaunit
luarocks install lua-mock
```

再从仓库根目录执行：

```sh
./run_tests.sh
```

脚本会在内部执行 `luarocks path`（优先 `--lua-version=5.2`，再并入默认输出），用本目录下的 `lua` 运行 `test/test.lua`，一般**不必**再手动 `eval "$(luarocks path)"`。若未安装 `luarocks` 命令，脚本会报错退出。

## 重新生成 macOS 二进制（维护者）

```sh
curl -sL -O https://www.lua.org/ftp/lua-5.2.2.tar.gz
tar -xzf lua-5.2.2.tar.gz
cd lua-5.2.2
make clean && make macosx
cp src/lua ../tools/lua/5.2.2/darwin-arm64/lua   # 在本机为 arm64 时
# Intel 或 Rosetta：
# arch -x86_64 make clean && arch -x86_64 make macosx && cp src/lua ../tools/lua/5.2.2/darwin-x86_64/lua
chmod +x tools/lua/5.2.2/darwin-*/lua
```

可选校验：`shasum -a 256 tools/lua/5.2.2/darwin-arm64/lua`（随构建环境变化，仅作发布记录用）。
