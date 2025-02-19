namespace eval TreeView {
    # 接口定义
    variable current_dir
    
    # 初始化文件树
    proc init {tree_widget scroll_widget} {}
    
    # 填充目录内容
    proc populate {tree_widget parent dir} {}
    
    # 获取完整路径
    proc get_full_path {tree_widget id} {}
    
    # 展开目录
    proc expand {tree_widget id} {}
    
    # 刷新目录
    proc refresh {tree_widget {path ""}} {}
    
    # 选择文件
    proc on_select {tree_widget callback} {}
} 