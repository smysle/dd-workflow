# dd-workflow

DD 流程自动化技能 —— Claude 写文档，Codex 写代码。

## 使用方式

### 1. 初始化设计阶段

```bash
cd /home/darling/.openclaw/workspace/skills/dd-workflow
./scripts/main.sh init <repo 路径> <DD 编号> <slug> "<需求描述>"
```

示例：
```bash
./scripts/main.sh init /home/darling/.openclaw/workspace/myapp DD-0001 auth-feature "实现用户认证功能"
```

### 2. 审核 DesignDoc

等待 Claude 完成 DesignDoc 后，阅读并审核：
- 路径：`/home/darling/.openclaw/workspace/design_docs/<repo 名>/DD-NNNN-*.md`

### 3. 执行实现阶段

审核通过后：
```bash
./scripts/main.sh apply <repo 路径> <DD 编号> <slug>
```

### 4. 验收

检查 Codex 的输出：
- 文件清单
- 测试结果
- Git 提交记录

## 目录结构

```
dd-workflow/
├── SKILL.md              # 本文件
├── scripts/
│   └── main.sh           # 主脚本
└── prompts/
    ├── design.md         # Claude 提示词模板
    └── implement.md      # Codex 提示词模板
```

## DesignDoc 存放位置

DesignDoc 存放在本地独立目录，不推送到远程仓库：
```
/home/darling/.openclaw/workspace/design_docs/<repo 名>/DD-NNNN-*.md
```

## 模型配置

- **Design 阶段**：`momo/claude-opus-4-6`（文档/思考型）
- **Implement 阶段**：`momo-openai/gpt-5.3-codex`（编码型）
