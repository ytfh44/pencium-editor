namespace eval Highlighter {
    # 接口定义
    
    # 初始化高亮器
    proc init {text_widget} {}
    
    # 设置语言
    proc set_language {text_widget language} {}
    
    # 高亮指定范围
    proc highlight {text_widget start end} {}
    
    # 更新高亮
    proc update {text_widget} {}
    
    # 清除高亮
    proc clear {text_widget} {}
    
    # 获取支持的语言列表
    proc get_supported_languages {} {}
} 