#!/usr/bin/wish

package require Tk

# 设置窗口标题和大小
wm title . "Pencium Editor"
wm geometry . "1200x800"

# 设置窗口关闭协议
wm protocol . WM_DELETE_WINDOW {
    # 检查是否有未保存的文件
    set has_unsaved 0
    foreach info $::Editor::tabs_info {
        set tab_id [lindex $info 0]
        set filename [lindex $info 1]
        if {[catch {.paned.right.notebook.f$tab_id.text edit modified} modified] == 0 && $modified} {
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
                    if {[catch {.paned.right.notebook.f$tab_id.text edit modified} modified] == 0 && $modified} {
                        .paned.right.notebook select .paned.right.notebook.f$tab_id
                        Editor::save_current_file
                        # 如果是未命名文件且用户取消了保存，则中止关闭
                        if {[lindex $info 1] eq "" && 
                            [lsearch -index 1 $::Editor::tabs_info ""] != -1} {
                            return
                        }
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
    -padding {2 2} \

# 创建全局变量
namespace eval Editor {
    variable current_tab 0
    variable tabs_info {}
    variable current_dir [pwd]
}

# 创建主菜单
menu .menubar
. configure -menu .menubar

# 文件菜单
menu .menubar.file -tearoff 0
.menubar add cascade -label "文件" -menu .menubar.file
.menubar.file add command -label "新建文件" -command {Editor::new_file}
.menubar.file add command -label "打开文件" -command {Editor::open_file}
.menubar.file add command -label "保存" -command {Editor::save_current_file}
.menubar.file add command -label "另存为" -command {Editor::save_as}
.menubar.file add separator
.menubar.file add command -label "退出" -command exit

# 编辑菜单
menu .menubar.edit -tearoff 0
.menubar add cascade -label "编辑" -menu .menubar.edit
.menubar.edit add command -label "撤销" -command {event generate .paned.right.notebook.f$::Editor::current_tab.text <<Undo>>}
.menubar.edit add command -label "重做" -command {event generate .paned.right.notebook.f$::Editor::current_tab.text <<Redo>>}
.menubar.edit add separator
.menubar.edit add command -label "剪切" -command {event generate .paned.right.notebook.f$::Editor::current_tab.text <<Cut>>}
.menubar.edit add command -label "复制" -command {event generate .paned.right.notebook.f$::Editor::current_tab.text <<Copy>>}
.menubar.edit add command -label "粘贴" -command {event generate .paned.right.notebook.f$::Editor::current_tab.text <<Paste>>}

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
ttk::treeview .paned.left.tree -yscrollcommand {.paned.left.scroll set}
scrollbar .paned.left.scroll -orient vertical -command {.paned.left.tree yview}
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

# 定义编辑器相关过程
proc Editor::close_tab {tab_id} {
    variable tabs_info
    variable current_tab
    
    # 获取当前标签页
    set current ".paned.right.notebook.f$tab_id"
    
    # 检查标签页是否存在
    if {![winfo exists $current]} return
    
    # 找到对应的标签页信息
    set idx [lsearch -index 0 $tabs_info $tab_id]
    if {$idx != -1} {
        set fileinfo [lindex $tabs_info $idx]
        set filename [lindex $fileinfo 1]
        
        # 检查文件是否已修改
        if {[catch {$current.text edit modified} modified] == 0 && $modified} {
            set title "未保存的更改"
            set message "文件 [expr {$filename eq "" ? "未命名-$tab_id" : [file tail $filename]}] 有未保存的更改。\n\n【是】保存更改\n【否】不保存更改\n【取消】不关闭"
            set answer [tk_messageBox -icon question -message $message -title $title -type yesnocancel]
            
            switch -- $answer {
                yes {
                    if {$filename eq ""} {
                        set filename [tk_getSaveFile]
                        if {$filename eq ""} return
                    }
                    if {[catch {
                        set fh [open $filename w]
                        puts -nonewline $fh [$current.text get 1.0 end]
                        close $fh
                    } err]} {
                        tk_messageBox -icon error -message "保存失败: $err"
                        return
                    }
                }
                cancel {
                    return
                }
            }
        }
        
        # 移除标签页信息
        set tabs_info [lreplace $tabs_info $idx $idx]
    }
    
    # 移除标签页
    .paned.right.notebook forget $current
    
    # 如果没有标签页了，创建一个新的
    if {[llength [.paned.right.notebook tabs]] == 0} {
        after idle Editor::new_file
    }
}

proc Editor::new_file {} {
    variable current_tab
    variable tabs_info
    
    set f [frame .paned.right.notebook.f$current_tab]
    text $f.text -wrap none -undo 1 -font {Monospace 10} \
        -yscrollcommand "$f.scrolly set" \
        -xscrollcommand "$f.scrollx set"
    scrollbar $f.scrolly -orient vertical -command "$f.text yview"
    scrollbar $f.scrollx -orient horizontal -command "$f.text xview"
    
    grid $f.text -row 0 -column 0 -sticky nsew
    grid $f.scrolly -row 0 -column 1 -sticky ns
    grid $f.scrollx -row 1 -column 0 -sticky ew
    grid rowconfigure $f 0 -weight 1
    grid columnconfigure $f 0 -weight 1
    
    # 启用修改跟踪
    $f.text edit modified 0
    
    .paned.right.notebook add $f -text "未命名-$current_tab"
    
    # 绑定标签页的右键菜单
    bind $f <Button-3> {
        tk_popup .tabmenu %X %Y
    }
    
    lappend tabs_info [list $current_tab "" 0]
    
    # 使用 after idle 确保标签页已完全创建后再选择
    after idle [list .paned.right.notebook select $f]
    after idle [list focus $f.text]
    
    incr current_tab
}

proc Editor::open_file {{filename ""}} {
    variable current_tab
    variable tabs_info
    
    if {$filename eq ""} {
        set filename [tk_getOpenFile]
        if {$filename eq ""} return
    }
    
    # 检查文件是否已经打开
    foreach info $tabs_info {
        set tab_id [lindex $info 0]
        set tab_file [lindex $info 1]
        if {$tab_file eq $filename} {
            .paned.right.notebook select .paned.right.notebook.f$tab_id
            focus .paned.right.notebook.f$tab_id.text
            return
        }
    }
    
    set f [frame .paned.right.notebook.f$current_tab]
    text $f.text -wrap none -undo 1 -font {Monospace 10} \
        -yscrollcommand "$f.scrolly set" \
        -xscrollcommand "$f.scrollx set"
    scrollbar $f.scrolly -orient vertical -command "$f.text yview"
    scrollbar $f.scrollx -orient horizontal -command "$f.text xview"
    
    grid $f.text -row 0 -column 0 -sticky nsew
    grid $f.scrolly -row 0 -column 1 -sticky ns
    grid $f.scrollx -row 1 -column 0 -sticky ew
    grid rowconfigure $f 0 -weight 1
    grid columnconfigure $f 0 -weight 1
    
    if {[catch {
        set fh [open $filename r]
        $f.text insert 1.0 [read $fh]
        close $fh
    } err]} {
        tk_messageBox -icon error -message "无法打开文件: $err"
        destroy $f
        return
    }
    
    .paned.right.notebook add $f -text [file tail $filename]
    
    # 绑定标签页的右键菜单
    bind $f <Button-3> {
        tk_popup .tabmenu %X %Y
    }
    
    lappend tabs_info [list $current_tab $filename 0]
    
    # 使用 after idle 确保标签页已完全创建后再选择
    after idle [list .paned.right.notebook select $f]
    after idle [list focus $f.text]
    
    incr current_tab
}

proc Editor::save_current_file {} {
    variable current_tab
    variable tabs_info
    
    set current [.paned.right.notebook select]
    if {$current eq ""} return
    
    set idx [lsearch -index 0 $tabs_info [string range $current end end]]
    if {$idx == -1} return
    
    set fileinfo [lindex $tabs_info $idx]
    set filename [lindex $fileinfo 1]
    
    if {$filename eq ""} {
        Editor::save_as
    } else {
        if {[catch {
            set fh [open $filename w]
            puts -nonewline $fh [.paned.right.notebook.$current.text get 1.0 end]
            close $fh
        } err]} {
            tk_messageBox -icon error -message "保存失败: $err"
        }
    }
}

proc Editor::save_as {} {
    variable tabs_info
    
    set current [.paned.right.notebook select]
    if {$current eq ""} return
    
    set filename [tk_getSaveFile]
    if {$filename eq ""} return
    
    if {[catch {
        set fh [open $filename w]
        puts -nonewline $fh [.paned.right.notebook.$current.text get 1.0 end]
        close $fh
    } err]} {
        tk_messageBox -icon error -message "保存失败: $err"
        return
    }
    
    set idx [lsearch -index 0 $tabs_info [string range $current end end]]
    if {$idx != -1} {
        set fileinfo [lindex $tabs_info $idx]
        set tabs_info [lreplace $tabs_info $idx $idx [list [lindex $fileinfo 0] $filename 0]]
        .paned.right.notebook tab $current -text [file tail $filename]
    }
}

# 初始化文件树
proc Editor::init_file_tree {} {
    variable current_dir
    .paned.left.tree delete [.paned.left.tree children {}]
    Editor::populate_tree "" $current_dir
}

proc Editor::populate_tree {parent dir} {
    foreach item [lsort [glob -nocomplain -directory $dir -tails *]] {
        set fullpath [file join $dir $item]
        set id [.paned.left.tree insert $parent end -text $item]
        if {[file isdirectory $fullpath]} {
            .paned.left.tree insert $id end -text "dummy"
            .paned.left.tree item $id -text "📁 $item"
        } else {
            .paned.left.tree item $id -text "📄 $item"
        }
    }
}

# 获取树节点完整路径
proc Editor::get_full_path {tree id} {
    set path {}
    while {$id ne ""} {
        set text [$tree item $id -text]
        # 移除文件图标前缀
        if {[string match "📁 *" $text]} {
            set text [string range $text 3 end]
        } elseif {[string match "📄 *" $text]} {
            set text [string range $text 3 end]
        }
        set path [linsert $path 0 $text]
        set id [$tree parent $id]
    }
    return $path
}

# 绑定文件树展开事件
bind .paned.left.tree <<TreeviewOpen>> {
    set tree %W
    set id [$tree focus]
    
    $tree delete [$tree children $id]
    
    set dir [file join $::Editor::current_dir {*}[Editor::get_full_path $tree $id]]
    Editor::populate_tree $id $dir
}

# 绑定文件树选择事件
bind .paned.left.tree <<TreeviewSelect>> {
    set tree %W
    set id [$tree selection]
    if {$id ne ""} {
        set fullpath [file join $::Editor::current_dir {*}[Editor::get_full_path $tree $id]]
        if {[file isfile $fullpath]} {
            Editor::open_file $fullpath
        }
    }
}

# 删除旧的双击事件绑定
bind .paned.left.tree <Double-1> {}

# 初始化编辑器
Editor::new_file
Editor::init_file_tree

# 绑定快捷键
bind . <Control-n> {Editor::new_file}
bind . <Control-o> {Editor::open_file}
bind . <Control-s> {Editor::save_current_file}
bind . <Control-Shift-s> {Editor::save_as}
bind . <Control-w> {
    set current [.paned.right.notebook select]
    if {$current ne ""} {
        Editor::close_tab [string range $current end end]
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