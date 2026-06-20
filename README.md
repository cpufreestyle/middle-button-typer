# MiddleButtonTyper

macOS 鼠标中键映射工具——把鼠标中键映射为键盘输入 `135790`。

## 背景

Karabiner-Elements 的 `shell_command` 在 macOS 辅助功能沙箱下无法触发键盘事件，本工具用 Swift `CGEvent.tapCreate` 直接捕获鼠标中键，再调用 [cliclick](https://github.com/BlueM/cliclick) 注入键盘输入，完美绕过限制。

## 文件说明

| 文件 | 说明 |
|------|------|
| `main.swift` | 主程序源码，监听鼠标中键并调用 cliclick |
| `build.sh` | 编译脚本 |
| `install.sh` | 安装为 Login Item（开机自启） |
| `com.a1-6.middle-button-typer.plist` | launchd 配置文件（备用） |
| `MiddleButtonTyper.app/` | 打包好的 .app 应用（LSUIElement，无 Dock 图标） |

## 依赖

- macOS 12.0+
- [cliclick](https://github.com/BlueM/cliclick) 已编译二进制放在 `/Users/a1-6/bin/cliclick`
  ```bash
  # 如果没有 cliclick，先编译安装
  git clone https://github.com/BlueM/cliclick.git
  cd cliclick && make
  cp cliclick /Users/a1-6/bin/cliclick
  ```

## 编译

```bash
cd middle-button-typer
./build.sh
```

编译产物：`MiddleButtonTyper.app/`

## 运行

直接打开 .app：

```bash
open MiddleButtonTyper.app
```

或编译后直接运行二进制：

```bash
./MiddleButtonTyper.app/Contents/MacOS/MiddleButtonTyper
```

## 开机自启

**方式一：Login Item（推荐）**

系统设置 → 通用 → 登录项 → 添加 `MiddleButtonTyper.app`

**方式二：launchd**

```bash
./install.sh
```

> 注意：launchd 启动的进程可能无法获取辅助功能权限，建议用方式一。

## 辅助功能授权

首次运行会在系统设置 → 隐私与安全性 → 辅助功能 中提示授权，请允许 `MiddleButtonTyper`。

## 自定义输入内容

修改 `main.swift` 中的：

```swift
typeString("135790")   // 改成你想要的输入内容
```

然后重新编译。

## 查看日志

```bash
tail -f /tmp/middle_button_typer.log
```

## 常见问题

**中键无效？** 先用 Karabiner-Elements EventViewer 确认中键是 `buttonNumber=2`，不同鼠标可能不同。

**cliclick 找不到？** 修改 `main.swift` 中的 `cliclickPath` 变量为你的 cliclick 路径。

## License

MIT
