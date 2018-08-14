# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=ProjectK by khusika @ xda-developers
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=1
device.name1=mido
supported.sdk1=27
supported.sdk2=28
'; } # end properties

# shell variables
block=/dev/block/platform/soc/7824900.sdhci/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;
overlay=/tmp/anykernel/overlay;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chmod -R 755 $ramdisk/sbin;
chmod -R 755 $overlay/init.spectrum.rc;
chmod -R 775 $overlay/init.spectrum.sh;
chown -R root:root $ramdisk/*;

## AnyKernel install
dump_boot;

# begin ramdisk changes

# sepolicy
+$bin/magiskpolicy --load /system_root/sepolicy --save $ramdisk/overlay/sepolicy \
  "allow init rootfs file execute_no_trans" \
;

# Add skip_override parameter to cmdline so user doesn't have to reflash Magisk
if [ -d $ramdisk/.subackup -o -d $ramdisk/.backup ]; then
  ui_print " "; ui_print "Magisk detected! Patching cmdline so reflashing Magisk is not necessary...";
  patch_cmdline "skip_override" "skip_override";
else
  patch_cmdline "skip_override" "";
fi;

# Add our ramdisk files if Magisk is installed
if [ -d $ramdisk/.backup ]; then
  mv $overlay $ramdisk;
  cp /system_root/init.rc $ramdisk/overlay;
  insert_line $ramdisk/overlay/init.rc "init.spectrum.rc" after 'import /init.usb.rc' "import /init.spectrum.rc";
fi

# end ramdisk changes

write_boot;

## end install

