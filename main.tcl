#!/usr/bin/wish

package require Tk
package require msgcat

# 设置语言环境
namespace eval ::I18N {
    variable current_locale "zh_CN"  ;# 默认使用中文
    
    proc init {} {
        variable current_locale
        ::msgcat::mclocale $current_locale
        ::msgcat::mcload [file join [file dirname [info script]] "locale"]
    }
    
    proc switch_locale {locale} {
        variable current_locale
        set current_locale $locale
        ::msgcat::mclocale $locale
        ::msgcat::mcload [file join [file dirname [info script]] "locale"]
    }
}

namespace import ::msgcat::mc
::I18N::init

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
        set answer [tk_messageBox -icon question -title [mc "Unsaved Changes"] \
            -message [mc "There are unsaved changes.\n\nYes: Save all changes\nNo: Discard changes\nCancel: Don't close"] \
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
.menubar add cascade -label [mc "File"] -menu .menubar.file
.menubar.file add command -label [mc "New File"] -command {Editor::new_tab}
.menubar.file add command -label [mc "Open File"] -command {Editor::open_file}
.menubar.file add command -label [mc "Save"] -command {Editor::save_file}
.menubar.file add command -label [mc "Save As"] -command {Editor::save_as}
.menubar.file add separator
.menubar.file add command -label [mc "Exit"] -command exit

# 编辑菜单
menu .menubar.edit -tearoff 0
.menubar add cascade -label [mc "Edit"] -menu .menubar.edit
.menubar.edit add command -label [mc "Undo"] -command {
    event generate .paned.right.notebook.f[Editor::get_current_tab].text <<Undo>>
}
.menubar.edit add command -label [mc "Redo"] -command {
    event generate .paned.right.notebook.f[Editor::get_current_tab].text <<Redo>>
}
.menubar.edit add separator
.menubar.edit add command -label [mc "Cut"] -command {
    event generate .paned.right.notebook.f[Editor::get_current_tab].text <<Cut>>
}
.menubar.edit add command -label [mc "Copy"] -command {
    event generate .paned.right.notebook.f[Editor::get_current_tab].text <<Copy>>
}
.menubar.edit add command -label [mc "Paste"] -command {
    event generate .paned.right.notebook.f[Editor::get_current_tab].text <<Paste>>
}

# 视图菜单
menu .menubar.view -tearoff 0
.menubar add cascade -label [mc "View"] -menu .menubar.view
.menubar.view add command -label [mc "Toggle File Tree"] -command {
    if {[winfo ismapped .paned.left]} {
        .paned forget .paned.left
    } else {
        .paned add .paned.left -before .paned.right
    }
}
.menubar.view add command -label [mc "Toggle Terminal"] -command {
    if {[winfo ismapped .paned.right.terminal]} {
        grid remove .paned.right.terminal
        grid rowconfigure .paned.right 1 -minsize 0
    } else {
        grid .paned.right.terminal -row 1 -column 0 -sticky nsew
        grid rowconfigure .paned.right 1 -minsize 200
    }
}

# 语言菜单
menu .menubar.lang -tearoff 0
.menubar add cascade -label [mc "Language"] -menu .menubar.lang
.menubar.lang add radiobutton -label "English" -value "en_US" \
    -variable ::I18N::current_locale -command {
        ::I18N::switch_locale $::I18N::current_locale
        update_ui
    }
.menubar.lang add radiobutton -label "简体中文" -value "zh_CN" \
    -variable ::I18N::current_locale -command {
        ::I18N::switch_locale $::I18N::current_locale
        update_ui
    }

# 更新UI文本的过程
proc update_ui {} {
    # 保存当前菜单索引
    set file_idx [.menubar index "File"]
    set edit_idx [.menubar index "Edit"]
    set view_idx [.menubar index "View"]
    set lang_idx [.menubar index "Language"]
    
    # 更新窗口标题
    wm title . "Pencium Editor"
    
    # 更新菜单标签
    .menubar entryconfigure $file_idx -label [mc "File"]
    .menubar entryconfigure $edit_idx -label [mc "Edit"]
    .menubar entryconfigure $view_idx -label [mc "View"]
    .menubar entryconfigure $lang_idx -label [mc "Language"]
    
    # 保存文件菜单索引
    set new_file_idx [.menubar.file index "New File"]
    set open_file_idx [.menubar.file index "Open File"]
    set save_idx [.menubar.file index "Save"]
    set save_as_idx [.menubar.file index "Save As"]
    set exit_idx [.menubar.file index "Exit"]
    
    # 更新文件菜单
    .menubar.file entryconfigure $new_file_idx -label [mc "New File"]
    .menubar.file entryconfigure $open_file_idx -label [mc "Open File"]
    .menubar.file entryconfigure $save_idx -label [mc "Save"]
    .menubar.file entryconfigure $save_as_idx -label [mc "Save As"]
    .menubar.file entryconfigure $exit_idx -label [mc "Exit"]
    
    # 保存编辑菜单索引
    set undo_idx [.menubar.edit index "Undo"]
    set redo_idx [.menubar.edit index "Redo"]
    set cut_idx [.menubar.edit index "Cut"]
    set copy_idx [.menubar.edit index "Copy"]
    set paste_idx [.menubar.edit index "Paste"]
    
    # 更新编辑菜单
    .menubar.edit entryconfigure $undo_idx -label [mc "Undo"]
    .menubar.edit entryconfigure $redo_idx -label [mc "Redo"]
    .menubar.edit entryconfigure $cut_idx -label [mc "Cut"]
    .menubar.edit entryconfigure $copy_idx -label [mc "Copy"]
    .menubar.edit entryconfigure $paste_idx -label [mc "Paste"]
    
    # 保存视图菜单索引
    set toggle_tree_idx [.menubar.view index "Toggle File Tree"]
    set toggle_term_idx [.menubar.view index "Toggle Terminal"]
    
    # 更新视图菜单
    .menubar.view entryconfigure $toggle_tree_idx -label [mc "Toggle File Tree"]
    .menubar.view entryconfigure $toggle_term_idx -label [mc "Toggle Terminal"]
    
    # 更新标签页右键菜单
    set close_idx [.tabmenu index "Close"]
    .tabmenu entryconfigure $close_idx -label [mc "Close"]
    
    # 更新标签页标题
    foreach tab [.paned.right.notebook tabs] {
        set title [.paned.right.notebook tab $tab -text]
        if {$title eq "欢迎" || $title eq "Welcome"} {
            .paned.right.notebook tab $tab -text [mc "Welcome"]
        } elseif {[string match "未命名-*" $title] || [string match "Untitled-*" $title]} {
            set num [string range $title [expr {[string first "-" $title] + 1}] end]
            .paned.right.notebook tab $tab -text "[mc Untitled]-$num"
        }
    }
    
    # 更新终端提示符
    set last_line [.paned.right.terminal.text get "end-1c linestart" "end-1c"]
    set prompt [mc "Terminal prompt"]
    if {[string match "$ *" $last_line] || [string match "$prompt*" $last_line]} {
        .paned.right.terminal.text delete "end-1c linestart" "end-1c"
        .paned.right.terminal.text insert "end-1c" $prompt
    }
    
    # 更新错误消息
    set file_not_found_msg [mc "File or directory does not exist: %s"]
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
.tabmenu add command -label [mc "Close"] -command {
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
.paned.right.terminal.text insert end [mc "Terminal prompt"]
.paned.right.terminal.text mark set insert end

# 绑定终端回车事件
bind .paned.right.terminal.text <Return> {
    set cmd [string trim [.paned.right.terminal.text get "insert linestart" "insert"]]
    if {[string match [mc "Terminal prompt"]* $cmd]} {
        set cmd [string range $cmd [string length [mc "Terminal prompt"]] end]
        if {$cmd ne ""} {
            if {[catch {
                set result [exec {*}[split $cmd] 2>@1]
                .paned.right.terminal.text insert end "\n$result"
            } err]} {
                .paned.right.terminal.text insert end "\n$err"
            }
        }
    }
    .paned.right.terminal.text insert end "\n[mc {Terminal prompt}]"
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

# 处理命令行参数
if {$argc > 0} {
    set target [lindex $argv 0]
    if {[file exists $target]} {
        if {[file isdirectory $target]} {
            # 如果是目录，设置为当前目录并刷新文件树
            set ::TreeView::current_dir [file normalize $target]
            TreeView::refresh .paned.left.tree
            Editor::show_welcome
        } else {
            # 如果是文件，打开它
            Editor::open_file [file normalize $target]
        }
    } else {
        tk_messageBox -icon error -message [format [mc "File or directory does not exist: %s"] $target]
        Editor::show_welcome
    }
} else {
    # 无参数时显示欢迎界面，不显示文件树内容
    Editor::show_welcome
} 