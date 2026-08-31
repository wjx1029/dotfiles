#!/bin/bash
# scripts/symlink.sh

DOTFILES_DIR="$HOME/dotfiles"
TARGET_DIR="$HOME"

# 定义映射：源文件路径 -> 目标路径
declare -A MAP=(
    ["$DOTFILES_DIR/bash/.bashrc"]="$TARGET_DIR/.bashrc"
    ["$DOTFILES_DIR/zsh/.zshrc"]="$TARGET_DIR/.zshrc"
    ["$DOTFILES_DIR/git/.gitconfig"]="$TARGET_DIR/.gitconfig"
    ["$DOTFILES_DIR/vim/.vimrc"]="$TARGET_DIR/.vimrc"
    ["$DOTFILES_DIR/tmux/.tmux.conf"]="$TARGET/.tmux.conf"
)

for src in "${!MAP[@]}"; do
    dest="${MAP[$src]}"
    # 如果目标已存在且不是符号链接，备份
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        mv "$dest" "$dest.backup.$(date +%s)"
    fi
    # 创建链接（强制覆盖旧的符号链接）
    ln -sf "$src" "$dest"
done







# ==========================================================================================================================================

#                                                           复杂版本

# ==========================================================================================================================================





# #!/bin/bash
# # ============================================================
# # dotfiles 符号链接管理脚本
# # 用法: 
# #   ./install.sh           # 创建所有链接
# #   ./install.sh --dry-run # 预览操作
# #   ./install.sh --uninstall # 移除所有链接
# # ============================================================

# set -euo pipefail

# # ---------- 配置 ----------
# DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
# TARGET_DIR="$HOME"
# LOCAL_BIN_DIR="$HOME/.local/bin"
# XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# # ---------- 全局变量 ----------
# DRY_RUN=false
# UNINSTALL=false
# LINKED_COUNT=0
# REMOVED_COUNT=0

# # ---------- 颜色输出 ----------
# RED='\033[0;31m'
# GREEN='\033[0;32m'
# YELLOW='\033[0;33m'
# BLUE='\033[0;34m'
# NC='\033[0m' # No Color

# info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
# warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
# error() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }
# dry()   { echo -e "${BLUE}[DRY-RUN]${NC} $1"; }

# # ---------- 参数解析 ----------
# while [[ $# -gt 0 ]]; do
#     case "$1" in
#         --dry-run)
#             DRY_RUN=true
#             shift
#             ;;
#         --uninstall)
#             UNINSTALL=true
#             shift
#             ;;
#         --help|-h)
#             echo "用法: $0 [选项]"
#             echo "选项:"
#             echo "  --dry-run    预览将要执行的操作（不实际修改）"
#             echo "  --uninstall  移除所有已创建的符号链接"
#             echo "  --help, -h   显示此帮助信息"
#             exit 0
#             ;;
#         *)
#             error "未知参数: $1 (使用 --help 查看帮助)"
#             ;;
#     esac
# done

# # ---------- 检查 ----------
# [[ -d "$DOTFILES_DIR" ]] || error "dotfiles 目录不存在: $DOTFILES_DIR"

# # ---------- 跳过列表 ----------
# skip_dirs=("scripts" "bin" "utils" ".git" ".github" "backup" "temp" "test")

# # ============================================================
# # 创建符号链接的辅助函数
# # ============================================================
# create_symlink() {
#     local source_file="$1"
#     local target_file="$2"
#     local target_dir
#     local backup
#     local current_target
    
#     # 检查源文件是否存在
#     if [[ ! -e "$source_file" ]]; then
#         warn "源文件不存在: $source_file"
#         return 1
#     fi
    
#     # 处理已存在的目标
#     if [[ -e "$target_file" ]] || [[ -L "$target_file" ]]; then
#         # 如果是符号链接且指向正确的源，跳过
#         if [[ -L "$target_file" ]]; then
#             current_target=$(readlink "$target_file")
#             if [[ "$current_target" == "$source_file" ]]; then
#                 info "  跳过 (已正确链接): $target_file"
#                 return 0
#             fi
#         fi
        
#         # 备份非链接的已存在文件
#         if [[ ! -L "$target_file" ]]; then
#             backup="${target_file}.backup.$(date +%Y%m%d_%H%M%S)"
#             if [[ "$DRY_RUN" == true ]]; then
#                 dry "将备份: $target_file -> $backup"
#             else
#                 mv "$target_file" "$backup"
#                 warn "已备份: $target_file -> $backup"
#             fi
#         fi
#     fi
    
#     # 创建目标目录（如果不存在）
#     target_dir=$(dirname "$target_file")
#     if [[ ! -d "$target_dir" ]]; then
#         if [[ "$DRY_RUN" == true ]]; then
#             dry "将创建目录: $target_dir"
#         else
#             mkdir -p "$target_dir"
#             info "创建目录: $target_dir"
#         fi
#     fi
    
#     # 创建符号链接
#     if [[ "$DRY_RUN" == true ]]; then
#         dry "将链接: $source_file -> $target_file"
#     else
#         ln -sfn "$source_file" "$target_file"
#         info "链接: $(basename "$target_file") -> $source_file"
#         ((LINKED_COUNT++))
#     fi
# }

# # ============================================================
# # 检查是否应该跳过目录
# # ============================================================
# should_skip_dir() {
#     local dir_name="$1"
#     local skip
    
#     for skip in "${skip_dirs[@]}"; do
#         if [[ "$dir_name" == "$skip" ]]; then
#             return 0  # 应该跳过
#         fi
#     done
#     return 1  # 不应该跳过
# }

# # ============================================================
# # 处理单个目录下的配置文件
# # ============================================================
# process_directory() {
#     local dir="$1"
#     local dirname
#     local found_files
#     local file
#     local config_file
#     local config_name
    
#     dirname=$(basename "$dir")
#     found_files=false
    
#     # 遍历目录下的所有点文件
#     for file in "$dir"/.*; do
#         [[ -e "$file" ]] || continue
#         [[ "$(basename "$file")" == "." || "$(basename "$file")" == ".." ]] && continue
        
#         found_files=true
#         create_symlink "$file" "$TARGET_DIR/$(basename "$file")"
#     done
    
#     # 处理 XDG .config 目录
#     if [[ -d "$dir/.config" ]]; then
#         info "  处理 XDG .config: $dir/.config"
#         for config_file in "$dir"/.config/*; do
#             [[ -e "$config_file" ]] || continue
#             config_name=$(basename "$config_file")
#             create_symlink "$config_file" "$XDG_CONFIG_HOME/$config_name"
#         done
#     fi
    
#     # 如果没有找到任何文件，给出提示
#     if [[ "$found_files" == false ]] && [[ ! -d "$dir/.config" ]]; then
#         warn "  目录为空或无可链接文件: $dirname"
#     fi
# }

# # ============================================================
# # 处理可执行脚本
# # ============================================================
# process_bin_scripts() {
#     local script
#     local script_name
#     local link_name
    
#     if [[ ! -d "$DOTFILES_DIR/bin" ]]; then
#         return 0
#     fi
    
#     info "处理可执行脚本: $DOTFILES_DIR/bin"
    
#     if [[ "$DRY_RUN" == false ]]; then
#         mkdir -p "$LOCAL_BIN_DIR"
#     else
#         dry "将创建目录: $LOCAL_BIN_DIR"
#     fi
    
#     for script in "$DOTFILES_DIR"/bin/*; do
#         [[ -e "$script" ]] || continue
#         [[ -f "$script" ]] || continue
        
#         # 检查是否为可执行文件，如果不是则添加执行权限
#         if [[ ! -x "$script" ]]; then
#             if [[ "$DRY_RUN" == true ]]; then
#                 dry "将添加执行权限: $script"
#             else
#                 chmod +x "$script"
#                 info "添加执行权限: $(basename "$script")"
#             fi
#         fi
        
#         # 链接到 ~/.local/bin
#         script_name=$(basename "$script")
#         # 去掉可能的扩展名（如 .sh）
#         link_name="${script_name%.*}"
#         create_symlink "$script" "$LOCAL_BIN_DIR/$link_name"
#     done
    
#     # 提醒用户检查 PATH
#     if [[ "$DRY_RUN" == false ]]; then
#         warn "请确保 ~/.local/bin 在你的 PATH 中 (如果尚未添加)"
#     fi
# }

# # ============================================================
# # 卸载功能
# # ============================================================
# uninstall_links() {
#     local links_to_remove=()
#     local link
#     local target
    
#     info "开始卸载 dotfiles 链接..."
    
#     # 1. 查找所有指向 DOTFILES_DIR 的符号链接
#     while IFS= read -r -d '' link; do
#         target=$(readlink "$link" 2>/dev/null || echo "")
#         if [[ "$target" == "$DOTFILES_DIR"* ]]; then
#             links_to_remove+=("$link")
#         fi
#     done < <(find "$TARGET_DIR" -maxdepth 1 -type l -print0 2>/dev/null)
    
#     # 2. 检查 ~/.config 下的链接
#     if [[ -d "$XDG_CONFIG_HOME" ]]; then
#         while IFS= read -r -d '' link; do
#             target=$(readlink "$link" 2>/dev/null || echo "")
#             if [[ "$target" == "$DOTFILES_DIR"* ]]; then
#                 links_to_remove+=("$link")
#             fi
#         done < <(find "$XDG_CONFIG_HOME" -maxdepth 1 -type l -print0 2>/dev/null)
#     fi
    
#     # 3. 检查 ~/.local/bin 下的链接
#     if [[ -d "$LOCAL_BIN_DIR" ]]; then
#         while IFS= read -r -d '' link; do
#             target=$(readlink "$link" 2>/dev/null || echo "")
#             if [[ "$target" == "$DOTFILES_DIR/bin/"* ]]; then
#                 links_to_remove+=("$link")
#             fi
#         done < <(find "$LOCAL_BIN_DIR" -maxdepth 1 -type l -print0 2>/dev/null)
#     fi
    
#     # 执行删除
#     if [[ ${#links_to_remove[@]} -eq 0 ]]; then
#         info "没有找到需要移除的链接"
#         return 0
#     fi
    
#     for link in "${links_to_remove[@]}"; do
#         if [[ "$DRY_RUN" == true ]]; then
#             dry "将删除: $link -> $(readlink "$link")"
#         else
#             rm -f "$link"
#             info "已删除: $link"
#             ((REMOVED_COUNT++))
#         fi
#     done
    
#     if [[ "$DRY_RUN" == true ]]; then
#         info "DRY-RUN 完成，共需要移除 ${#links_to_remove[@]} 个链接"
#     else
#         info "卸载完成！共移除 $REMOVED_COUNT 个链接"
#     fi
# }

# # ============================================================
# # 显示安装完成信息
# # ============================================================
# show_completion_message() {
#     echo ""
#     info "========================================"
    
#     if [[ "$DRY_RUN" == false ]]; then
#         info "安装完成！共链接 $LINKED_COUNT 个文件"
        
#         # 提示重新加载配置
#         if [[ -f "$TARGET_DIR/.zshrc" ]] || [[ -f "$TARGET_DIR/.bashrc" ]]; then
#             echo "提示: 运行以下命令重新加载配置:"
#             echo "  source ~/.zshrc   # 如果使用 Zsh"
#             echo "  source ~/.bashrc  # 如果使用 Bash"
#         fi
        
#         # 提示 Git 配置
#         if [[ -f "$TARGET_DIR/.gitconfig" ]]; then
#             echo ""
#             echo "Git 配置已链接，如果要使用私有配置:"
#             echo "  创建 ~/.gitconfig.local 并添加个人设置"
#         fi
#     else
#         info "DRY-RUN 完成，未实际修改任何文件"
#         info "移除 --dry-run 参数以执行实际安装"
#     fi
    
#     info "========================================"
# }

# # ============================================================
# # 安装主逻辑
# # ============================================================
# install_dotfiles() {
#     local dir
#     local dirname
    
#     info "开始创建 dotfiles 符号链接..."
#     info "源目录: $DOTFILES_DIR"
#     info "目标目录: $TARGET_DIR"
#     [[ "$DRY_RUN" == true ]] && warn "== 运行在 DRY-RUN 模式，不会实际修改文件 =="
    
#     # 主循环：处理配置文件
#     while IFS= read -r -d '' dir; do
#         dirname=$(basename "$dir")
        
#         # 检查是否在跳过列表
#         if should_skip_dir "$dirname"; then
#             continue
#         fi
        
#         info "处理目录: $dirname"
#         process_directory "$dir"
        
#     done < <(find "$DOTFILES_DIR" -mindepth 1 -maxdepth 1 -type d -print0)
    
#     # 处理可执行脚本
#     process_bin_scripts
    
#     # 显示完成信息
#     show_completion_message
# }

# # ============================================================
# # 主程序入口
# # ============================================================

# # 执行卸载或安装
# if [[ "$UNINSTALL" == true ]]; then
#     uninstall_links
# else
#     install_dotfiles
# fi

# exit 0