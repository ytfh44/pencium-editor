#!/usr/bin/wish

package require msgcat

# 打印当前程序信息
puts "Running TCL version: [info patchlevel]"
puts "Initial locale: [::msgcat::mclocale]"

# 设置中文翻译
puts "Setting translations..."
::msgcat::mcset zh_cn "Hello" "你好"
::msgcat::mcset zh_cn "World" "世界"
::msgcat::mcset zh_cn "Test Button" "测试按钮" 

# 测试不同区域码的 mc 命令
puts "--- Testing mc command ---"
puts "Current locale: [::msgcat::mclocale]"
puts "mc Hello -> [::msgcat::mc "Hello"]"
puts "mc World -> [::msgcat::mc "World"]"

# 切换到中文
puts "\nChanging locale to zh_cn..."
::msgcat::mclocale zh_cn
puts "Current locale: [::msgcat::mclocale]"
puts "mc Hello -> [::msgcat::mc "Hello"]"
puts "mc World -> [::msgcat::mc "World"]"

# 创建一个简单的 UI 测试
puts "\n--- Creating UI test ---"
# 设置窗口标题
wm title . "I18N Test"

# 创建按钮
button .btn -text [::msgcat::mc "Test Button"] -command {
    puts "Button text: [.btn cget -text]"
    puts "mc translation: [::msgcat::mc "Test Button"]"
    puts "Updating button text..."
    .btn configure -text [::msgcat::mc "Test Button"]
}
pack .btn -padx 20 -pady 20

# 创建标签
label .lbl -text [::msgcat::mc "Hello"]
pack .lbl -padx 20 -pady 20

# 创建动态更新按钮
button .updateBtn -text "Update UI" -command {
    puts "Updating UI..."
    .lbl configure -text [::msgcat::mc "Hello"]
    .btn configure -text [::msgcat::mc "Test Button"]
    wm title . [::msgcat::mc "I18N Test"]
}
pack .updateBtn -padx 20 -pady 20

# 创建语言切换按钮
button .langBtn -text "Switch to Chinese" -command {
    puts "Switching to Chinese..."
    ::msgcat::mclocale zh_cn
    puts "Current locale: [::msgcat::mclocale]"
    # 不更新 UI
}
pack .langBtn -padx 20 -pady 20

# 打印消息数据库
puts "\n--- Message database ---"
if {[info exists ::msgcat::Messages]} {
    foreach key [lsort [array names ::msgcat::Messages]] {
        puts "  $key: $::msgcat::Messages($key)"
    }
} else {
    puts "  No messages found in database"
} 