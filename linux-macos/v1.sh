#!/bin/zsh

# 获取总项目路径
if [[ "$BASH_VERSION" != "" ]]; then
  read -p "请输入总项目路径: " project_path
else
  echo -n "请输入总项目路径: "
  read project_path
fi

# 检查路径是否存在
if [ ! -d "$project_path" ]; then
  echo "错误：路径不存在或不可访问"
  exit 1
fi

# 扫描所有包含 .git 的目录并保存到数组
git_modules=()
while IFS= read -r -d $'\0' git_dir; do
  # 提取父目录（模块根路径）
  module_path=$(dirname "$git_dir")
  git_modules+=("$module_path")
done < <(find "$project_path" -maxdepth 2 -type d -name .git -print0 2>/dev/null)

# 检查是否有 Git 模块
if [ ${#git_modules[@]} -eq 0 ]; then
  echo "未找到任何 Git 模块"
  exit 1
fi  

# 打印找到的模块
length=${#git_modules[@]}
echo "找到以下 Git 模块($length):"
printf '  %s\n' "${git_modules[@]}"

# 收集所有分支信息
# 动态选择关联数组声明方式
if [[ "$BASH_VERSION" != "" ]]; then
  declare -A branch_counts
else
  typeset -A branch_counts
fi

for module in "${git_modules[@]}"; do
  echo "正在扫描模块: $(basename "$module")"
  
  branches=$(git -C "$module" branch --list -r | grep -v "HEAD" | sed 's/^[[:space:]]*//')
  
  # 记录分支出现次数
  while IFS= read -r branch; do
    # 动态选择关联数组递增方式
    if [[ "$BASH_VERSION" != "" ]]; then
      ((branch_counts["$branch"]++))
    else
      branch_counts["$branch"]=$((branch_counts["$branch"] + 1))
    fi
  done <<< "$branches"
done

for key value in ${(kv)branch_counts}; do
  echo "branch_counts[$key] = $value"
done

matched_keys=()
echo "length: $length"
# 正确遍历关联数组的键值对（间接引用）
for key value in ${(kv)branch_counts}; do
  # echo "key: $key, value: $value"  # 调试输出
  if [[ $value == $length ]]; then
    matched_keys+=("$key")
  fi
done

# echo "匹配的键：${matched_keys[@]}"

# 检查公共分支是否存在
if [ ${#matched_keys[@]} -eq 0 ]; then
  echo "错误：没有找到所有模块共有的分支"
  exit 1
fi

matched_branch_length=${#matched_keys[@]}
echo "所有模块共有的分支($matched_branch_length):"
printf '  %s\n' "${matched_keys[@]}"

# 显示分支选项
echo "可用公共分支:"
PS3="请选择要切换的分支 (输入数字): "
select branch in "${matched_keys[@]}"; do
  if [[ -n "$branch" ]]; then
    selected_branch="$branch"
    break
  else
    echo "无效选择，请重新输入"
  fi
done

selected_branch=$(echo "$selected_branch" | tr -d '"')
# echo "已选择分支: $selected_branch"
selected_branch=${selected_branch#origin/}
echo "已选择分支: $selected_branch"

# 切换分支
success_count=0
fail_count=0
failed_modules=()

for module in "${git_modules[@]}"; do
  echo -n "正在切换 $module ... "
  if output=$(git -C "$module" -c credential.helper= -c core.quotepath=false -c log.showSignature=false checkout "$selected_branch" -- 2>&1); then
    echo "✓"
    ((success_count++))
  else
    echo "✗"
    ((fail_count++))
    failed_modules+=("$module: $output")
  fi
done

# 输出结果
echo ""
echo "切换完成:"
echo "成功: $success_count 个模块"
echo "失败: $fail_count 个模块"

# 显示失败详情
if [ $fail_count -gt 0 ]; then
  echo ""
  echo "失败模块详情:"
  printf '%s\n' "${failed_modules[@]}"
fi
