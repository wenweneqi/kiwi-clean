SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=true
LATESTARTSERVICE=true

print_modname() {
  ui_print "*******************************"
  ui_print "  Magisk Module:虎牙精简  "
  ui_print "For Huya Live    By Hinata"
  ui_print "*******************************"
}

on_install() {
  ui_print "- 正在释放文件"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
}

tar -xf $MODPATH/tools.tar.xz -C $TMPDIR >&2
chmod -R 0755 $TMPDIR/tools
alias keycheck="$TMPDIR/tools/$ARCH32/keycheck"

work_dir=/sdcard/Android/Huya
syshosts=/system/etc/hosts

if [ ! -d $work_dir ];then
   mkdir -p $work_dir
fi

keytest() {
  ui_print "- 音量键测试"
  ui_print "   请按任意音量键:"
  if (timeout 3 /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events); then
    return 0
  else
    ui_print "   再试一次:"
    timeout 3 keycheck
    local SEL=$?
    [ $SEL -eq 143 ] && abort "   未检测到音量键!" || return 1
  fi
}

chooseport() {
  # Original idea by chainfire @xda-developers, improved on by ianmacd @xda-developers
  #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
  while true; do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events
    if (`cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
      break
    fi
  done
  if (`cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
    return 0
  else
    return 1
  fi
}

chooseportold() {
  # Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
  # Calling it first time detects previous input. Calling it second time will do what we want
  while true; do
    keycheck
    keycheck
    local SEL=$?
    if [ "$1" == "UP" ]; then
      UP=$SEL
      break
    elif [ "$1" == "DOWN" ]; then
      DOWN=$SEL
      break
    elif [ $SEL -eq $UP ]; then
      return 0
    elif [ $SEL -eq $DOWN ]; then
      return 1
    fi
  done
}

# Have user option to skip vol keys
OIFS=$IFS; IFS=\|; MID=false; NEW=false
case $(echo $(basename $ZIPFILE) | tr '[:upper:]' '[:lower:]') in
  *novk*) ui_print "- 跳过音量键 -";;
  *) if keytest; then
       VKSEL=chooseport
     else
       VKSEL=chooseportold
       ui_print "  ! 检测到遗留设备! 使用旧的 keycheck 方案"
       ui_print " "
       ui_print "- 音量键录入 -"
       ui_print "  请按音量+键:"
       $VKSEL "UP"
       ui_print "  请按音量–键"
       $VKSEL "DOWN"
     fi;;
esac
IFS=$OIFS


ui_print "选择虎牙版本"
ui_print "  音量+ = play版"
ui_print "  音量– = 国内版"
if $VKSEL; then
  ui_print "已选择play版"
      rm -rf /data/data/com.huya.kiwi/files/.props
      touch /data/data/com.huya.kiwi/files/.props
      chmod 000 /data/data/com.huya.kiwi/files/.props
else
  ui_print "已选择国内版"
      rm -rf /data/data/com.duowan.kiwi/files/.umeng
      rm -rf /data/data/com.duowan.kiwi/files/splash
      rm -rf /data/data/com.duowan.kiwi/files/.props
      rm -rf /data/user/0/com.duowan.kiwi/files/.props
      rm -rf /data/user/0/com.duowan.kiwi/files/.umeng
      rm -rf /data/user/0/com.duowan.kiwi/files/live_log
      rm -rf /data/user/0/com.duowan.kiwi/files/splash
      touch /data/data/com.duowan.kiwi/files/.umeng
      touch /data/data/com.duowan.kiwi/files/splash
      touch /data/data/com.duowan.kiwi/files/.props
      touch /data/user/0/com.duowan.kiwi/files/.props
      touch /data/user/0/com.duowan.kiwi/files/.umeng
      touch /data/user/0/com.duowan.kiwi/files/live_log
      touch /data/user/0/com.duowan.kiwi/files/splash
      chmod 000 /data/data/com.duowan.kiwi/files/.umeng
      chmod 000 /data/data/com.duowan.kiwi/files/splash
      chmod 000 /data/data/com.duowan.kiwi/files/.props
      chmod 000 /data/user/0/com.duowan.kiwi/files/.props
      chmod 000 /data/user/0/com.duowan.kiwi/files/.umeng
      chmod 000 /data/user/0/com.duowan.kiwi/files/live_log
      chmod 000 /data/user/0/com.duowan.kiwi/files/splash
fi


ui_print "选择屏蔽p2p方式(暂时全为systemless屏蔽,此选项选什么都一样)"
ui_print "  音量+ = systemless"
ui_print "  音量– = 不安装"
if $VKSEL; then
ui_print "systemless屏蔽p2p"
else
 ui_print "不安装hosts屏蔽p2p"
fi
set_perm_recursive  $MODPATH  0  0  0755  0644

