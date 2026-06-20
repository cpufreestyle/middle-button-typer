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

func mouseCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    let buttonNumber = event.getIntegerValueField(.mouseEventButtonNumber)
    
    if type == .otherMouseDown && buttonNumber == 2 {
        log("中键按下，调用 cliclick 输入 135790")
        typeString("135790")
        return nil
    }
    
    return Unmanaged.passRetained(event)
}

func setupEventTap() {
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
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        if let source = source {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            log("鼠标中键监听已启动（LSUIElement 模式）")
        } else {
            log("无法创建 RunLoop Source")
        }
    } else {
        log("无法创建事件监听，请检查辅助功能权限")
    }
}

// 使用 LSUIElement=true 隐藏 Dock 图标，不调用 NSApp.setActivationPolicy
log("程序启动")
setupEventTap()
log("进入 RunLoop")
RunLoop.main.run()
