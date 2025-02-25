#!/usr/bin/wish

package require msgcat

# 定义 mcset 命令，这样语言文件就可以被正确解析
if {![llength [info commands ::msgcat::mcset]]} {
    namespace eval ::msgcat {
        proc mcset {locale src {dest ""}} {
            variable Messages
            if {[string length $dest] == 0} {
                set dest $src
            }
            set Messages($locale,$src) $dest
            return $dest
        }
    }
}

# 打印初始语言环境
puts "Initial locale: [::msgcat::mclocale]"

# 设置为中文
::msgcat::mclocale zh_cn
puts "Setting locale to zh_cn: [::msgcat::mclocale]"

# 加载语言文件
puts "Loading messages from: [file join [file dirname [info script]] "locale"]"
if {[catch {::msgcat::mcload [file join [file dirname [info script]] "locale"]} err]} {
    puts "Error loading messages: $err"
}

# 检查文件是否存在
set zh_file [file join [file dirname [info script]] "locale" "zh_cn.msg"]
puts "Message file exists: [file exists $zh_file]"
if {[file exists $zh_file]} {
    puts "Message file size: [file size $zh_file]"
} else {
    puts "Trying old filename (zh_CN.msg)"
    set zh_file [file join [file dirname [info script]] "locale" "zh_CN.msg"]
    puts "Old file exists: [file exists $zh_file]"
    if {[file exists $zh_file]} {
        puts "Old file size: [file size $zh_file]"
    }
}

# 直接加载语言文件
if {[file exists $zh_file]} {
    puts "Sourcing language file directly..."
    if {[catch {source $zh_file} err]} {
        puts "Error sourcing file: $err"
    } else {
        puts "Language file sourced successfully"
    }
}

# 导入 mc 命令
namespace import ::msgcat::mc

# 测试一些翻译
puts "File translated: [mc "File"]"
puts "Edit translated: [mc "Edit"]"
puts "Pencium Editor translated: [mc "Pencium Editor"]"

# 测试一下强制使用命名空间
puts "File translated (ns): [::msgcat::mc "File"]"
puts "Edit translated (ns): [::msgcat::mc "Edit"]"

# 检查消息数据库
puts "Dumping msgcat message database:"
if {[info exists ::msgcat::Messages]} {
    foreach key [lsort [array names ::msgcat::Messages]] {
        puts "  $key: $::msgcat::Messages($key)"
    }
} else {
    puts "  No messages found in database"
}

exit 