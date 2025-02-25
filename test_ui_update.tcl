#!/usr/bin/wish

package require msgcat

# 打印当前程序信息
puts "Running TCL version: [info patchlevel]"
puts "Initial locale: [::msgcat::mclocale]"

# 创建翻译数据
proc setup_translations {} {
    puts "Setting up translations..."
    
    # 中文翻译
    ::msgcat::mcset zh_cn "Test Application" "测试应用程序"
    ::msgcat::mcset zh_cn "File" "文件"
    ::msgcat::mcset zh_cn "Edit" "编辑"
    ::msgcat::mcset zh_cn "Help" "帮助"
    ::msgcat::mcset zh_cn "Open" "打开"
    ::msgcat::mcset zh_cn "Save" "保存"
    ::msgcat::mcset zh_cn "Exit" "退出"
    ::msgcat::mcset zh_cn "Cut" "剪切"
    ::msgcat::mcset zh_cn "Copy" "复制"
    ::msgcat::mcset zh_cn "Paste" "粘贴"
    ::msgcat::mcset zh_cn "About" "关于"
    ::msgcat::mcset zh_cn "English" "英语"
    ::msgcat::mcset zh_cn "Chinese" "中文"
    ::msgcat::mcset zh_cn "Switch Language" "切换语言"
    ::msgcat::mcset zh_cn "Update UI" "更新界面"
    
    # 英文翻译（默认值，可以省略）
    ::msgcat::mcset en_us "Test Application" "Test Application"
    ::msgcat::mcset en_us "File" "File"
    ::msgcat::mcset en_us "Edit" "Edit"
    ::msgcat::mcset en_us "Help" "Help"
    ::msgcat::mcset en_us "Open" "Open"
    ::msgcat::mcset en_us "Save" "Save"
    ::msgcat::mcset en_us "Exit" "Exit"
    ::msgcat::mcset en_us "Cut" "Cut"
    ::msgcat::mcset en_us "Copy" "Copy"
    ::msgcat::mcset en_us "Paste" "Paste"
    ::msgcat::mcset en_us "About" "About"
    ::msgcat::mcset en_us "English" "English"
    ::msgcat::mcset en_us "Chinese" "Chinese"  
    ::msgcat::mcset en_us "Switch Language" "Switch Language"
    ::msgcat::mcset en_us "Update UI" "Update UI"
}

# 更新所有 UI 元素的文本
proc update_ui {} {
    global menu_indices
    
    puts "Updating UI with locale: [::msgcat::mclocale]"
    
    # 更新窗口标题
    wm title . [::msgcat::mc "Test Application"]
    
    # 更新主菜单
    .menubar entryconfigure $menu_indices(file) -label [::msgcat::mc "File"]
    .menubar entryconfigure $menu_indices(edit) -label [::msgcat::mc "Edit"]
    .menubar entryconfigure $menu_indices(help) -label [::msgcat::mc "Help"]
    
    # 更新文件菜单
    .menubar.file entryconfigure $menu_indices(open) -label [::msgcat::mc "Open"]
    .menubar.file entryconfigure $menu_indices(save) -label [::msgcat::mc "Save"]
    .menubar.file entryconfigure $menu_indices(exit) -label [::msgcat::mc "Exit"]
    
    # 更新编辑菜单
    .menubar.edit entryconfigure $menu_indices(cut) -label [::msgcat::mc "Cut"]
    .menubar.edit entryconfigure $menu_indices(copy) -label [::msgcat::mc "Copy"]
    .menubar.edit entryconfigure $menu_indices(paste) -label [::msgcat::mc "Paste"]
    
    # 更新帮助菜单
    .menubar.help entryconfigure $menu_indices(about) -label [::msgcat::mc "About"]
    
    # 更新语言菜单
    .menubar.lang entryconfigure $menu_indices(en) -label [::msgcat::mc "English"]
    .menubar.lang entryconfigure $menu_indices(zh) -label [::msgcat::mc "Chinese"]
    
    # 更新按钮
    .btn configure -text [::msgcat::mc "Update UI"]
    
    # 更新标签
    .lbl configure -text [::msgcat::mc "Current locale: [::msgcat::mclocale]"]
    
    # 强制刷新
    update idletasks
}

# 设置初始区域码和翻译
::msgcat::mclocale en_us
setup_translations

# 创建 UI
wm title . [::msgcat::mc "Test Application"]
wm geometry . 400x300

# 创建主菜单
menu .menubar
. configure -menu .menubar

# 文件菜单
menu .menubar.file -tearoff 0
.menubar add cascade -label [::msgcat::mc "File"] -menu .menubar.file
.menubar.file add command -label [::msgcat::mc "Open"] -command {
    puts "Open command"
}
.menubar.file add command -label [::msgcat::mc "Save"] -command {
    puts "Save command"
}
.menubar.file add separator
.menubar.file add command -label [::msgcat::mc "Exit"] -command {
    exit
}

# 编辑菜单
menu .menubar.edit -tearoff 0
.menubar add cascade -label [::msgcat::mc "Edit"] -menu .menubar.edit
.menubar.edit add command -label [::msgcat::mc "Cut"] -command {
    puts "Cut command"
}
.menubar.edit add command -label [::msgcat::mc "Copy"] -command {
    puts "Copy command"
}
.menubar.edit add command -label [::msgcat::mc "Paste"] -command {
    puts "Paste command"
}

# 帮助菜单
menu .menubar.help -tearoff 0
.menubar add cascade -label [::msgcat::mc "Help"] -menu .menubar.help
.menubar.help add command -label [::msgcat::mc "About"] -command {
    puts "About command"
}

# 语言菜单
menu .menubar.lang -tearoff 0
.menubar add cascade -label [::msgcat::mc "Switch Language"] -menu .menubar.lang
.menubar.lang add radiobutton -label [::msgcat::mc "English"] -value "en_us" \
    -variable locale -command {
        puts "\nSwitching to English..."
        ::msgcat::mclocale en_us
        # 注意：这里没有调用 update_ui
        puts "Locale changed to: [::msgcat::mclocale]"
        puts "但 UI 不会自动更新！"
    }
.menubar.lang add radiobutton -label [::msgcat::mc "Chinese"] -value "zh_cn" \
    -variable locale -command {
        puts "\nSwitching to Chinese..."
        ::msgcat::mclocale zh_cn
        # 注意：这里没有调用 update_ui
        puts "Locale changed to: [::msgcat::mclocale]"
        puts "但 UI 不会自动更新！"
    }

# 保存菜单索引
global menu_indices
array set menu_indices {
    file 0
    edit 1
    help 2
    lang 3
    open 0
    save 1
    exit 3
    cut 0
    copy 1
    paste 2
    about 0
    en 0
    zh 1
}

# 创建按钮
button .btn -text [::msgcat::mc "Update UI"] -command {
    update_ui
}
pack .btn -padx 20 -pady 20

# 创建标签
label .lbl -text [::msgcat::mc "Current locale: [::msgcat::mclocale]"]
pack .lbl -padx 20 -pady 20

# 创建解释性文本
text .txt -width 40 -height 10 -wrap word
pack .txt -padx 20 -pady 20 -fill both -expand 1

.txt insert end "这是测试脚本，演示如何手动更新 UI。\n\n"
.txt insert end "这个脚本证明：\n"
.txt insert end "1. Tcl 中的 [mc] 命令只在调用时计算翻译值\n"
.txt insert end "2. UI 元素创建后不会随语言更改自动更新\n"
.txt insert end "3. 需要手动调用 update_ui 函数来更新 UI\n\n"
.txt insert end "请通过菜单切换语言，然后点击\"更新 UI\"按钮查看效果。"
.txt configure -state disabled 