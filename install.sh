# Set to true if you need to enable Magic Mount
# Most mods would like it to be enabled
SKIPMOUNT=false
#是否安装模块后自动关闭，改为true，安装后不会自动勾选启用
# Set to true if you need to load system.prop
PROPFILE=false

# Set to true if you need post-fs-data script
POSTFSDATA=false

# Set to true if you need late_start service script
LATESTARTSERVICE=false

##########################################################################################
# Installation Message
##########################################################################################

print_modname() {
  ui_print "*******************************"
  ui_print "   方案：by 酷安@白羊唐黎明     "
  ui_print " "
  ui_print "   处理：by 酷安@夙丶愿丨       "
  ui_print " "
  ui_print "   模块：by 酷安@多幸运i        "
  ui_print " "
  ui_print "   二改：by 酷安@Uranium92     "
  ui_print "*******************************"
}

# 文件替换路径
REPLACE="
/system/system_ext/priv-app/Settings/oat
/system/system_ext/priv-app/MiuiSystemUI/oat
"

# 释放文件并安装模块
on_install() {
  if [ -d "/data/adb/modules/miuisystemlyric/" ]; then
    ui_print "您已经安装过模块。如需更新，请卸载并重启后再安装。"
    exit 0
  fi

  configure_environment

  ui_print "- 请问你的ROM是否移除了系统应用签名验证？"
  ui_print ""
  ui_print "- 没移除请摁：[音量+]执行移除，移除请摁：[音量-]跳过"
  ui_print ""
  ui_print "- 【官方包】请无脑摁：[音量+]执行移除"
  ui_print "- 【官改包】请根据ROM修改情况选择！"
  ui_print "- 若services.jar已移除签名验证，请摁：[音量-]跳过"
  ui_print "- 若services.jar未移除签名验证，请更换勿刷入该模块"

  if keyListener; then
    ui_print "- 已选择[音量+]，将移除系统签名验证"
    sett1=1
  else
    ui_print "- 已选择[音量-]，跳过移除系统签名验证步骤"
    sett2=0
  fi

  backup_apk "Settings.apk" "/system_ext/priv-app/Settings/"
  backup_apk "MiuiSystemUI.apk" "/system_ext/priv-app/MiuiSystemUI/"

  deploy_files

  modify_apk "Settings.apk" "/system_ext/priv-app/Settings/" "Settings"
  modify_apk "MiuiSystemUI.apk" "/system_ext/priv-app/MiuiSystemUI/" "MiuiSystemUI"

  if [ $sett1 = 1 ]; then
    modify_services_jar
  fi

  enable_statusbar_lyric
  clean_cache
  ui_print "- 安装完成，感谢支持！"
}

# 配置安装环境
configure_environment() {
  ui_print "- 正在配置安装环境，请稍候"
  rm -rf /data/local/tmp/Dxy
  mkdir -p /data/local/tmp/Dxy/tmp
  unzip -o "$ZIPFILE" 'module.prop' -d $MODPATH >&2
  unzip -o "$ZIPFILE" -d /data/local/tmp >&2
  chmod -R 0777 /data/local/tmp/Dxy/*
  cd /data/local/tmp/Dxy
  ./7zz x openjdk.7z >/dev/null 2>&1
  chmod -R 0777 openjdk
  export PATH=./openjdk/bin:$PATH
  export LD_LIBRARY_PATH=/data/local/tmp/Dxy/tmp
}

# 按键监听器
keyListener() {
  while true; do
    getevent -qlc 1 2>&1 | grep VOLUME | grep " DOWN" > /data/local/Dxy
    if grep -q "VOLUMEUP" /data/local/Dxy; then
      return 0
    elif grep -q "VOLUMEDOWN" /data/local/Dxy; then
      return 1
    fi
  done
}

# 备份APK文件
backup_apk() {
  local apk_file=$1
  local source_dir=$2

  ui_print "- 备份${apk_file}"
  cp -r $source_dir$apk_file /data/adb/modules/miuisystemlyric/backup/ >/dev/null 2>&1
  if [ ! -f "/data/adb/modules/miuisystemlyric/backup/$apk_file" ]; then
    ui_print "- 备份失败，停止安装"
    error_exit
  fi
}

# 部署文件
deploy_files() {
  ui_print "- 部署修改文件"
  cp /system_ext/priv-app/Settings/Settings.apk .
  cp /system_ext/priv-app/MiuiSystemUI/MiuiSystemUI.apk .
  chmod 0777 Settings.apk MiuiSystemUI.apk
}

# 修改APK文件
modify_apk() {
  local apk_file=$1
  local target_dir=$2
  local ui_name=$3

  ui_print "- 正在修改${ui_name}"
  ./sky -$ui_name $apk_file >/dev/null 2>&1
  if [ -f "$apk_file" ]; then
    mkdir -p $MODPATH$target_dir
    mv $apk_file $MODPATH$target_dir
  else
    error_exit
  fi
}

# 修改services.jar
modify_services_jar() {
  cp /system/framework/services.jar .
  chmod 0777 services.jar
  ui_print "- 修改services.jar"
  ./sky -services services.jar >/dev/null 2>&1
  if [ -f 'services.jar' ]; then
    mkdir -p $MODPATH/system/framework/
    mv services.jar $MODPATH/system/framework/services.jar
  else
    error_exit
  fi
}

# 开启状态栏歌词
enable_statusbar_lyric() {
  ui_print "- 开启状态栏歌词"
  settings put system system_statusbar_lyric 1
}

# 清理缓存
clean_cache() {
  ui_print "- 清理MIUI系统缓存"
  rm -rf /data/dalvik-cache /data/system/package_cache /data/local/tmp/Dxy >/dev/null 2>&1
}

# 错误处理
error_exit() {
  rm -rf /data/dalvik-cache /data/system/package_cache /data/local/tmp/Dxy >/dev/null 2>&1
  ui_print "- 安装处理失败，请尝试其他方法"
  exit 0
}

set_permissions() {
  set_perm_recursive  $MODPATH  0  0  0755  0644
}