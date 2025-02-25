#!/usr/bin/wish

package require Tk
package require msgcat

# 确保在namespace eval之前恢复命名空间初始化
# 删除之前的"namespace import ::msgcat::mc"行

# 加载模块
# source [file join [file dirname [info script]] "impl/treeview_impl.tcl"]
# source [file join [file dirname [info script]] "impl/editor_impl.tcl"]
# source [file join [file dirname [info script]] "impl/highlighter_impl.tcl"]
# source [file join [file dirname [info script]] "impl/lsp_impl.tcl"]

# 初始化国际化
# ::I18N::init

# 设置语言环境
namespace eval ::I18N {
    variable current_locale "zh_cn"  ;# 默认使用中文
    variable menu_indices
    variable updating 0  ;# 添加标志变量，防止循环更新
    variable in_switch_locale 0  ;# 添加标记变量，标识是否在switch_locale中调用
    variable translation_cache
    array set menu_indices {}
    array set translation_cache {}
    
    proc init {} {
        variable current_locale
        # 确保使用小写的区域码
        set current_locale [string tolower $current_locale]
        ::msgcat::mclocale $current_locale
        
        # 定义消息
        define_messages
        
        # 调试信息
        puts "Initialized with locale: $current_locale"
        puts "msgcat locale is: [::msgcat::mclocale]"
        
        # 输出当前翻译测试
        puts "翻译测试 - File = [::msgcat::mc "File"]"
        puts "翻译测试 - Edit = [::msgcat::mc "Edit"]"
        puts "翻译测试 - New File = [::msgcat::mc "New File"]"
        
        # 预先缓存常用翻译
        cache_translations
        
        # 延迟到 UI 完全创建后再更新
        after 100 update_ui
    }
    
    proc switch_locale {locale} {
        variable current_locale
        variable updating
        variable in_switch_locale
        
        # 如果已经在更新中，避免重复切换
        if {$updating && !$in_switch_locale} {
            puts "正在更新UI中，忽略区域码切换请求: $locale"
            return
        }
        
        # 确保使用小写的区域码
        set locale [string tolower $locale]
        
        # 调试信息
        puts "切换区域码：当前=$current_locale，目标=$locale"
        
        # 如果区域码没有变化，返回
        if {$current_locale eq $locale} {
            puts "区域码相同，无需切换"
            return
        }
        
        set current_locale $locale
        ::msgcat::mclocale $locale
        
        # 重新加载消息
        define_messages
        
        # 重新缓存翻译
        cache_translations
        
        # 调试信息
        puts "开始切换区域码: $current_locale"
        puts "msgcat 当前区域码: [::msgcat::mclocale]"
        
        # 测试翻译结果
        puts "翻译测试 - File = [::msgcat::mc "File"]"
        puts "翻译测试 - Edit = [::msgcat::mc "Edit"]"
        puts "翻译测试 - New File = [::msgcat::mc "New File"]"
        
        # 设置更新标志，防止重复调用
        set old_updating $updating
        set updating 1
        set in_switch_locale 1
        
        # 立即更新 UI
        force_update_ui
        
        # 重置更新标志
        set updating $old_updating
        set in_switch_locale 0
        
        # 强制刷新显示
        update
        update idletasks
        puts "区域码切换完成，界面已更新，当前区域码: $current_locale"
    }
    
    # 添加强制更新UI的函数，绕过递归检测
    proc force_update_ui {} {
        puts "强制更新UI，当前区域码: $::I18N::current_locale"
        _do_update_ui
    }
    
    # 缓存常用翻译，解决命名空间问题
    proc cache_translations {} {
        variable translation_cache
        variable current_locale
        
        # 清空缓存
        array unset translation_cache
        
        # 缓存主要UI元素的翻译
        set keys {
            "File" "Edit" "View" "Language" "English" "Chinese"
            "New File" "Open File" "Save" "Save As" "Exit"
            "Undo" "Redo" "Cut" "Copy" "Paste"
            "Toggle File Tree" "Toggle Terminal"
            "Welcome" "Untitled" "Close"
            "Pencium Editor"
        }
        
        foreach key $keys {
            set translation_cache($key) [::msgcat::mc $key]
            puts "缓存翻译: $key -> $translation_cache($key)"
        }
    }
    
    # 安全获取翻译，优先使用缓存
    proc get_translation {text} {
        variable translation_cache
        
        if {[info exists translation_cache($text)]} {
            return $translation_cache($text)
        } else {
            # 强制重新设置区域码，避免命名空间问题
            variable current_locale
            ::msgcat::mclocale $current_locale
            return [::msgcat::mc $text]
        }
    }
    
    proc define_messages {} {
        variable current_locale
        puts "开始定义消息，当前区域码: $current_locale"
        
        # 手动定义所有翻译消息
        
        # 中文翻译
        ::msgcat::mcmset zh_cn {
            "File" "文件"
            "Edit" "编辑"
            "View" "视图"
            "Language" "语言"
            "English" "英语"
            "Chinese" "简体中文"
            
            "New File" "新建文件"
            "Open File" "打开文件"
            "Save" "保存"
            "Save As" "另存为"
            "Exit" "退出"
            
            "Undo" "撤销"
            "Redo" "重做"
            "Cut" "剪切"
            "Copy" "复制"
            "Paste" "粘贴"
            
            "Toggle File Tree" "切换文件树"
            "Toggle Terminal" "切换终端"
            
            "Unsaved Changes" "未保存的更改"
            "There are unsaved changes" "有未保存的更改"
            "Save all changes" "保存所有更改"
            "Discard changes" "放弃更改"
            "Don't close" "不关闭"
            "Cannot open file" "无法打开文件"
            "Save failed" "保存失败"
            "File %s has unsaved changes" "文件 %s 有未保存的更改"
            "Save changes" "保存更改"
            "Don't save" "不保存"
            
            "Welcome" "欢迎"
            "Untitled" "未命名"
            "Close" "关闭"
            
            "Terminal prompt" "$ "
            
            "File or directory does not exist: %s" "文件或目录不存在: %s"
            
            "Pencium Editor" "Pencium 编辑器"
            
            "Yes" "是"
            "No" "否"
            "Cancel" "取消"
        }
        
        # 英文翻译（默认值，可以省略）
        ::msgcat::mcmset en_us {
            "File" "File"
            "Edit" "Edit"
            "View" "View"
            "Language" "Language"
            "English" "English"
            "Chinese" "Chinese"
            
            "New File" "New File"
            "Open File" "Open File"
            "Save" "Save"
            "Save As" "Save As"
            "Exit" "Exit"
            
            "Undo" "Undo"
            "Redo" "Redo"
            "Cut" "Cut"
            "Copy" "Copy"
            "Paste" "Paste"
            
            "Toggle File Tree" "Toggle File Tree"
            "Toggle Terminal" "Toggle Terminal"
            
            "Unsaved Changes" "Unsaved Changes"
            "There are unsaved changes" "There are unsaved changes"
            "Save all changes" "Save all changes"
            "Discard changes" "Discard changes"
            "Don't close" "Don't close"
            "Cannot open file" "Cannot open file"
            "Save failed" "Save failed"
            "File %s has unsaved changes" "File %s has unsaved changes"
            "Save changes" "Save changes"
            "Don't save" "Don't save"
            
            "Welcome" "Welcome"
            "Untitled" "Untitled"
            "Close" "Close"
            
            "Terminal prompt" "$ "
            
            "File or directory does not exist: %s" "File or directory does not exist: %s"
            
            "Pencium Editor" "Pencium Editor"
            
            "Yes" "Yes"
            "No" "No"
            "Cancel" "Cancel"
        }
        
        # 欢迎文本需要单独设置，因为含有复杂格式
        ::msgcat::mcset zh_cn "Welcome Text" {欢迎使用 Pencium Editor！

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

项目地址：https://github.com/ytfh44/pencium-editor}
        
        ::msgcat::mcset en_us "Welcome Text" {Welcome to Pencium Editor!

This is a modern text editor based on TCL/Tk.

Shortcuts:
• Ctrl+N  - New File
• Ctrl+O  - Open File
• Ctrl+S  - Save File
• Ctrl+W  - Close Current Tab

Features:
• Multi-tab Editing
• File Tree Browser
• Integrated Terminal
• Auto-save Prompt

Getting Started:
• Browse files using the file tree
• Use shortcuts to create/open files
• Toggle terminal for command-line operations

Project URL: https://github.com/ytfh44/pencium-editor}
        
        # 测试翻译加载是否成功
        puts "翻译加载完成，测试结果："
        puts "File -> [::msgcat::mc "File"]"
        puts "Edit -> [::msgcat::mc "Edit"]"
        puts "View -> [::msgcat::mc "View"]"
    }
}

# 加载模块
source [file join [file dirname [info script]] "impl/treeview_impl.tcl"]
source [file join [file dirname [info script]] "impl/editor_impl.tcl"]
source [file join [file dirname [info script]] "impl/highlighter_impl.tcl"]
source [file join [file dirname [info script]] "impl/lsp_impl.tcl"]

# 初始化国际化
::I18N::init

# 设置窗口标题和大小
wm title . [::I18N::get_translation "Pencium Editor"]
wm geometry . "1200x800"

# 创建主菜单
menu .menubar
. configure -menu .menubar

# 文件菜单
menu .menubar.file -tearoff 0
.menubar add cascade -label [::I18N::get_translation "File"] -menu .menubar.file

# 编辑菜单
menu .menubar.edit -tearoff 0
.menubar add cascade -label [::I18N::get_translation "Edit"] -menu .menubar.edit

# 视图菜单
menu .menubar.view -tearoff 0
.menubar add cascade -label [::I18N::get_translation "View"] -menu .menubar.view

# 语言菜单
menu .menubar.lang -tearoff 0
.menubar add cascade -label [::I18N::get_translation "Language"] -menu .menubar.lang

# 更新UI文本的过程
proc update_ui {} {
    # 防止递归调用
    if {$::I18N::updating && !$::I18N::in_switch_locale} {
        puts "检测到递归调用update_ui，已忽略"
        return
    }
    
    # 执行实际更新
    _do_update_ui
}

# 实际执行UI更新的内部函数，可以被force_update_ui直接调用
proc _do_update_ui {} {
    # 设置更新标志
    set old_updating $::I18N::updating
    set ::I18N::updating 1
    
    # 强制刷新翻译环境状态 - 这是关键修复
    ::msgcat::mclocale $::I18N::current_locale
    ::I18N::define_messages
    ::I18N::cache_translations
    
    # 调试当前状态
    puts "===== 开始更新UI ====="
    puts "当前区域码: $::I18N::current_locale"
    puts "msgcat区域码: [::msgcat::mclocale]"
    
    # 测试翻译
    puts "翻译测试："
    puts "File -> [::I18N::get_translation "File"] (应为: [expr {$::I18N::current_locale eq "zh_cn" ? "文件" : "File"}])"
    puts "Edit -> [::I18N::get_translation "Edit"] (应为: [expr {$::I18N::current_locale eq "zh_cn" ? "编辑" : "Edit"}])"
    puts "New File -> [::I18N::get_translation "New File"] (应为: [expr {$::I18N::current_locale eq "zh_cn" ? "新建文件" : "New File"}])"
    
    # 初始化菜单索引 - 使用数字索引而不是查找文本
    if {![info exists ::I18N::menu_indices(file)]} {
        # 主菜单项索引
        set ::I18N::menu_indices(file) 0
        set ::I18N::menu_indices(edit) 1
        set ::I18N::menu_indices(view) 2
        set ::I18N::menu_indices(lang) 3
        
        # 文件菜单索引
        set ::I18N::menu_indices(new_file) 0
        set ::I18N::menu_indices(open_file) 1
        set ::I18N::menu_indices(save) 2
        set ::I18N::menu_indices(save_as) 3
        set ::I18N::menu_indices(exit) 4
        
        # 编辑菜单索引
        set ::I18N::menu_indices(undo) 0
        set ::I18N::menu_indices(redo) 1
        set ::I18N::menu_indices(cut) 2
        set ::I18N::menu_indices(copy) 3
        set ::I18N::menu_indices(paste) 4
        
        # 视图菜单索引
        set ::I18N::menu_indices(toggle_tree) 0
        set ::I18N::menu_indices(toggle_term) 1
        
        puts "初始化菜单索引完成"
    }
    
    # 打印调试信息
    puts "开始更新 UI，当前区域码: $::I18N::current_locale"
    
    # 更新窗口标题
    set old_title [wm title .]
    set new_title [::I18N::get_translation "Pencium Editor"]
    wm title . $new_title
    puts "更新窗口标题: $old_title -> $new_title"
    
    # 更新菜单标签 - 使用正确的方式
    if {[catch {
        # 针对顶级菜单使用正确的更新方式
        puts "菜单项数量: [.menubar index end]"
        
        # 使用configure命令而不是entryconfigure
        .menubar configure -tearoff 0
        
        # 删除并重新创建整个菜单
        catch {.menubar delete 0 end}
        
        # 确保子菜单存在
        if {![winfo exists .menubar.file]} {
            menu .menubar.file -tearoff 0
        }
        if {![winfo exists .menubar.edit]} {
            menu .menubar.edit -tearoff 0
        }
        if {![winfo exists .menubar.view]} {
            menu .menubar.view -tearoff 0
        }
        if {![winfo exists .menubar.lang]} {
            menu .menubar.lang -tearoff 0
        }
        
        # 重新添加主菜单项
        .menubar add cascade -label [::I18N::get_translation "File"] -menu .menubar.file
        .menubar add cascade -label [::I18N::get_translation "Edit"] -menu .menubar.edit
        .menubar add cascade -label [::I18N::get_translation "View"] -menu .menubar.view
        .menubar add cascade -label [::I18N::get_translation "Language"] -menu .menubar.lang
        
        puts "更新主菜单项成功，新菜单项数量: [.menubar index end]"
    } err]} {
        puts "更新主菜单项失败: $err"
        puts "错误详情: [info errorinfo]"
    }
    
    # 更新文件菜单
    if {[catch {
        # 删除并重建文件菜单内容
        .menubar.file delete 0 end
        
        # 重新添加文件菜单项
        .menubar.file add command -label [::I18N::get_translation "New File"] -command {Editor::new_tab}
        .menubar.file add command -label [::I18N::get_translation "Open File"] -command {Editor::open_file}
        .menubar.file add command -label [::I18N::get_translation "Save"] -command {Editor::save_file}
        .menubar.file add command -label [::I18N::get_translation "Save As"] -command {Editor::save_as}
        .menubar.file add separator
        .menubar.file add command -label [::I18N::get_translation "Exit"] -command exit
        
        puts "更新文件菜单成功"
    } err]} {
        puts "更新文件菜单失败: $err"
    }
    
    # 更新编辑菜单
    if {[catch {
        # 删除并重建编辑菜单内容
        .menubar.edit delete 0 end
        
        # 重新添加编辑菜单项
        .menubar.edit add command -label [::I18N::get_translation "Undo"] -command {
            event generate .paned.right.notebook.f[Editor::get_current_tab].text <<Undo>>
        }
        .menubar.edit add command -label [::I18N::get_translation "Redo"] -command {
            event generate .paned.right.notebook.f[Editor::get_current_tab].text <<Redo>>
        }
        .menubar.edit add separator
        .menubar.edit add command -label [::I18N::get_translation "Cut"] -command {
            event generate .paned.right.notebook.f[Editor::get_current_tab].text <<Cut>>
        }
        .menubar.edit add command -label [::I18N::get_translation "Copy"] -command {
            event generate .paned.right.notebook.f[Editor::get_current_tab].text <<Copy>>
        }
        .menubar.edit add command -label [::I18N::get_translation "Paste"] -command {
            event generate .paned.right.notebook.f[Editor::get_current_tab].text <<Paste>>
        }
        
        puts "更新编辑菜单成功"
    } err]} {
        puts "更新编辑菜单失败: $err"
    }
    
    # 更新视图菜单
    if {[catch {
        # 删除并重建视图菜单内容
        .menubar.view delete 0 end
        
        # 重新添加视图菜单项
        .menubar.view add command -label [::I18N::get_translation "Toggle File Tree"] -command {
            if {[winfo ismapped .paned.left]} {
                .paned forget .paned.left
            } else {
                .paned add .paned.left -before .paned.right
            }
        }
        .menubar.view add command -label [::I18N::get_translation "Toggle Terminal"] -command {
            if {[winfo ismapped .paned.right.terminal]} {
                grid remove .paned.right.terminal
                grid rowconfigure .paned.right 1 -minsize 0
            } else {
                grid .paned.right.terminal -row 1 -column 0 -sticky nsew
                grid rowconfigure .paned.right 1 -minsize 200
            }
        }
        
        puts "更新视图菜单成功"
    } err]} {
        puts "更新视图菜单失败: $err"
    }
    
    # 更新标签页右键菜单
    if {[winfo exists .tabmenu]} {
        if {[catch {
            set close_idx [.tabmenu index "Close"]
            if {$close_idx != -1} {
                .tabmenu entryconfigure $close_idx -label [::I18N::get_translation "Close"]
                puts "更新标签页右键菜单成功"
            }
        } err]} {
            puts "更新标签页右键菜单失败: $err"
        }
    }
    
    # 更新标签页标题
    if {[winfo exists .paned.right.notebook]} {
        if {[catch {
            foreach tab [.paned.right.notebook tabs] {
                set title [.paned.right.notebook tab $tab -text]
                if {[string match "*Welcome*" $title] || [string match "*欢迎*" $title]} {
                    .paned.right.notebook tab $tab -text [::I18N::get_translation "Welcome"]
                } elseif {[string match "*Untitled*" $title] || [string match "*未命名*" $title]} {
                    if {[string first "-" $title] != -1} {
                        set num [string range $title [expr {[string first "-" $title] + 1}] end]
                        .paned.right.notebook tab $tab -text "[::I18N::get_translation "Untitled"]-$num"
                    } else {
                        .paned.right.notebook tab $tab -text [::I18N::get_translation "Untitled"]
                    }
                }
            }
            puts "更新标签页标题成功"
        } err]} {
            puts "更新标签页标题失败: $err"
        }
    }
    
    # 更新语言菜单
    if {[catch {
        # 删除并重建语言菜单内容
        .menubar.lang delete 0 end
        
        # 使用简单的command而不是radiobutton，避免自动触发机制
        .menubar.lang add command -label [::I18N::get_translation "English"] -command {
            if {!$::I18N::updating} {
                puts "英文菜单被点击"
                ::I18N::switch_locale "en_us"
            }
        }
        
        .menubar.lang add command -label [::I18N::get_translation "Chinese"] -command {
            if {!$::I18N::updating} {
                puts "中文菜单被点击"
                ::I18N::switch_locale "zh_cn"
            }
        }
        
        # 标记当前选中项
        if {$::I18N::current_locale eq "en_us"} {
            .menubar.lang entryconfigure 0 -background "#ccccff"
        } else {
            .menubar.lang entryconfigure 1 -background "#ccccff"
        }
        
        puts "更新语言菜单成功"
        # 打印菜单项的标签，验证翻译
        puts "  英文选项标签: [.menubar.lang entrycget 0 -label]"
        puts "  中文选项标签: [.menubar.lang entrycget 1 -label]"
    } err]} {
        puts "更新语言菜单失败: $err"
    }
    
    # 更新终端提示符
    if {[winfo exists .paned.right.terminal.text]} {
        if {[catch {
            set last_line [.paned.right.terminal.text get "end-1c linestart" "end-1c"]
            set prompt [::I18N::get_translation "Terminal prompt"]
            if {[string match "$ *" $last_line] || [string match "$prompt*" $last_line]} {
                .paned.right.terminal.text delete "end-1c linestart" "end-1c"
                .paned.right.terminal.text insert "end-1c" $prompt
            }
            puts "更新终端提示符成功"
        } err]} {
            puts "更新终端提示符失败: $err"
        }
    }
    
    # 强制刷新显示
    update
    update idletasks
    after 10 {update idletasks}
    
    # 重置更新标志
    set ::I18N::updating $old_updating
    
    puts "===== UI 更新完成，当前区域码: $::I18N::current_locale ====="
}

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
        set message "[::I18N::get_translation {There are unsaved changes}]\n\n[::I18N::get_translation Yes]: [::I18N::get_translation {Save all changes}]\n[::I18N::get_translation No]: [::I18N::get_translation {Discard changes}]\n[::I18N::get_translation Cancel]: [::I18N::get_translation {Don't close}]"
        set answer [tk_messageBox -icon question -title [::I18N::get_translation "Unsaved Changes"] \
            -message $message \
            -type yesnocancel -default yes]
        
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
.tabmenu add command -label [::I18N::get_translation "Close"] -command {
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
.paned.right.terminal.text insert end [::I18N::get_translation "Terminal prompt"]
.paned.right.terminal.text mark set insert end

# 绑定终端回车事件
bind .paned.right.terminal.text <Return> {
    set cmd [string trim [.paned.right.terminal.text get "insert linestart" "insert"]]
    if {[string match [::I18N::get_translation "Terminal prompt"]* $cmd]} {
        set cmd [string range $cmd [string length [::I18N::get_translation "Terminal prompt"]] end]
        if {$cmd ne ""} {
            if {[catch {
                set result [exec {*}[split $cmd] 2>@1]
                .paned.right.terminal.text insert end "\n$result"
            } err]} {
                .paned.right.terminal.text insert end "\n$err"
            }
        }
    }
    .paned.right.terminal.text insert end "\n[::I18N::get_translation {Terminal prompt}]"
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
        tk_messageBox -icon error -message [format [::I18N::get_translation "File or directory does not exist: %s"] $target]
        Editor::show_welcome
    }
} else {
    # 无参数时显示欢迎界面，不显示文件树内容
    Editor::show_welcome
}

# 确保默认选中中文
puts "正在设置默认语言为中文..."

# 在所有UI元素创建完成后更新UI
puts "正在初始执行UI更新..."
update

# 直接调用switch_locale
::I18N::switch_locale "zh_cn"

puts "初始UI更新完成" 