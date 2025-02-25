#!/usr/bin/wish

# 创建一个简单的菜单测试
wm title . "菜单测试"
wm geometry . 400x300

# 创建主菜单
menu .mb
. configure -menu .mb

# 添加菜单项
.mb add cascade -label "文件" -menu .mb.file
.mb add cascade -label "编辑" -menu .mb.edit

# 创建子菜单
menu .mb.file -tearoff 0
.mb.file add command -label "打开" -command {puts "打开"}
.mb.file add command -label "保存" -command {puts "保存"}
.mb.file add separator
.mb.file add command -label "退出" -command {exit}

menu .mb.edit -tearoff 0
.mb.edit add command -label "复制" -command {puts "复制"}
.mb.edit add command -label "粘贴" -command {puts "粘贴"}

# 创建按钮切换菜单语言
button .btn1 -text "切换为英文" -command {
    puts "切换菜单为英文..."
    # 打印菜单信息
    puts "菜单类型: [winfo class .mb]"
    puts "菜单项数量: [.mb index end]"
    
    # 获取当前菜单标签
    set old_label [lindex [.mb entrycget 0 -label] end]
    puts "当前第一个菜单项: $old_label"
    
    # 尝试更新菜单标签
    if {[catch {
        .mb entryconfigure 0 -label "File"
        .mb entryconfigure 1 -label "Edit"
        puts "更新成功"
    } err]} {
        puts "更新失败: $err"
    }
}

button .btn2 -text "切换为中文" -command {
    puts "切换菜单为中文..."
    # 尝试更新菜单标签
    if {[catch {
        .mb entryconfigure 0 -label "文件"
        .mb entryconfigure 1 -label "编辑"
        puts "更新成功"
    } err]} {
        puts "更新失败: $err"
    }
}

# 放置按钮
pack .btn1 -pady 10
pack .btn2 -pady 10 