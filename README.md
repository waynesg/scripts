#
<details>
<summary>🔻安装curl、wget命令🔻</summary>
<br>

```yaml
yum install -y curl wget || apt update && apt install -y curl wget
```

<br />
</details>

#
<details>
<summary>🔻Linux 一键网络重装系统🔻</summary>
<br>

```sh
wget -N --no-check-certificate "https://raw.githubusercontent.com/waynesg/scripts/main/Install.sh"
chmod +x Install.sh
./Install.sh
```
<br />
</details>

#
<details>
<summary>🔻Portainer安装脚本🔻</summary>
<br>

```sh
docker run -d --name=portainer -p 9900:9000 --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /share/docker_conf/portainer/data:/data 6053537/portainer-ce:latest
```
<br />
</details>

#
<details>
<summary>🔻Linux 一键网络重装系统傻瓜版🔻</summary>
<br>
  
```sh
wget -N --no-check-certificate "https://raw.githubusercontent.com/chiakge/installNET/master/Install.sh"
chmod +x Install.sh && ./Install.sh
```
<br />
</details>

#
<details>
<summary>🔻Hysteria2一键脚本🔻</summary>
<br>
  
```sh
wget -N --no-check-certificate "https://raw.githubusercontent.com/waynesg/scripts/main/hysteria.sh"
chmod +x hysteria.sh && ./hysteria.sh
```

<br />
</details>

#
<details>
<summary>🔻谷歌云、甲骨云开启root用户SSH连接🔻</summary>
<br>

- 第一步：进入服务器后,切换到root用户,下面命令一般都能切入root用户,如果不行请自行百度
```sh
sudo -i   或者   sudo su
```

- 第二步：进入root用户后，把下面命令里的中文改成您要设置的服务器密码,然后执行命令
```sh
echo root:你想要设置的密码 |chpasswd root
```

- 第三步：一键开启root用户SSH连接
```sh
bash -c  "$(curl -fsSL https://raw.githubusercontent.com/waynesg/scripts/main/ssh.sh)"
```

<br />
</details>


#
<details>
<summary>🔻TG代理安装🔻</summary>
<br>

TG代理安装,下面两个一键安装二选一即可
```yaml
bash -c "$(curl -fsSL https://raw.githubusercontent.com/waynesg/scripts/main/erlang_tg.sh)"
```

```yaml
bash <(wget -qO- https://git.io/mtg.sh)
```
<br />
</details>


#
<details>
<summary>🔻服务器检查🔻</summary>

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

  
```yaml
wget -O server-tools.sh https://raw.githubusercontent.com/waynesg/scripts/main/server-tools.sh && chmod +x server-tools.sh && clear && ./server-tools.sh
```
  
<br />
</details>

#
<details>
<summary>🔻服务器性能测试🔻</summary>
<br>

- 显示当前测试的各种系统信息；
- 取自世界多处的知名数据中心的测试点，下载测试比较全面；
- 支持 IPv6 下载测速；
- IO 测试三次，并显示平均值。

<br>配合 unixbench.sh 脚本测试，即可全面测试 VPS 的性能。

使用方法：

```yaml
wget -qO- https://raw.githubusercontent.com/waynesg/scripts/main/bench.sh | bash
```

或者

```yaml
curl -Lso- https://raw.githubusercontent.com/waynesg/scripts/main/bench.sh | bash
```
<br />
</details>

#
<details>
<summary>🔻各种常用代理一键搭建🔻</summary>
<br>

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

- [一键安装带x-ui面版的xray](https://github.com/vaxilu/x-ui)
```yaml
bash -c "$(curl -fsSL https://raw.githubusercontent.com/waynesg/scripts/main/x-ui.sh)"
```

- [八合一的一键搭建(V2ray/Xray/Trojan)](https://github.com/mack-a/v2ray-agent)，需要域名，后期管理命令：vasma
```yaml
wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
```
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
- [一键安装BBR](https://github.com/ylx2016/Linux-NetSpeed)，使用BBR+CAKE加速方案，后期管理再次输入命令
```yaml
wget -N --no-check-certificate "https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
```
- [一键安装BBR2](https://github.com/yeyingorg/bbr2.sh),不支持CentOS
```yaml
wget --no-check-certificate -q -O bbr2.sh "https://github.com/yeyingorg/bbr2.sh/raw/master/bbr2.sh" && chmod +x bbr2.sh && bash bbr2.sh auto
```
<br />
</details>

#
<details>
<summary>🔻测试解锁流媒体情况🔻</summary>
<br>
  
```yaml
bash <(curl -L -s https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/check.sh)
```
<br />
</details>



## MetaCubeX geosite

`.github/workflows/BuildGeosite.yml` 每日同步 V2Fly 的完整域名分类并生成
[`geodata/geosite.dat`](https://raw.githubusercontent.com/waynesg/scripts/main/geodata/geosite.dat)。
原有分类会完整保留，另外提供两个自定义分类：

- `custom-direct`：合并 `rules/custom_direct.yaml` 和 `rules/unbreak-classical.yaml`
- `custom-proxy`：合并 `rules/custom_proxy.yaml` 和 `rules/proxy-classical.yaml`

工作流会解析生成后的二进制文件，要求至少包含 1000 个分类，并检查 `cn`、
`geolocation-!cn`、`private`、`category-ads-all`、`apple`、`google` 及两个自定义
分类。完整分类清单、统计和上游版本分别保存在：

- `geodata/geosite-tags.txt`
- `geodata/geosite-summary.json`
- `geodata/source-revisions.txt`

因此构建器若只生成自定义分类，工作流会直接失败，不会覆盖完整的 `geosite.dat`。

Honk 示例：

```dae
assets {
    geodata {
        geosite: 'https://raw.githubusercontent.com/waynesg/scripts/main/geodata/geosite.dat'
    }
}

domain(geosite: custom-direct) -> direct
domain(geosite: custom-proxy) -> Proxy
```

`IP-CIDR`/`IP-CIDR6` 不属于 geosite 域名数据库，工作流会分别输出
`geodata/custom-direct-ip.txt` 和 `geodata/custom-proxy-ip.txt`，需要在 Honk 中用
`dip(...)` 或其它 IP 规则单独处理。
