#!/usr/bin/wish

package require Tk

# 加载模块
source [file join [file dirname [info script]] "impl/treeview_impl.tcl"]
source [file join [file dirname [info script]] "impl/editor_impl.tcl"]
source [file join [file dirname [info script]] "impl/highlighter_impl.tcl"]
source [file join [file dirname [info script]] "impl/lsp_impl.tcl"]

# 设置窗口标题和大小
wm title . "Pencium Editor"
wm geometry . "1200x800"

# 设置窗口关闭协议
wm protocol . WM_DELETE_WINDOW {
    # 检查是否有未保存的文件
    set has_unsaved 0
    foreach info $::Editor::tabs_info {
        set tab_id [lindex $info 0]
        if {[Editor::is_modified $tab_id]} {
            set has_unsaved 1
            break
        }
    }
    
    if {$has_unsaved} {
        set answer [tk_messageBox -icon question -title "未保存的更改" \
            -message "有未保存的更改。\n\n【是】保存所有更改\n【否】放弃更改\n【取消】不关闭" \
            -type yesnocancel]
        
        switch -- $answer {
            yes {
                # 保存所有更改
                foreach info $::Editor::tabs_info {
                    set tab_id [lindex $info 0]
                    if {[Editor::is_modified $tab_id]} {
                        Editor::select_tab $tab_id
                        if {![Editor::save_file]} return
                    }
                }
                exit
            }
            no {
                exit
            }
            cancel {
                return
            }
        }
    } else {
        exit
    }
}

# 设置标签页样式
ttk::style configure TNotebook.Tab -padding {5 2}
ttk::style layout TNotebook.Tab {
    Notebook.tab -children {
        Notebook.padding -side top -sticky nswe -children {
            Notebook.label -side left -sticky {}
            Notebook.close -side right -sticky {}
        }
    }
}

# 创建关闭按钮图片
set closeImg [image create photo -data {
    R0lGODlhDAAMAKEBAAAAAP///////////yH5BAEKAAIALAAAAAAMAAwAAAIVhI+py+0Po5y02ouz3rz7D4biSIUFADs=
}]

ttk::style element create Notebook.close image $closeImg \
    -sticky e \
    -padding {2 2}

# 创建主菜单
menu .menubar
. configure -menu .menubar

# 文件菜单
menu .menubar.file -tearoff 0
.menubar add cascade -label "文件" -menu .menubar.file
.menubar.file add command -label "新建文件" -command {Editor::new_tab}
.menubar.file add command -label "打开文件" -command {Editor::open_file}
.menubar.file add command -label "保存" -command {Editor::save_file}
.menubar.file add command -label "另存为" -command {Editor::save_as}
.menubar.file add separator
.menubar.file add command -label "退出" -command exit

# 编辑菜单
menu .menubar.edit -tearoff 0
.menubar add cascade -label "编辑" -menu .menubar.edit
.menubar.edit add command -label "撤销" -command {
    event generate .paned.right.notebook.f[Editor::get_current_tab].text <<Undo>>
}
.menubar.edit add command -label "重做" -command {
    event generate .paned.right.notebook.f[Editor::get_current_tab].text <<Redo>>
}
.menubar.edit add separator
.menubar.edit add command -label "剪切" -command {
    event generate .paned.right.notebook.f[Editor::get_current_tab].text <<Cut>>
}
.menubar.edit add command -label "复制" -command {
    event generate .paned.right.notebook.f[Editor::get_current_tab].text <<Copy>>
}
.menubar.edit add command -label "粘贴" -command {
    event generate .paned.right.notebook.f[Editor::get_current_tab].text <<Paste>>
}

# 视图菜单
menu .menubar.view -tearoff 0
.menubar add cascade -label "视图" -menu .menubar.view
.menubar.view add command -label "切换文件树" -command {
    if {[winfo ismapped .paned.left]} {
        .paned forget .paned.left
    } else {
        .paned add .paned.left -before .paned.right
    }
}
.menubar.view add command -label "切换终端" -command {
    if {[winfo ismapped .paned.right.terminal]} {
        grid remove .paned.right.terminal
        grid rowconfigure .paned.right 1 -minsize 0
    } else {
        grid .paned.right.terminal -row 1 -column 0 -sticky nsew
        grid rowconfigure .paned.right 1 -minsize 200
    }
}

# 创建主面板
panedwindow .paned -orient horizontal
pack .paned -fill both -expand 1

# 左侧文件树面板
frame .paned.left -width 200
ttk::treeview .paned.left.tree
scrollbar .paned.left.scroll -orient vertical
TreeView::init .paned.left.tree .paned.left.scroll
pack .paned.left.scroll -side right -fill y
pack .paned.left.tree -side left -fill both -expand 1
.paned add .paned.left

# 右侧编辑区
frame .paned.right
.paned add .paned.right

# 创建标签页notebook
ttk::notebook .paned.right.notebook
pack .paned.right.notebook -fill both -expand 1

# 创建标签页右键菜单
menu .tabmenu -tearoff 0
.tabmenu add command -label "关闭" -command {
    set current [.paned.right.notebook select]
    if {$current ne ""} {
        Editor::close_tab [string range $current end end]
    }
}

# 创建终端区域
frame .paned.right.terminal
text .paned.right.terminal.text -bg black -fg white -font {Monospace 10} -insertbackground white -height 10
pack .paned.right.terminal.text -fill both -expand 1

# 初始化布局
grid .paned.right.notebook -row 0 -column 0 -sticky nsew
grid rowconfigure .paned.right 0 -weight 1
grid columnconfigure .paned.right 0 -weight 1

# 初始状态下不显示终端
grid remove .paned.right.terminal
grid rowconfigure .paned.right 1 -minsize 0

# 绑定文件树事件
TreeView::on_select .paned.left.tree {Editor::open_file}
bind .paned.left.tree <<TreeviewOpen>> {
    TreeView::expand %W [%W focus]
}

# 绑定关闭按钮点击事件
bind TNotebook <Button-1> {
    set tabset %W
    set clicked [$tabset identify tab %x %y]
    if {$clicked != -1} {
        if {[string match "*close" [$tabset identify element %x %y]]} {
            set current [$tabset select]
            if {$current ne ""} {
                set tab_id [string range $current end end]
                if {[string is integer -strict $tab_id]} {
                    Editor::close_tab $tab_id
                }
            }
        }
    }
}

# 设置终端命令提示符
.paned.right.terminal.text insert end "$ "
.paned.right.terminal.text mark set insert end

# 绑定终端回车事件
bind .paned.right.terminal.text <Return> {
    set cmd [string trim [.paned.right.terminal.text get "insert linestart" "insert"]]
    if {[string match "$ *" $cmd]} {
        set cmd [string range $cmd 2 end]
        if {$cmd ne ""} {
            if {[catch {
                set result [exec {*}[split $cmd] 2>@1]
                .paned.right.terminal.text insert end "\n$result"
            } err]} {
                .paned.right.terminal.text insert end "\n$err"
            }
        }
    }
    .paned.right.terminal.text insert end "\n$ "
    .paned.right.terminal.text see end
    break
}

# 绑定快捷键
bind . <Control-n> {Editor::new_tab}
bind . <Control-o> {Editor::open_file}
bind . <Control-s> {Editor::save_file}
bind . <Control-Shift-s> {Editor::save_as}
bind . <Control-w> {
    set current [.paned.right.notebook select]
    if {$current ne ""} {
        Editor::close_tab [string range $current end end]
    }
}

# 初始化编辑器
Editor::new_tab 