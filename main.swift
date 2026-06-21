import Cocoa
import CoreGraphics
import Foundation

let logPath = "/tmp/middle_button_typer.log"

func log(_ message: String) {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let timestamp = formatter.string(from: Date())
    let line = "[\(timestamp)] \(message)\n"
    if let data = line.data(using: .utf8) {
        if FileManager.default.fileExists(atPath: logPath) {
            let handle = FileHandle(forWritingAtPath: logPath)
            handle?.seekToEndOfFile()
            handle?.write(data)
            handle?.closeFile()
        } else {
            try? data.write(to: URL(fileURLWithPath: logPath))
        }
    }
}

let cliclickPath = "/Users/a1-6/bin/cliclick"

func typeString(_ string: String) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: cliclickPath)
    task.arguments = ["t:\(string)"]
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    task.standardOutput = outputPipe
    task.standardError = errorPipe
    do {
        try task.run()
        task.waitUntilExit()
        if task.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorText = String(data: errorData, encoding: .utf8) ?? "unknown error"
            log("cliclick 失败 (exit \(task.terminationStatus)): \(errorText)")
        }
    } catch {
        log("cliclick 调用失败: \(error.localizedDescription)")
    }
}

// 全局状态，用于重置 tap
var currentTap: CFMachPort? = nil
var currentSource: CFRunLoopSource? = nil

func teardownEventTap() {
    if let tap = currentTap {
        CGEvent.tapEnable(tap: tap, enable: false)
        if let source = currentSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }
        currentTap = nil
        currentSource = nil
    }
}

func setupEventTap() -> Bool {
    teardownEventTap()

    let eventMask: CGEventMask =
        (1 << CGEventType.otherMouseDown.rawValue) |
        (1 << CGEventType.otherMouseUp.rawValue)

    let tap = CGEvent.tapCreate(
        tap: .cgSessionEventTap,
        place: .headInsertEventTap,
        options: .defaultTap,
        eventsOfInterest: eventMask,
        callback: mouseCallback,
        userInfo: nil
    )

    if let tap = tap {
        currentTap = tap
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        if let source = source {
            currentSource = source
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            log("鼠标中键监听已启动")
            return true
        } else {
            log("无法创建 RunLoop Source")
            currentTap = nil
            return false
        }
    } else {
        log("无法创建事件监听，请检查辅助功能权限")
        return false
    }
}

func mouseCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    // 处理 tap 被系统超时禁用的事件
    if type == .tapDisabledByTimeout {
        log("事件监听被系统超时禁用，正在重新启用...")
        if let tap = currentTap {
            CGEvent.tapEnable(tap: tap, enable: true)
            log("事件监听已重新启用")
        }
        return nil
    }

    if type == .tapDisabledByUserInput {
        log("事件监听被用户禁用（可能在「辅助功能」中取消了授权）")
        return nil
    }

    let buttonNumber = event.getIntegerValueField(.mouseEventButtonNumber)

    if type == .otherMouseDown && buttonNumber == 2 {
        log("中键按下，调用 cliclick 输入 135790")
        typeString("135790")
        return nil
    }

    return Unmanaged.passRetained(event)
}

func handleWake(_ notification: Notification) {
    log("系统唤醒，重新初始化事件监听...")
    _ = setupEventTap()
}

func handleSleep(_ notification: Notification) {
    log("系统即将休眠，暂时禁用事件监听")
    teardownEventTap()
}

func registerSleepWakeHandlers() {
    let workspace = NSWorkspace.shared
    let center = workspace.notificationCenter

    center.addObserver(
        forName: NSWorkspace.didWakeNotification,
        object: nil,
        queue: .main,
        using: handleWake
    )

    center.addObserver(
        forName: NSWorkspace.willSleepNotification,
        object: nil,
        queue: .main,
        using: handleSleep
    )

    log("已注册休眠/唤醒监听")
}

// 启动
log("程序启动")
_ = setupEventTap()
registerSleepWakeHandlers()
log("进入 RunLoop")
RunLoop.main.run()
