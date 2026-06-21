# MiddleButtonTyper

**macOS 鼠标中键 → 自动键盘输入 | Middle mouse button to keystroke on macOS**

把鼠标中键变成文本输入快捷键。默认输入 `135790`，可自行修改为任何文本。

---

## 📥 下载与安装 | Download & Install

- **Release 下载**: https://github.com/cpufreestyle/middle-button-typer/releases
- 也可自行编译（见下方说明）

### 快速开始

1. 下载 `.zip`，解压得到 `MiddleButtonTyper.app`
2. 拖到「应用程序」或任意位置
3. **首次运行**：右键 → 打开（不要双击，会提示未验证开发者）
   系统设置 → 隐私与安全性 → 辅助功能 → 允许 `MiddleButtonTyper`
4. 在文本输入框按鼠标中键 → 自动输入 `135790`

### 依赖 | Dependencies

需要 [cliclick](https://github.com/BlueM/cliclick)（用于键盘事件注入）：

```bash
brew install cliclick
```

或手动编译：

```bash
git clone https://github.com/BlueM/cliclick.git
cd cliclick && make
cp cliclick ~/bin/
```

---

## ⚙️ 开机自启（推荐双保险） | Auto-Start (Dual Method)

macOS 上 Accessibility 权限是按「用户登录 session」授予的，所以 GUI 类工具最稳的启动方式是用 **Login Items**；再配一个 **launchd** 做守护，确保异常退出后自动重启。

### 方法 A：Login Items（最稳，推荐）

1. 打开 **系统设置 → 通用 → 登录项**
2. 点 **+**，选择 `~/Applications/MiddleButtonTyper.app`
3. 完成，每次登录都会自动启动

### 方法 B：一键安装脚本（双保险）

适合想自动化的用户，会同时做：

- 复制 `MiddleButtonTyper.app` 到 `~/Applications`
- 创建 launchd 启动项（异常退出 10 秒后自动重启）
- 立即启动

```bash
cd middle-button-typer
./install.sh
```

> 脚本首次运行后，**仍需要手动授权**：系统设置 → 隐私与安全性 → 辅助功能 → 允许 MiddleButtonTyper
>
> **注意**：launchd 启动的进程有时无法获得 Accessibility 权限，因此安装完成后仍建议按方法 A 再手动添加 Login Items。

### 方法 C：手动 launchd（进阶）

如果你不想用脚本，可以手动编辑 `com.cpufreestyle.middle-button-typer.plist`：

1. 把 `CHANGE_ME` 改成你的用户名和实际路径
2. 复制到 `~/Library/LaunchAgents/`
3. 加载：

```bash
launchctl load ~/Library/LaunchAgents/com.cpufreestyle.middle-button-typer.plist
launchctl start com.cpufreestyle.middle-button-typer
```

### 卸载

```bash
./uninstall.sh
```

> 这会删除 launchd 项和 `~/Applications/MiddleButtonTyper.app`，但 Login Items 里手动添加的条目仍需手动移除。

---

## ✏️ 自定义输入内容 | Customize the Output

### 方法一：修改源码（推荐）

1. 修改 `main.swift` 中的 `typeString()` 调用：

   ```swift
   // main.swift — 第 12 行附近
   typeString("你的自定义文本")   // 👈 把 135790 改成你要的
   ```

   > 支持特殊字符：可以用 `cliclick` 支持的语法，如 `"Hello{enter}World"` 输入换行。

2. 重新编译：

   ```bash
   ./build.sh
   ```

3. 运行新生成的 `MiddleButtonTyper.app` 即可

### 方法二：修改已编译的二进制（无需源码）

如果你不想编译，可以修改已编译好的 binary：

```bash
# 找到 binary 中的字符串
strings MiddleButtonTyper.app/Contents/MacOS/MiddleButtonTyper | grep "135790"
```

然后用 `sed/vi` 工具替换。但**推荐方法一**，更安全可控。

### 方法三：直接使用 cliclick（不依赖本工具）

```bash
cliclick t:你的文本
```

可以用 Automator / Hammerspoon / Karabiner 等工具触发。

### 技术说明

本工具通过 CGEvent.tapCreate 捕获鼠标中键（buttonNumber=2），
然后调用 cliclick 的 `t:` 命令模拟键盘输入。

绕过 macOS 对 Karabiner shell_command 的键盘事件注入限制。

---

## 🔧 自行编译 | Build from Source

```bash
# 需要 Xcode Command Line Tools
xcode-select --install

# 编译
cd middle-button-typer
swiftc -framework Cocoa -framework CoreGraphics main.swift -o MiddleButtonTyper

# 打包 .app
mkdir -p MiddleButtonTyper.app/Contents/MacOS
cp MiddleButtonTyper MiddleButtonTyper.app/Contents/MacOS/
# 复制 Info.plist 等资源...
codesign --force --deep --sign - MiddleButtonTyper.app
```

完整编译脚本：`build.sh`

---

## 🐛 排错与日志 | TroubleShooting

```bash
# 查看实时日志
tail -f /tmp/middle_button_typer.log

# 日志内容示例
# [10:16:23] 程序启动
# [10:16:23] 鼠标中键监听已启动（LSUIElement 模式）
# [10:16:25] 中键按下，调用 cliclick 输入 135790
```

常见问题：

| 问题 | 原因 | 解决 |
|------|------|------|
| 中键无反应 | 权限未授权 | 检查「辅助功能」列表是否有 MiddleButtonTyper |
| 日志显示"cliclick 执行失败" | cliclick 不在预期路径 | 修改 `main.swift` 中的 `cliclickPath`，重新编译 |
| 按中键触发的是系统功能 | 其他软件拦截了中键 | 检查 Karabiner / Logitech Options 等 |
| 开机自启不生效 | 权限问题 | 改用「登录项」，不要用 launchd |

---

## 📂 文件结构 | File Structure

```
.
├── main.swift                                    # 主程序源码
├── build.sh                                      # 编译脚本
├── install.sh                                    # 一键安装脚本（Login Items + launchd）
├── uninstall.sh                                  # 卸载脚本
├── com.a1-6.middle-button-typer.plist            # 旧 launchd 配置（不再使用）
├── com.cpufreestyle.middle-button-typer.plist    # launchd 模板
├── MiddleButtonTyper.app/                        # 已编译 .app（不提交到 git）
├── MiddleButtonTyper-1.0.2.zip                   # 发布包（不提交到 git）
├── README.md                                     # 本文件
└── .gitignore
```

---

## 💡 原理 | How It Works

1. `CGEvent.tapCreate` 创建一个全局事件监听器（Event Tap）
2. 监听所有鼠标事件，检测 `buttonNumber == 2`（中键）
3. 收到中键 → 调用 `system()` 运行 cliclick 命令
4. cliclick 通过 Accessibility API 注入键盘事件
5. 应用窗口收到文本输入

绕过 macOS 安全沙箱：Karabiner 的 shell_command 运行在上下文隔离中，无法注入键盘事件。
而独立 .app 通过 CGEvent.tap + cliclick，完全合法且有效。

---

## 📜 License

MIT © [cpufreestyle](https://github.com/cpufreestyle)
