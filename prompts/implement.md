# DD-{dd_id}: {slug} - 代码实现

## 任务
按 DesignDoc 实现代码。文档已在仓库中，只负责代码不动 docs/。

**文档路径：** `{{design_dir}}/DD-{dd_id}-{slug}.md`
**项目路径：** {repo}

## Phase 1 — 读文档，输出执行 plan
- 仔细阅读 DesignDoc
- 理解目标、方案、测试要求
- 输出分步执行计划

## Phase 2 — 按 plan 逐步实施
1. `.gitignore` → 项目初始化 → 源码 → 依赖安装 → 构建 → 测试
2. 偏离文档须回写 DesignDoc §8（决策变更记录）
3. 遇到问题记录在案，不要重复失败尝试

## Phase 3 — Git 提交
```bash
cd {repo}
git add -A
git commit -m "feat: {slug} (DD-{dd_id})"
```

## 完成后
- 列出文件清单
- 列出测试结果
- 专注技术，不废话

## 注意
- 不要修改 `{{design_dir}}/` 中的 DesignDoc（除非记录变更）
- 不要推送到远程仓库
