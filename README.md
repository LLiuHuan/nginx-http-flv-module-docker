<!--
 * @Description: 
 * @Author: LLiuHuan
 * @Date: 2022-04-11 16:30:02
 * @LastEditTime: 2024-09-05 09:40:20
 * @LastEditors: LLiuHuan
-->
### Introduce
> The official image of nginx-http-flv-module is N years ago, so the project needs to get the latest version.  

1. This project uses the latest version of `nginx-http-flv-module`. The current version is `1.2.11`  
2. Both rtmp and http nginx parsing is stream, which can be modified if necessary.

### Use
1. Run container  
  ```bash
  docker run --name flv -p 1935:1935 -p 8080:80 -itd lliuhuan/nginx-http-flv-module
  ```  
2. Using OBS and other software to push streams  
  ```
  Server: rtmp://127.0.0.1:1935/stream
  Secret Key: t55
  ```  
  ![image](./static/1.OBS.gif)  
3. Play using IINA or other HTTP video playback tools  
  ```
  http://localhost:8080/stream?app=stream&stream=t55
  ```
![image](./static/2.IINA.gif)  

#### RTMP method

##### Push streaming
```bash
# Serve
rtmp://127.0.0.1:1935/[app]
#streamname
t55
```
##### Play
```
http://127.0.0.1:8080/stream?app=stream&stream=[streamname]
```

#### HLS method
##### Push streaming
```bash
# Serve
rtmp://127.0.0.1:1935/hls
#streamname
t55
```
##### Play
```
http://localhost:8080/hls/[streamname].m3u8
```

#### DASH method
##### Push streaming
```bash
# Serve
rtmp://127.0.0.1:1935/dash
#streamname
t55
```
##### Play
```
http://localhost:8080/dash/[streamname].mpd
```

#### Monitoring
```
http://127.0.0.1:8080/stat
```

### Default Nginx configuration

```nginx
user  root;
worker_processes  1; #运行在 Windows 上时，设置为 1，因为 Windows 不支持 Unix domain socket
#worker_processes  auto; #1.3.8 和 1.2.5 以及之后的版本

#worker_cpu_affinity  0001 0010 0100 1000; #只能用于 FreeBSD 和 Linux
#worker_cpu_affinity  auto; #1.9.10 以及之后的版本

error_log logs/error.log error;

#如果此模块被编译为动态模块并且要使用与 RTMP 相关的功
#能时，必须指定下面的配置项并且它必须位于 events 配置
#项之前，否则 NGINX 启动时不会加载此模块或者加载失败

#load_module modules/ngx_http_flv_live_module.so;

# error_log  /var/log/nginx/error.log notice;
# pid        /var/run/nginx.pid;

events {
    worker_connections  4096;  ## Default: 1024
}

rtmp_auto_push on;
rtmp_auto_push_reconnect 1s;
rtmp_socket_dir /tmp;

rtmp {
    out_queue           4096;
    out_cork            8;
    max_streams         128;
    timeout             15s;
    drop_idle_publisher 15s;

    log_interval 5s; #log 模块在 access.log 中记录日志的间隔时间，对调试非常有用
    log_size     1m; #log 模块用来记录日志的缓冲区大小

    server {
        listen 1935;  # 接受推流的端口号
        chunk_size 8192; # 单一推流数据包的最大容量？
        access_log off;	# 加上这行，取消操作日志
        application stream { # mlive 模块，可以自行更换名字
            live on; # 打开直播
            meta off; # 为了兼容网页前端的 flv.js，设置为 off 可以避免报错
            gop_cache on; # 支持GOP缓存，以减少首屏时间  改为off 延迟较大
            allow play all; # 允许来自任何 ip 的人拉流
        }

        application hls { # hls 模块，可以自行更换名字
            live on;
            hls on;
            hls_path /tmp/hls;
        }

        application dash { # dash 模块，可以自行更换名字
            live on;
            dash on;
            dash_path /tmp/dash;
        }
    }
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    #tcp_nopush     on;
    #keepalive_timeout  0;
    keepalive_timeout  65;
    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';
    #access_log  logs/access.log  main;
    access_log off;	# 加上这行，取消操作日志
    #gzip  on;
    server {
        listen       80;  # http 服务的端口
        # server_name  localhost;
        location / {
            root   html;
            index  index.html index.htm;
            add_header 'Access-Control-Allow-Origin' '*'; # 允许跨域
            add_header 'Access-Control-Allow-Credentials' 'true';
        }

        location /stream {
            flv_live on; # 打开 http-flv 服务
            chunked_transfer_encoding on; #支持 'Transfer-Encoding: chunked' 方式回复

            add_header 'Access-Control-Allow-Origin' '*'; # 允许跨域
            add_header 'Access-Control-Allow-Credentials' 'true';
        }

        location /hls { # hls 服务 根据需求修改
            types {
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
            }

            root /tmp;
            add_header 'Cache-Control' 'no-cache';
        }

        location /dash { # dash 服务 根据需求修改
            root /tmp;
            add_header 'Cache-Control' 'no-cache';
        }

        location /stat { # 推流播放和录制统计数据的配置 根据需求确定是否开放
            rtmp_stat all;
            rtmp_stat_stylesheet stat.xsl;
        }

        location /stat.xsl {
            root rtmp; #指定 stat.xsl 的位置
        }

        #如果需要 JSON 风格的 stat, 不用指定 stat.xsl
        #但是需要指定一个新的配置项 rtmp_stat_format
        #location /stat {
        #    rtmp_stat all;
        #    rtmp_stat_format json;
        #}

        location /control {
            rtmp_control all; #rtmp 控制模块的配置
        }
    }
}

```

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