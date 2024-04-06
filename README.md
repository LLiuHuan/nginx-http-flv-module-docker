<!--
 * @Description: 
 * @Author: LLiuHuan
 * @Date: 2022-04-11 16:30:02
 * @LastEditTime: 2024-04-06 15:45:57
 * @LastEditors: LLiuHuan
-->
### Introduce
> The official image of nginx-http-flv-module is four years ago, so the project needs to get the latest version.  

1. This project uses the latest version of `nginx-http-flv-module`. The current version is `1.2.11`  
2. Both rtmp and http nginx parsing is stream, which can be modified if necessary.

### Use
1. Run container  
  `docker run --name flv -p 31935:1935 -p 39000:9000 -itd lliuhuan/nginx-http-flv-module`  
2. Using OBS and other software to push streams  
  ```
  Server: rtmp://127.0.0.1:31935/stream
  Secret Key: t55
  ```  
  ![image](./static/1.OBS.gif)  
3. Play using IINA or other HTTP video playback tools  
  `http://127.0.0.1:39000/stream?app=stream&stream=t55`
![image](./static/2.IINA.gif)  

### Build images by workflow

Automatically execute workflow, build Docker image, and upload Docker Hub when push tag is v*

#### 1. Add secrets in this repo:

  1. Add your Docker account and password in the settings -> secrets
  ```
  DOCKER_USERNAME is your Docker account
  ACCESS_TOKEN is your Docker password
  ```
  

#### 2. Push tag about v*

### References
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
