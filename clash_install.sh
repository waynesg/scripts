#!/usr/bin/env bash

#====================================================
#	System Request:Debian 9+/Ubuntu 18.04+/Centos 7+
#	Author:	wulabing
#	Dscription: Xray onekey Management
#	email: admin@wulabing.com
#====================================================

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
stty erase ^?

cd "$(
  cd "$(dirname "$0")" || exit
  pwd
)" || exit

# 字体颜色配置
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Font="\033[0m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
OK="${Green}[OK]${Font}"
Hi="${Green}[Hi]${Font}"
ERROR="${Red}[ERROR]${Font}"

# 变量
github_branch="main"
xray_conf_dir="/root/sub-web"
website_dir="/www/xray_web/"
cert_dir="/root/sub-web"
domain_tmp_dir="/root/sub-web"
cert_group="nobody"
random_num=$((RANDOM % 12 + 4))
HOME="/root"

function print_ok() {
  echo -e " ${OK} ${Blue} $1 ${Font}"
}
function print_Hi() {
  echo -e " ${Hi} ${Blue} $1 ${Font}"
}
function print_error() {
  echo -e "${ERROR} ${RedBG} $1 ${Font}"
}
function ECHOY()
{
  echo -e "${Yellow} $1 ${Font}"
}
function ECHOG()
{
  echo -e "${Green} $1 ${Font}"
}
function is_root() {
  if [[ 0 == "$UID" ]]; then
    print_ok "当前用户是 root 用户，请开始您的骚操作"
  else
    print_error "当前用户不是 root 用户，请切换到 root 用户后重新执行脚本"
    exit 1
  fi
}
judge() {
  if [[ 0 -eq $? ]]; then
    print_ok "$1 完成"
    sleep 1
  else
    print_error "$1 失败"
    exit 1
  fi
}

function system_check() {
  source '/etc/os-release'

  if [[ "${ID}" == "centos" && ${VERSION_ID} -ge 7 ]]; then
    print_ok "当前系统为 Centos ${VERSION_ID} ${VERSION}"
    curl -sL https://rpm.nodesource.com/setup_12.x | bash -
    export INS="yum install -y"
    ${INS} socat wget ca-certificates && update-ca-trust force-enable
    wget -N -P /etc/yum.repos.d/ https://raw.githubusercontent.com/281677160/agent/main/xray/nginx.repo
  elif [[ "${ID}" == "ol" ]]; then
    print_ok "当前系统为 Oracle Linux ${VERSION_ID} ${VERSION}"
    export INS="yum install -y"
    ${INS} wget
    wget -N -P /etc/yum.repos.d/ https://raw.githubusercontent.com/281677160/agent/main/xray/nginx.repo
  elif [[ "${ID}" == "debian" && ${VERSION_ID} -ge 9 ]]; then
    print_ok "当前系统为 Debian ${VERSION_ID} ${VERSION}"
    curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
    export INS="apt install -y"
    ${INS} socat wget ca-certificates && update-ca-certificates
    # 清除可能的遗留问题
    rm -f /etc/apt/sources.list.d/nginx.list
    $INS lsb-release gnupg2

    echo "deb http://nginx.org/packages/debian $(lsb_release -cs) nginx" >/etc/apt/sources.list.d/nginx.list
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -

    apt update
  elif [[ "${ID}" == "ubuntu" && $(echo "${VERSION_ID}" | cut -d '.' -f1) -ge 18 ]]; then
    print_ok "当前系统为 Ubuntu ${VERSION_ID} ${UBUNTU_CODENAME}"
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
    export INS="apt install -y"
    ${INS} socat wget ca-certificates && update-ca-certificates
    # 清除可能的遗留问题
    rm -f /etc/apt/sources.list.d/nginx.list
    $INS lsb-release gnupg2

    echo "deb http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" >/etc/apt/sources.list.d/nginx.list
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
    apt update
  else
    print_error "当前系统为 ${ID} ${VERSION_ID} 不在支持的系统列表内"
    exit 1
  fi

  if [[ $(grep "nogroup" /etc/group) ]]; then
    cert_group="nogroup"
  fi

  $INS dbus

  # 关闭各类防火墙
  systemctl stop firewalld
  systemctl disable firewalld
  systemctl stop nftables
  systemctl disable nftables
  systemctl stop ufw
  systemctl disable ufw
}

function kaishi_install() {
  echo
  echo
  export YUMING1="请输入您的前端域名(浏览网页用的)"
  ECHOY "${YUMING1}[比如：q.xray.com]"
  while :; do
  read -p " ${YUMING1}：" domain
  if [[ -n "${domain}" ]] && [[ "$(echo ${domain} |grep -c '\.')" -ge '1' ]]; then
    export domainy="Y"
  fi
  case $domainy in
  Y)
    export domain="${domain}"
  break
  ;;
  *)
    export YUMING1="敬告：请输入正确的前端域名"
  ;;
  esac
  done
  echo
  export YUMING2="请输入您的后端域名(服务IP用的)"
  ECHOY "${YUMING2}[比如：h.xray.com]"
  while :; do
  read -p " ${YUMING2}：" domain2
  if [[ -n "${domain2}" ]] && [[ "$(echo ${domain2} |grep -c '\.')" -ge '1' ]]; then
    export domainy2="Y"
  fi
  case $domainy2 in
  Y)
    export domain2="${domain2}"
  break
  ;;
  *)
    export YUMING2="敬告：请输入正确的后端域名"
  ;;
  esac
  done
  echo
  ECHOG "您的域名为：${domain}"
  ECHOG "您的域名为：${domain2}"
  echo
  read -p " [检查是否正确,正确回车继续,不正确按Q回车重新输入]： " NNKC
  case $NNKC in
  [Qq])
    install_xray_ws
    exit 0
  ;;
  *)
    echo
    print_ok "您已确认无误!"
  ;;
  esac
  ECHOY "开始执行安装程序,请耐心等候..."
  sleep 3
  echo
}

function nodejs_install() {
  ${INS} nodejs
  if [[ `node --version |egrep -o "v[0-9]+\.[0-9]+\.[0-9]+"` ]]; then
    echo ""
  else
    echo -e "\033[31m node安装失败! \033[0m"
    exit 1
  fi
  if [[ `npm --version |egrep -o "[0-9]+\.[0-9]+\.[0-9]+"` ]]; then
    echo ""
  else
    echo -e "\033[31m npm安装失败! \033[0m"
    exit 1
  fi
  npm install -g yarn
  if [[ `yarn --version |egrep -o "[0-9]+\.[0-9]+\.[0-9]+"` ]]; then
    echo ""
  else
    echo -e "\033[31m yarn安装失败! \033[0m"
    exit 1
  fi
  rm -fr sub-web && git clone https://github.com/CareyWang/sub-web.git
  if [[ $? -ne 0 ]];then
    echo -e "\033[31m sub-web下载失败! \033[0m"
    exit 1
  else
    cd sub-web
    yarn install
    timeout -k 1s 30s yarn serve
  fi
}

function nginx_install() {
  if ! command -v nginx >/dev/null 2>&1; then
    ${INS} nginx
    judge "Nginx 安装"
  else
    print_ok "Nginx 已存在"
    ${INS} nginx
  fi
  # 遗留问题处理
  mkdir -p /etc/nginx/conf.d >/dev/null 2>&1
}

function dependency_install() {
  ${INS} lsof tar
  judge "安装 lsof tar"

  if [[ "${ID}" == "centos" || "${ID}" == "ol" ]]; then
    ${INS} crontabs
  else
    ${INS} cron
  fi
  judge "安装 crontab"

  if [[ "${ID}" == "centos" || "${ID}" == "ol" ]]; then
    touch /var/spool/cron/root && chmod 600 /var/spool/cron/root
    systemctl start crond && systemctl enable crond
  else
    touch /var/spool/cron/crontabs/root && chmod 600 /var/spool/cron/crontabs/root
    systemctl start cron && systemctl enable cron
  fi
  judge "crontab 自启动配置 "

  ${INS} unzip
  judge "安装 unzip"

  # upgrade systemd
  ${INS} systemd
  judge "安装/升级 systemd"

  # Nginx 后置 无需编译 不再需要
  #  if [[ "${ID}" == "centos" ||  "${ID}" == "ol" ]]; then
  #    yum -y groupinstall "Development tools"
  #  else
  #    ${INS} build-essential
  #  fi
  #  judge "编译工具包 安装"

  if [[ "${ID}" == "centos" ]]; then
    ${INS} pcre pcre-devel zlib-devel epel-release openssl openssl-devel
  elif [[ "${ID}" == "ol" ]]; then
    ${INS} pcre pcre-devel zlib-devel openssl openssl-devel
    # Oracle Linux 不同日期版本的 VERSION_ID 比较乱 直接暴力处理。如出现问题或有更好的方案，请提交 Issue。
    yum-config-manager --enable ol7_developer_EPEL >/dev/null 2>&1
    yum-config-manager --enable ol8_developer_EPEL >/dev/null 2>&1
  else
    ${INS} libpcre3 libpcre3-dev zlib1g-dev openssl libssl-dev
  fi

  ${INS} jq

  if ! command -v jq; then
    wget -P /usr/bin https://raw.githubusercontent.com/281677160/agent/main/xray/jq && chmod +x /usr/bin/jq
    judge "安装 jq"
  fi

  # 防止部分系统xray的默认bin目录缺失
  mkdir /usr/local/bin >/dev/null 2>&1
}

function basic_optimization() {
  # 最大文件打开数
  sed -i '/^\*\ *soft\ *nofile\ *[[:digit:]]*/d' /etc/security/limits.conf
  sed -i '/^\*\ *hard\ *nofile\ *[[:digit:]]*/d' /etc/security/limits.conf
  echo '* soft nofile 65536' >>/etc/security/limits.conf
  echo '* hard nofile 65536' >>/etc/security/limits.conf

  # RedHat 系发行版关闭 SELinux
  if [[ "${ID}" == "centos" || "${ID}" == "ol" ]]; then
    sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
    setenforce 0
  fi
}

function domain_check() {
  export domain_ip="$(ping "${domain}" -c 1 | sed '1{s/[^(]*(//;s/).*//;q}')" > /dev/null 2>&1
  export local_ip=$(curl -4L api64.ipify.org)
  print_ok "检测域名解析"
  if [[ ! ${local_ip} == ${domain_ip} ]]; then
    echo
    ECHOY "域名解析IP为：${domain_ip}"
    echo
    ECHOY "本机IP为：${local_ip}"
    echo
    print_error "域名解析IP跟本机IP不一致"
    exit 1
  else
    print_ok "域名解析IP为：${domain_ip}"
    print_ok "本机IP为：${local_ip}"
    print_ok "域名解析IP跟本机IP一致"
  fi
}

function port_exist_check() {
  if [[ 0 -eq $(lsof -i:"$1" | grep -i -c "listen") ]]; then
    print_ok "$1 端口未被占用"
    sleep 1
  else
    print_error "检测到 $1 端口被占用，以下为 $1 端口占用信息"
    lsof -i:"$1"
    print_error "5s 后将尝试自动 kill 占用进程"
    sleep 5
    lsof -i:"$1" | awk '{print $2}' | grep -v "PID" | xargs kill -9
    print_ok "kill 完成"
    sleep 1
  fi
}

function configure_nginx() {
  nginx_conf="/etc/nginx/conf.d/${domain}.conf"
  cd /etc/nginx/conf.d/ && rm -f ${domain}.conf && wget -O ${domain}.conf https://raw.githubusercontent.com/281677160/agent/main/xray/web.conf
  sed -i "s/xxx/${domain}/g" ${nginx_conf}
  judge "Nginx 配置 修改"

  systemctl restart nginx
}

function generate_certificate() {
  signedcert=$(xray tls cert -domain="$local_ip" -name="$local_ip" -org="$local_ip" -expire=87600h)
  echo $signedcert | jq '.certificate[]' | sed 's/\"//g' | tee $cert_dir/self_signed_cert.pem
  echo $signedcert | jq '.key[]' | sed 's/\"//g' >$cert_dir/self_signed_key.pem
  openssl x509 -in $cert_dir/self_signed_cert.pem -noout || 'print_error "生成自签名证书失败" && exit 1'
  print_ok "生成自签名证书成功"
  chown nobody.$cert_group $cert_dir/self_signed_cert.pem
  chown nobody.$cert_group $cert_dir/self_signed_key.pem
}

function ssl_judge_and_install() {
  [[ ! -d /ssl ]] && mkdir -p /ssl
  if [[ ${houduan} == "1" ]]; then
    clxray="clashhd"
  else
    clxray="clashqd"
  fi
  if [[ -f "$HOME/.acme.sh/${domain}_ecc/${domain}.key" && -f "$HOME/.acme.sh/${domain}_ecc/${domain}.cer" && -f "$HOME/.acme.sh/acme.sh" ]]; then
    print_ok "[${domain}]证书已存在，重新启用证书"
    sleep 2
    rm -fr /ssl/* >/dev/null 2>&1
    "$HOME"/.acme.sh/acme.sh --installcert -d "${domain}" --fullchainpath /ssl/${clxray}.crt --keypath /ssl/${clxray}.key --ecc
    judge "证书启用"
    sleep 2
    "$HOME"/.acme.sh/acme.sh --upgrade --auto-upgrade
    echo $domain >"$HOME"/.acme.sh/${clxray}
    judge "域名记录"
  else
    acme
  fi
  chown -R nobody.$cert_group /ssl/*
}

function acme() {
  if [[ ! -f "$HOME/.acme.sh" ]]; then
    curl -L get.acme.sh | bash
    judge "安装 SSL 证书生成脚本"
  fi

  "$HOME"/.acme.sh/acme.sh --set-default-ca --server letsencrypt

  sed -i "6s/^/#/" "$nginx_conf"
  sed -i "6a\\\troot $website_dir;" "$nginx_conf"
  systemctl restart nginx

  if "$HOME"/.acme.sh/acme.sh --issue -d "${domain}" --webroot "$website_dir" -k ec-256 --force; then
    print_ok "SSL 证书生成成功"
    sleep 2
    if "$HOME"/.acme.sh/acme.sh --installcert -d "${domain}" --fullchainpath /ssl/${clxray}.crt --keypath /ssl/${clxray}.key --reloadcmd "systemctl restart nginx" --ecc --force; then
      print_ok "SSL 证书配置成功"
      "$HOME"/.acme.sh/acme.sh --upgrade --auto-upgrade
      echo $domain >"$HOME"/.acme.sh/${clxray}
      judge "域名记录"
    fi
  else
    print_error "SSL 证书生成失败"
    rm -rf "$HOME/.acme.sh/${domain}_ecc"
    exit 1
  fi

  sed -i "7d" "$nginx_conf"
  sed -i "6s/#//" "$nginx_conf"
}

function acme2() {
  houduan="1"
  domain="${domain2}"
  configure_nginx
  domain_check
  ssl_judge_and_install
}

function xray_uninstall() {
  bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove --purge
  find / -iname 'xray' | xargs -i rm -rf {}
  print_ok "Xray御载 完成"
  sleep 2
  systemctl stop cloudreve
  systemctl disable cloudreve
  systemctl daemon-reload
  find / -iname 'cloudreve' | xargs -i rm -rf {}
  print_ok "cloudreve御载 完成"
  sleep 2
  if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]] || [[ "$(. /etc/os-release && echo "$ID")" == "ol" ]]; then
    yum remove nginx -y
  else
    apt-get --purge remove -y nginx
    apt-get autoremove -y
    apt-get --purge remove -y nginx
    apt-get --purge remove -y nginx-common
    apt-get --purge remove -y nginx-core
  fi
  find / -iname 'nginx' | xargs -i rm -rf {}
  print_ok "nginx御载 完成"
  sleep 2
  if [[ -e "$HOME"/.acme.sh ]]; then
    clear
    echo
    [[ -f "$HOME/.acme.sh/domainjilu" ]] && PROFILE="$(cat $HOME/.acme.sh/domainjilu)"
    if [[ -f "$HOME/.acme.sh/${PROFILE}_ecc/${PROFILE}.cer" ]] && [[ -f "$HOME/.acme.sh/${PROFILE}_ecc/${PROFILE}.key" ]]; then
        export TISHI="提示：[ ${PROFILE} ]证书已经存在,如果还继续使用此域名建议勿删除.acme.sh"
     else
        export WUTISHI="Y"
     fi
     if [[ ${WUTISHI} == "Y" ]]; then
        "$HOME"/.acme.sh/acme.sh --uninstall
        rm -rf $HOME/.acme.sh
        rm -rf /ssl/*
        sed -i '/acme.sh/d' /root/.bashrc > /dev/null 2>&1
        sed -i '/acme.sh/d' /root/.cshrc > /dev/null 2>&1
        sed -i '/acme.sh/d' /root/.tcshrc > /dev/null 2>&1
      else
        ECHOY "是否卸载 acme.sh [Y/N]?"
        echo
        ECHOY "${TISHI}"
        echo
        read -p " 输入您的选择：" uninstall_acme
        case $uninstall_acme in
        [yY])
           "$HOME"/.acme.sh/acme.sh --uninstall
           rm -rf "$HOME"/.acme.sh
           rm -rf /ssl/*
           sed -i '/acme.sh/d' /root/.bashrc > /dev/null 2>&1
           sed -i '/acme.sh/d' /root/.cshrc > /dev/null 2>&1
           sed -i '/acme.sh/d' /root/.tcshrc > /dev/null 2>&1
	   print_ok "acme.sh御载 完成"
	   sleep 2
        ;;
        *) 
            print_ok "您已跳过御载acme.sh"
            echo
        ;;
        esac
       fi
    fi
  print_ok "所有卸载程序执行完毕!"
  exit 0
}

function install_xray_ws() {
  is_root
  kaishi_install
  system_check
  nodejs_install
  dependency_install
  basic_optimization
  domain_check
  port_exist_check 80
  nginx_install
  configure_nginx
  ssl_judge_and_install
  acme2
}
menu() {
  clear
  echo
  echo
  ECHOY "1、安装 Xray、nginx和cloudreve"
  ECHOY "2、打印 Xray 节点信息"
  ECHOY "3、安装 BBR、锐速加速"
  ECHOY "4、更新 Xray"
  ECHOY "5、修改 UUID/端口/路径/Tronjian密码"
  ECHOY "6、删除 阿里云盾或腾讯云盾"
  ECHOY "7、卸载 Xray、nginx和cloudreve"
  ECHOY "8、重启 Xray、nginx和cloudreve"
  ECHOY "9、退出"
  echo
  echo
  XUANZHE="请输入数字"
  while :; do
  read -p " ${XUANZHE}：" menu_num
  case $menu_num in
  1)
    install_xray_ws
    break
    ;;
  2)
    source $domain_tmp_dir/pzcon
    break
    ;;
  3)
    wget -N --no-check-certificate "https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
    break
    ;;
  4)
    systemctl stop xray
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" - install
    restart_all
    break
    ;;
  5)
    configure_gaipeizhi
    break
    ;;
    
  6)
    bash -c "$(curl -Ls https://raw.githubusercontent.com/281677160/agent/main/xray/uninstall_firewall.sh)"
    break
    ;;
  7)
    xray_uninstall
    break
    ;;
  8)
    restart_all
    break
    ;;
  9)
    exit 0
    break
    ;;
    *)
    XUANZHE="请输入正确的选择"
    ;;
  esac
  done
}
menu "$@"
