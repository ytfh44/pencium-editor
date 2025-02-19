source [file join [file dirname [info script]] "../interfaces/editor.tcl"]

namespace eval Editor {
    # 实现编辑器接口
    variable current_tab 0
    variable tabs_info {}
    
    proc show_welcome {} {
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
        
        # 设置欢迎文本
        set welcome_text "欢迎使用 Pencium Editor！

这是一个基于 TCL/Tk 开发的现代化文本编辑器。

快捷键：
• Ctrl+N  - 新建文件
• Ctrl+O  - 打开文件
• Ctrl+S  - 保存文件
• Ctrl+W  - 关闭当前标签页

功能：
• 多标签页编辑
• 文件树浏览
• 集成终端
• 自动保存提示

开始使用：
• 使用文件树浏览文件
• 使用快捷键新建或打开文件
• 切换终端显示开始命令行操作

项目地址：https://github.com/ytfh44/pencium-editor"
        
        $f.text insert 1.0 $welcome_text
        $f.text configure -state disabled
        
        .paned.right.notebook add $f -text "欢迎"
        
        lappend tabs_info [list $current_tab "" 0]
        
        after idle [list .paned.right.notebook select $f]
        after idle [list focus $f.text]
        
        incr current_tab
    }
    
    proc new_tab {} {
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
        
        lappend tabs_info [list $current_tab "" 0]
        
        # 使用 after idle 确保标签页已完全创建后再选择
        after idle [list .paned.right.notebook select $f]
        after idle [list focus $f.text]
        
        set tab_id $current_tab
        incr current_tab
        return $tab_id
    }
    
    proc close_tab {tab_id} {
        variable tabs_info
        
        set current ".paned.right.notebook.f$tab_id"
        if {![winfo exists $current]} return
        
        set idx [lsearch -index 0 $tabs_info $tab_id]
        if {$idx != -1} {
            set fileinfo [lindex $tabs_info $idx]
            set filename [lindex $fileinfo 1]
            
            if {[is_modified $tab_id]} {
                set title "未保存的更改"
                set message "文件 [expr {$filename eq "" ? "未命名-$tab_id" : [file tail $filename]}] 有未保存的更改。\n\n【是】保存更改\n【否】不保存更改\n【取消】不关闭"
                set answer [tk_messageBox -icon question -message $message -title $title -type yesnocancel]
                
                switch -- $answer {
                    yes {
                        if {$filename eq ""} {
                            set filename [tk_getSaveFile]
                            if {$filename eq ""} return
                        }
                        if {![save_file $filename]} return
                    }
                    cancel {
                        return
                    }
                }
            }
            
            set tabs_info [lreplace $tabs_info $idx $idx]
        }
        
        .paned.right.notebook forget $current
        
        if {[llength [.paned.right.notebook tabs]] == 0} {
            after idle new_tab
        }
    }
    
    proc select_tab {tab_id} {
        .paned.right.notebook select .paned.right.notebook.f$tab_id
        focus .paned.right.notebook.f$tab_id.text
    }
    
    proc get_current_tab {} {
        set current [.paned.right.notebook select]
        if {$current eq ""} return ""
        return [string range $current end end]
    }
    
    proc open_file {{filename ""}} {
        variable tabs_info
        
        if {$filename eq ""} {
            set filename [tk_getOpenFile]
            if {$filename eq ""} return ""
        }
        
        # 检查文件是否已经打开
        foreach info $tabs_info {
            set tab_id [lindex $info 0]
            set tab_file [lindex $info 1]
            if {$tab_file eq $filename} {
                select_tab $tab_id
                return $tab_id
            }
        }
        
        if {[catch {
            set fh [open $filename r]
            set content [read $fh]
            close $fh
        } err]} {
            tk_messageBox -icon error -message "无法打开文件: $err"
            return ""
        }
        
        set tab_id [new_tab]
        set_text $tab_id $content
        
        set idx [lsearch -index 0 $tabs_info $tab_id]
        set tabs_info [lreplace $tabs_info $idx $idx [list $tab_id $filename 0]]
        .paned.right.notebook tab .paned.right.notebook.f$tab_id -text [file tail $filename]
        
        return $tab_id
    }
    
    proc save_file {{filename ""}} {
        variable tabs_info
        
        set tab_id [get_current_tab]
        if {$tab_id eq ""} return 0
        
        if {$filename eq ""} {
            set idx [lsearch -index 0 $tabs_info $tab_id]
            if {$idx == -1} return 0
            set filename [lindex [lindex $tabs_info $idx] 1]
            if {$filename eq ""} {
                return [save_as]
            }
        }
        
        if {[catch {
            set fh [open $filename w]
            puts -nonewline $fh [get_text $tab_id]
            close $fh
        } err]} {
            tk_messageBox -icon error -message "保存失败: $err"
            return 0
        }
        
        set_modified $tab_id 0
        return 1
    }
    
    proc save_as {} {
        variable tabs_info
        
        set tab_id [get_current_tab]
        if {$tab_id eq ""} return 0
        
        set filename [tk_getSaveFile]
        if {$filename eq ""} return 0
        
        if {![save_file $filename]} return 0
        
        set idx [lsearch -index 0 $tabs_info $tab_id]
        set tabs_info [lreplace $tabs_info $idx $idx [list $tab_id $filename 0]]
        .paned.right.notebook tab .paned.right.notebook.f$tab_id -text [file tail $filename]
        
        return 1
    }
    
    proc get_text {tab_id} {
        return [.paned.right.notebook.f$tab_id.text get 1.0 end]
    }
    
    proc set_text {tab_id text} {
        .paned.right.notebook.f$tab_id.text delete 1.0 end
        .paned.right.notebook.f$tab_id.text insert 1.0 $text
        set_modified $tab_id 0
    }
    
    proc is_modified {tab_id} {
        return [.paned.right.notebook.f$tab_id.text edit modified]
    }
    
    proc set_modified {tab_id value} {
        .paned.right.notebook.f$tab_id.text edit modified $value
    }
    
    proc on_text_change {tab_id callback} {
        bind .paned.right.notebook.f$tab_id.text <<Modified>> [list apply {{cb id} {
            if {[.paned.right.notebook.f$id.text edit modified]} {
                {*}$cb $id
                .paned.right.notebook.f$id.text edit modified 0
            }
        }} $callback $tab_id]
    }
    
    proc on_cursor_move {tab_id callback} {
        bind .paned.right.notebook.f$tab_id.text <<CursorChange>> [list apply {{cb id} {
            {*}$cb $id [.paned.right.notebook.f$id.text index insert]
        }} $callback $tab_id]
    }
} 