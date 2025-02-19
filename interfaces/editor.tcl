namespace eval Editor {
    # 接口定义
    variable current_tab
    variable tabs_info
    
    # 标签页管理
    proc new_tab {} {}
    proc close_tab {tab_id} {}
    proc select_tab {tab_id} {}
    proc get_current_tab {} {}
    
    # 文件操作
    proc open_file {{filename ""}} {}
    proc save_file {{filename ""}} {}
    proc save_as {} {}
    
    # 编辑操作
    proc get_text {tab_id} {}
    proc set_text {tab_id text} {}
    proc is_modified {tab_id} {}
    proc set_modified {tab_id value} {}
    
    # 事件处理
    proc on_text_change {tab_id callback} {}
    proc on_cursor_move {tab_id callback} {}
} 