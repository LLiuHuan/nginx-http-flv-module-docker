<!--
 * @Description: 
 * @Author: LLiuHuan
 * @Date: 2022-04-11 16:30:02
 * @LastEditTime: 2024-04-06 15:45:59
 * @LastEditors: LLiuHuan
-->
### 介绍
> nginx-http-flv-module官方镜像是四年前的，因项目需要弄个最新版  

1. 本项目使用最新版 `nginx-http-flv-module` 目前版本为 `1.2.10`  
2. rtmp和http nginx 解析都为 stream，有需要可自行修改

### 使用
1. 运行容器  
  `docker run --name flv -p 31935:1935 -p 39000:9000 -itd lliuhuan/nginx-http-flv-module`  
2. 使用OBS或其他软件推送  
  ```
  Server: rtmp://127.0.0.1:31935/stream
  Secret Key: t55
  ```  
  ![image](./static/1.OBS.gif)  
3. 使用IINA或其他软件播放  
  `http://127.0.0.1:39000/stream?app=stream&stream=t55`
![image](./static/2.IINA.gif)  

### 通过工作流自动构建镜像
当 push 标签为v* 时自动执行工作流,构建 Docker 镜像并上传到 Docker Hub

#### 1. 在本仓库中添加 secrets:

1. 在 settings -> secrets 中添加你的 Docker 账号和密码

```
DOCKER_USERNAME 是你的 Docker 账号
ACCESS_TOKEN 是你的 Docker 密码
```

2. 推送关于 v* 的标签

### 参考
- https://github.com/alfg/docker-nginx-rtmp/blob/master/Dockerfile
- https://github.com/nginxinc/docker-nginx/blob/6f0396c1e06837672698bc97865ffcea9dc841d5/mainline/alpine-perl/Dockerfile
- https://github.com/winshining/nginx-http-flv-module/blob/master/README.CN.md
- https://www.jianshu.com/p/123df9333db0
- https://blog.csdn.net/syy014799/article/details/121885306
- https://blog.csdn.net/a_917/article/details/121473954
- https://hub.docker.com/r/mycujoo/nginx-http-flv-module
- https://blog.csdn.net/a_917/article/details/106709928
- https://blog.csdn.net/Prinz_Corn/article/details/120746676
- https://blog.csdn.net/xjcallen/article/details/107174374
- 
