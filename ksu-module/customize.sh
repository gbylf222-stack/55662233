SKIPUNZIP=0
ui_print "- Brightness Floor Overlay (14% minimum)"
ui_print "- 静态RRO覆盖，开机由系统自动扫描生效"
set_perm_recursive $MODPATH 0 0 0755 0644
if [ -f "$MODPATH/system_ext/overlay/BrightnessFloorOverlay.apk" ]; then
  set_perm "$MODPATH/system_ext/overlay/BrightnessFloorOverlay.apk" 0 0 0644
  ui_print "- overlay apk 已就位"
else
  ui_print "! 警告: 没找到 BrightnessFloorOverlay.apk"
  abort "缺少编译好的overlay apk，安装终止"
fi
