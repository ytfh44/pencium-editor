source [file join [file dirname [info script]] "../interfaces/lsp.tcl"]

namespace eval LSP {
    # 空实现
    proc init {language server_cmd} {
        # TODO: 实现 LSP 服务器初始化
    }
    
    proc start {language} {
        # TODO: 实现服务器启动
    }
    
    proc stop {language} {
        # TODO: 实现服务器停止
    }
    
    proc open_document {uri language} {
        # TODO: 实现文档打开通知
    }
    
    proc close_document {uri} {
        # TODO: 实现文档关闭通知
    }
    
    proc change_document {uri changes} {
        # TODO: 实现文档更改通知
    }
    
    proc save_document {uri} {
        # TODO: 实现文档保存通知
    }
    
    proc get_completion {uri position} {
        # TODO: 实现代码补全
        return {}
    }
    
    proc get_definition {uri position} {
        # TODO: 实现转到定义
        return {}
    }
    
    proc get_references {uri position} {
        # TODO: 实现查找引用
        return {}
    }
    
    proc get_hover {uri position} {
        # TODO: 实现悬停提示
        return {}
    }
    
    proc get_diagnostics {uri} {
        # TODO: 实现诊断信息获取
        return {}
    }
    
    proc on_diagnostics {callback} {
        # TODO: 实现诊断信息回调
    }
    
    proc on_completion {callback} {
        # TODO: 实现补全回调
    }
} 