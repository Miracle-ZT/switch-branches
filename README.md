# switch-branches

一个用于快速切换多个代码仓库 Git 分支的 shell 脚本，适用于 Spring Boot 微服务等多仓场景。  
A shell script for quickly switching Git branches of multiple repositories  
— perfect for managing multi-repo micro-services in a Spring Boot environment.

## 📦 使用场景

这个工具非常适合如下微服务项目结构：
```
projectName/
├── service-gateway
│   ├── ...
│   └── pom.xml
├── service-user
│   ├── ...
│   └── pom.xml
├── ...
├── ...
└── service-order
    ├── ...
    └── pom.xml
```

每个服务目录是一个独立的 Git 仓库。使用本脚本，可以将它们全部切换到指定分支（例如 `feature/develop`），节省大量手动切换时间。

## 🔧 使用方法

1. 下载脚本至任意目录（你找得到就行）。
2. 执行脚本。
   ```
   zsh /local_path/switch_branches.sh
   ```
3. 输入项目主目录`/projectName`。
4. 选择需要切换到的分支。
5. 查看执行结果。


## 🧠 脚本逻辑

## 💡 示例输出
```

```
