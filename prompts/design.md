# DD-{dd_id}: {slug}

## 任务
撰写 DesignDoc 并提交。

**需求：** {description}
**编号：** DD-{dd_id}
**输出路径：** {{design_dir}}/DD-{dd_id}-{slug}.md

## 步骤

1. **Research**
   - 阅读 `{repo}/docs/design/` 现有文档（如果有）
   - 理解项目结构和需求

2. **撰写 DesignDoc**
   - 使用模板：`/home/darling/.openclaw/workspace/docs/design/TEMPLATE.md`
   - 输出到：`{{design_dir}}/DD-{dd_id}-{slug}.md`
   - Status 设为 `Draft`

3. **Git 提交**
   ```bash
   cd {repo}
   git init  # 如果还没初始化
   git config user.name "Noah"
   git config user.email "noasamaaa@outlook.com"
   git add -A
   git commit -m "docs: DD-{dd_id} {slug}"
   ```

4. **输出摘要**
   - 3-5 句话总结设计要点
   - 专注技术，不废话

## 注意
- DesignDoc 存放在 `{{design_dir}}`（本地独立目录），不推送到远程仓库
- 完成后等待用户审核，不要自动进入实现阶段
