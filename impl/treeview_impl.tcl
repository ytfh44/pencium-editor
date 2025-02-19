source [file join [file dirname [info script]] "../interfaces/treeview.tcl"]

namespace eval TreeView {
    # 实现文件树视图接口
    variable current_dir [pwd]
    
    proc init {tree_widget scroll_widget} {
        variable current_dir
        $tree_widget configure -yscrollcommand "$scroll_widget set"
        $scroll_widget configure -command "$tree_widget yview"
        refresh $tree_widget $current_dir
    }
    
    proc populate {tree_widget parent dir} {
        foreach item [lsort [glob -nocomplain -directory $dir -tails *]] {
            set fullpath [file join $dir $item]
            set id [$tree_widget insert $parent end -text $item]
            if {[file isdirectory $fullpath]} {
                $tree_widget insert $id end -text "dummy"
                $tree_widget item $id -text "📁 $item"
            } else {
                $tree_widget item $id -text "📄 $item"
            }
        }
    }
    
    proc get_full_path {tree_widget id} {
        set path {}
        while {$id ne ""} {
            set text [$tree_widget item $id -text]
            # 移除文件图标前缀
            if {[string match "📁 *" $text]} {
                set text [string range $text 3 end]
            } elseif {[string match "📄 *" $text]} {
                set text [string range $text 3 end]
            }
            set path [linsert $path 0 $text]
            set id [$tree_widget parent $id]
        }
        return $path
    }
    
    proc expand {tree_widget id} {
        variable current_dir
        $tree_widget delete [$tree_widget children $id]
        set dir [file join $current_dir {*}[get_full_path $tree_widget $id]]
        populate $tree_widget $id $dir
    }
    
    proc refresh {tree_widget {path ""}} {
        variable current_dir
        if {$path eq ""} {
            set path $current_dir
        }
        $tree_widget delete [$tree_widget children {}]
        populate $tree_widget "" $path
    }
    
    proc on_select {tree_widget callback} {
        bind $tree_widget <<TreeviewSelect>> [list apply {{cb tree} {
            set id [$tree selection]
            if {$id ne ""} {
                set fullpath [file join $::TreeView::current_dir {*}[TreeView::get_full_path $tree $id]]
                if {[file isfile $fullpath]} {
                    {*}$cb $fullpath
                }
            }
        }} $callback %W]
    }
} 