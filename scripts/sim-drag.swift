#!/usr/bin/swift
import AppKit
import CoreGraphics
import Foundation

/// 把 HID 拖拽打进 Simulator 窗口（设备像素 → 屏幕坐标）。
enum SimDrag {
    static func windowFrame() -> CGRect {
        let src = """
        tell application "System Events"
          tell process "Simulator"
            set p to position of window 1
            set s to size of window 1
            return (item 1 of p as text) & "," & (item 2 of p as text) & "," & (item 1 of s as text) & "," & (item 2 of s as text)
          end tell
        end tell
        """
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        proc.arguments = ["-e", src]
        let out = Pipe()
        proc.standardOutput = out
        try? proc.run()
        proc.waitUntilExit()
        let text = String(data: out.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let parts = text.split(separator: ",").compactMap { Double($0) }
        guard parts.count == 4 else {
            fputs("无法读取 Simulator 窗口: \(text)\n", stderr)
            exit(1)
        }
        return CGRect(x: parts[0], y: parts[1], width: parts[2], height: parts[3])
    }

    /// 设备 framebuffer 像素 → 屏幕点。假定窗口顶栏约 52pt，其余为屏。
    static func screenPoint(deviceX: CGFloat, deviceY: CGFloat, fb: CGSize, window: CGRect) -> CGPoint {
        let title: CGFloat = 52
        let content = CGRect(x: window.minX, y: window.minY + title, width: window.width, height: window.height - title)
        let x = content.minX + deviceX / fb.width * content.width
        let y = content.minY + deviceY / fb.height * content.height
        return CGPoint(x: x, y: y)
    }

    static func drag(from: CGPoint, to: CGPoint, duration: TimeInterval) {
        let src = CGEventSource(stateID: .hidSystemState)
        let down = CGEvent(
            mouseEventSource: src,
            mouseType: .leftMouseDown,
            mouseCursorPosition: from,
            mouseButton: .left
        )
        down?.post(tap: .cghidEventTap)
        let steps = max(12, Int(duration * 60))
        for i in 1...steps {
            Thread.sleep(forTimeInterval: duration / Double(steps))
            let t = CGFloat(i) / CGFloat(steps)
            let p = CGPoint(
                x: from.x + (to.x - from.x) * t,
                y: from.y + (to.y - from.y) * t
            )
            let moved = CGEvent(
                mouseEventSource: src,
                mouseType: .leftMouseDragged,
                mouseCursorPosition: p,
                mouseButton: .left
            )
            moved?.post(tap: .cghidEventTap)
        }
        let up = CGEvent(
            mouseEventSource: src,
            mouseType: .leftMouseUp,
            mouseCursorPosition: to,
            mouseButton: .left
        )
        up?.post(tap: .cghidEventTap)
        Thread.sleep(forTimeInterval: 0.05)
    }
}

let args = CommandLine.arguments
guard args.count >= 5 else {
    fputs("usage: sim-drag.swift fromX fromY toX toY [duration]\n", stderr)
    exit(2)
}
let fx = CGFloat(Double(args[1]) ?? 0)
let fy = CGFloat(Double(args[2]) ?? 0)
let tx = CGFloat(Double(args[3]) ?? 0)
let ty = CGFloat(Double(args[4]) ?? 0)
let duration = args.count > 5 ? (Double(args[5]) ?? 0.45) : 0.45
let fb = CGSize(width: 1206, height: 2622)
let window = SimDrag.windowFrame()
let from = SimDrag.screenPoint(deviceX: fx, deviceY: fy, fb: fb, window: window)
let to = SimDrag.screenPoint(deviceX: tx, deviceY: ty, fb: fb, window: window)
FileHandle.standardError.write(Data("drag window=\(window) from=\(from) to=\(to)\n".utf8))
let app = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.iphonesimulator").first
app?.activate()
Thread.sleep(forTimeInterval: 0.2)
SimDrag.drag(from: from, to: to, duration: duration)
