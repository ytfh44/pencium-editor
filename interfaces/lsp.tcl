namespace eval LSP {
    # 接口定义
    
    # 服务器管理
    proc init {language server_cmd} {}
    proc start {language} {}
    proc stop {language} {}
    
    # 文档操作
    proc open_document {uri language} {}
    proc close_document {uri} {}
    proc change_document {uri changes} {}
    proc save_document {uri} {}
    
    # LSP 功能
    proc get_completion {uri position} {}
    proc get_definition {uri position} {}
    proc get_references {uri position} {}
    proc get_hover {uri position} {}
    proc get_diagnostics {uri} {}
    
    # 事件处理
    proc on_diagnostics {callback} {}
    proc on_completion {callback} {}
} 