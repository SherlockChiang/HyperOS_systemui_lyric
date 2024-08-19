#!/system/bin/sh

MODPATH=${0%/*}

ui_print "- 开始卸载并恢复源文件..."

# 恢复APK文件
restore_apk() {
    local apk_file=$1
    local target_dir=$2

    if [ -f "$MODPATH/backup/$apk_file" ]; then
        ui_print "- 恢复${apk_file}"
        cp -f "$MODPATH/backup/$apk_file" "$target_dir" >/dev/null 2>&1
        chmod 0644 "$target_dir/$apk_file"
    else
        ui_print "- 找不到备份的${apk_file}，跳过..."
    fi
}

restore_apk "Settings.apk" "/system_ext/priv-app/Settings/"
restore_apk "MiuiSystemUI.apk" "/system_ext/priv-app/MiuiSystemUI/"

ui_print "- 清理缓存和临时文件..."
rm -rf /data/dalvik-cache >/dev/null 2>&1
rm -rf /data/system/package_cache >/dev/null 2>&1
rm -rf $MODPATH/backup >/dev/null 2>&1

ui_print "- 卸载完成，系统已恢复原状。"
