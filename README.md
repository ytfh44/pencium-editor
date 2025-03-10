# Pencium Editor

一个基于 TCL/Tk 开发的现代化文本编辑器，具有模块化设计和丰富的功能。

## 主要功能

### 1. 多标签页编辑
- 支持多文件同时编辑
- 标签页可以自由切换、关闭
- 未保存内容提示
- 智能标签页管理

### 2. 文件树浏览
- 实时显示当前目录结构
- 支持文件夹展开/折叠
- 单击文件直接打开
- 文件类型图标显示（📁 文件夹，📄 文件）

### 3. 集成终端
- 内置命令行终端
- 支持基本的命令执行
- 可切换显示/隐藏
- 错误输出捕获和显示

### 4. 文件操作
- 新建文件（Ctrl+N）
- 打开文件（Ctrl+O）
- 保存文件（Ctrl+S）
- 另存为（Ctrl+Shift+S）
- 关闭文件（Ctrl+W）

### 5. 编辑功能
- 撤销/重做
- 剪切/复制/粘贴
- 自动缩进
- 水平/垂直滚动

### 6. 界面定制
- 可调节文件树宽度
- 可切换文件树显示
- 可切换终端显示
- 现代化 UI 设计

### 7. 扩展性设计
- 模块化架构
- 接口与实现分离
- 预留语法高亮接口
- 预留 LSP 支持接口

## 环境要求

- TCL/Tk 8.6 或更高版本
- 支持 Linux/macOS/Windows 系统

## 安装方法

1. 确保系统已安装 TCL/Tk 8.6+
2. 克隆仓库：
```bash
git clone https://github.com/ytfh44/pencium-editor.git
```
3. 添加执行权限：
```bash
chmod +x main.tcl
```

## 运行方法

直接运行主程序：
```bash
./main.tcl
```

或使用 wish 解释器：
```bash
wish main.tcl
```

## 快捷键

- `Ctrl+N`: 新建文件
- `Ctrl+O`: 打开文件
- `Ctrl+S`: 保存文件
- `Ctrl+Shift+S`: 另存为
- `Ctrl+W`: 关闭当前标签页

## 项目结构

```
.
├── interfaces/          # 接口定义
│   ├── editor.tcl      # 编辑器接口
│   ├── treeview.tcl    # 文件树接口
│   ├── highlighter.tcl # 语法高亮接口
│   └── lsp.tcl         # LSP 支持接口
├── impl/               # 接口实现
│   ├── editor_impl.tcl
│   ├── treeview_impl.tcl
│   ├── highlighter_impl.tcl
│   └── lsp_impl.tcl
├── main.tcl           # 主程序
└── README.md          # 项目文档
```

## 开发计划

- [ ] 实现语法高亮功能
- [ ] 添加 LSP 支持
- [ ] 支持主题切换
- [ ] 添加插件系统
- [ ] 支持更多编码格式

## 贡献指南

1. Fork 本仓库
2. 创建特性分支
3. 提交更改
4. 发起 Pull Request

## 许可证

本项目采用 BSD 0-Clause License（BSD-0-Clause）。这是一个极其宽松的许可证，允许任何人自由使用、修改和分发本软件，无需保留版权声明。

完整许可证文本请参见 [LICENSE](LICENSE) 文件。 