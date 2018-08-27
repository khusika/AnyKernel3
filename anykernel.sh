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
device.name1=tissot
device.name2=Mi A1
device.name3=tissot_sprout
supported.sdk1=27
supported.sdk2=28
'; } # end properties

# shell variables
block=/dev/block/platform/soc/7824900.sdhci/by-name/boot;
is_slot_device=1;
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
chmod -R 755 $overlay/init.khusika.rc;
chmod -R 775 $overlay/init.spectrum.sh;
chown -R root:root $ramdisk/*;

## AnyKernel install
dump_boot;

# begin ramdisk changes

# Add skip_override parameter to cmdline so user doesn't have to reflash Magisk
if [ -d $ramdisk/.subackup -o -d $ramdisk/.backup ]; then
  ui_print " "; ui_print "Magisk detected! Patching cmdline so reflashing Magisk is not necessary...";
  patch_cmdline "skip_override" "skip_override";
else
  patch_cmdline "skip_override" "";
fi;

# Clean up other kernels' ramdisk overlay files
rm -rf $ramdisk/overlay;

# Add our ramdisk files if Magisk is installed
if [ -d $ramdisk/.backup ]; then
  mv $overlay $ramdisk;
  cp /system_root/init.rc $ramdisk/overlay;
  insert_line $ramdisk/overlay/init.rc "init.spectrum.rc" after 'import /init.usb.rc' "import /init.spectrum.rc";
  insert_line $ramdisk/overlay/init.rc "init.khusika.rc" after 'import /init.spectrum.rc' "import /init.khusika.rc";
fi

# Fix selinux denials for /init.*.sh
$bin/magiskpolicy --load /system_root/sepolicy --save $ramdisk/overlay/sepolicy \
  "allow init rootfs file execute_no_trans" \
  "allow toolbox toolbox capability sys_admin" \
  "allow toolbox property_socket sock_file write" \
  "allow toolbox default_prop property_service set" \
  "allow toolbox init unix_stream_socket connectto" \
  "allow toolbox init fifo_file { getattr write }" && \
  { cat "$ramdisk/overlay/sepolicy" > /system_root/sepolicy; }

# end ramdisk changes

write_boot;

## end install

