# bench.sh 特点：
#
---
1、显示当前测试的各种系统信息；
2、取自世界多处的知名数据中心的测试点，下载测试比较全面；
3、支持 IPv6 下载测速；
4、IO 测试三次，并显示平均值。


配合 unixbench.sh 脚本测试，即可全面测试 VPS 的性能。

使用方法：
命令1：

wget -qO- bench.sh | bash
或者

curl -Lso- bench.sh | bash

# 各种常用代理一键搭建
#
---

- 首先您要有一个外网的服务器，一般来说线路用香港、日本、新加坡的应该比较好

- 支持ubunt18或debian10以下系统，(用root用户登录，然后首先对你的系统使用以下命令)
```yaml
apt-get update && apt-get install -y wget curl git socat sudo ca-certificates && update-ca-certificates
```

- 支持CentOS7或者以下系统，(用root用户登录，然后首先对你的系统使用以下命令)
```yaml
yum install -y wget curl git socat ca-certificates && update-ca-trust force-enable
```
#
---
#
---
- 一键安装xary脚本，需要域名
```yaml
bash -c "$(curl -fsSL https://raw.githubusercontent.com/waynesg/scripts/main/xray_install.sh)"
```
#
---
#
---
- [一键安装带x-ui面版的xray](https://github.com/vaxilu/x-ui)
```yaml
bash -c "$(curl -fsSL https://raw.githubusercontent.com/waynesg/scripts/main/x-ui.sh)"
```
#
---
#
---
- [TG代理一键搭建](https://github.com/seriyps/mtproto_proxy)
```yaml
bash -c "$(curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/erlang_tg.sh)"
```
#
---
#
---
- [TG代理一键搭建](https://github.com/cutelua/mtg-dist)
- 输入命令后显示：`> Input service PORT, or press Enter to use a random port` 这个是输入您要设置端口，不设置的话回车默认端口
- 然后显示：`> Input a domain for FakeTLS, or press Enter to use "hostupdate.vmware.com"` 回车默认hostupdate.vmware.com，可以输入 FakeTLS 改协议
- 搭建好以后要查看TG代理链接，输入：mtg access /etc/mtg.toml
```yaml
bash <(wget -qO- https://git.io/mtg.sh)
```
#
---
#
---
- [八合一的一键搭建(V2ray/Xray/Trojan)](https://github.com/mack-a/v2ray-agent)，需要域名，后期管理命令：vasma
```yaml
wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
```
#
---
#
---
- [v2ray一键搭建](https://github.com/gms1979/v2ray)，后期管理看下面的命令
```yaml
bash <(curl -s -L https://git.io/v2ray.sh)
```
```yaml

快速管理

v2ray info 查看 V2Ray 配置信息

v2ray config 修改 V2Ray 配置

v2ray link 生成 V2Ray 配置文件链接

v2ray infolink 生成 V2Ray 配置信息链接

v2ray qr 生成 V2Ray 配置二维码链接

v2ray ss 修改 Shadowsocks 配置

v2ray ssinfo 查看 Shadowsocks 配置信息

v2ray ssqr 生成 Shadowsocks 配置二维码链接

v2ray status 查看 V2Ray 运行状态

v2ray start 启动 V2Ray

v2ray stop 停止 V2Ray

v2ray restart 重启 V2Ray

v2ray log 查看 V2Ray 运行日志

v2ray update 更新 V2Ray

v2ray update.sh 更新 V2Ray 管理脚本

v2ray uninstall 卸载 V2Ray

配置文件路径

V2Ray 配置文件路径：/etc/v2ray/config.json

Caddy 配置文件路径：/etc/caddy/Caddyfile

脚本配置文件路径: /etc/v2ray/233blog_v2ray_backup.conf
```
#
---
#
---
- [一键安装BBR](https://github.com/ylx2016/Linux-NetSpeed)，使用BBR+CAKE加速方案，后期管理再次输入命令
```yaml
wget -N --no-check-certificate "https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
```
#
---
#
---
- [一键安装BBR2](https://github.com/yeyingorg/bbr2.sh),不支持CentOS
```yaml
wget --no-check-certificate -q -O bbr2.sh "https://github.com/yeyingorg/bbr2.sh/raw/master/bbr2.sh" && chmod +x bbr2.sh && bash bbr2.sh auto
```
#
---
#
---
- [测试解锁流媒体情况](https://github.com/lmc999/RegionRestrictionCheck)
```yaml
bash <(curl -L -s https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/check.sh)
```
#
---
#
---
- [一键DD更换服务器系统教程](https://www.moeelf.com/archives/293.html)
#
---
#
---
```yaml
wget -O server-tools.sh https://raw.githubusercontent.com/waynesg/scripts/main/server-tools.sh && chmod +x server-tools.sh && clear && ./server-tools.sh
```
服务器检查：
- Lemonbench 综合测试
- 三网Speedtest测速
- 内存压力测试
- 回程路由追踪
- Speedtest测速
- 获取本机IP
- 流媒体解锁测试
- 检测/诊断Youtube地域
- 服务器功能
- Linux换源脚本
- ipv4/6优先级调整
- 虚拟内存SWAP一键安装
- 一键安装BBR
- 系统网络配置优化
- 宝塔中文官方一键安装
- 宝塔英文官方一键安装（无需验证）
- 宝塔破解纯净版
- Cloudflare WARP 一键配置脚本
- 科学上网工具
- iptables一键中转
- gost一键中转
- MTP&TLS 一键脚本
- xray一键安装8合一脚本
- v2-ui一键安装
- wulabing一键xray脚本
#
---
#
---
