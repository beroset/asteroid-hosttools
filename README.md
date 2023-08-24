# asteroid-hosttools
A collection of tools to make it easy to work with AsteroidOS watches from a Linux host

These tools are intended to make it a little easier and faster to use an [AsteroidOS](https://github.com/AsteroidOS) watch.  To give an idea of how they're intended to be used, here's a short summary:

Let's say you have a TicWatch Pro watch (codename `catfish`) that is running the stock WearOS image, and you'd like to try out AsteroidOS.

`flashy catfish --nightly --temp`

This automatically downloads the nightly catfish images and does a temporary install.

`watch-image catfish --save`

This saves the entire flash image of the watch as a file. It's about 3.6GiB, so make sure you have room.

After a while, you decide to use AsteroidOS all the time, so you install it permanently:

`flashy catfish --nightly`

Much later, perhaps you find another watch you like better and would like to sell this one.  Or perhaps you just want to revert to WearOS to see how it does some particular thing.  You can restore it like this with the previously saved image file:

`watch-image catfish --restore`

Now the next time you reboot the watch it will start up in WearOS.

## flashy
This tool allows a user to easily flash an image of AsteroidOS to a supported watch connected via USB.  To use it, the environment variable `ASTEROIDROOT` should be defined and point to the top level directory of a local copy of the [`asteroid` project](https://github.com/AsteroidOS/asteroid) if you intend to flash images that you have created.
If you want to just use files from the nightly build, the script will automatically download them into the current directory and then flash them into the watch per the parameters given.

### Options
The program options are currently:
```
./flashy codename [option]
Deploy AsteroidOS binary image to a watch.

Available options:
-h or --help        prints this help screen and quits
-b or --bootonly    only push the boot image (implies temp; image already pushed)
-f or --fastboot    watch is already in fastboot mode
-l or --local       image files are in current working directory
-t or --temp        perform a temporary install (watch is running WearOS)
-n or --nightly     download image file(s) from nightly builds
-N or --dryrun      don't actually flash, just show what would happen
```

### Examples

#### Try a temporary installation
If you have a `sturgeon` model watch currently running WearOS (see https://asteroidos.org/install/ for a list of supported watches and their codenames) connected via USB to your computer and you've got your Linux host set up to automatically give the watch an IP address, you can download and temporarily install AsteroidOS to the watch with a single command:

```
./flashy sturgeon --temp --nightly
```
If you want to see what it *would* do if you execute that command (or any other `flashy` command), just use the `-N` or `--dryrun` option which will show but not execute the commands that it would have executed.
```
./flashy sturgeon --temp --nightly --dryrun
```

#### Try a permanent installation
If you have verified that your watch successfully runs AsteroidOS in a temporary mode, you can convert to a "permanent" installation easily:

```
./flashy sturgeon --nightly
```

This also works to do a fresh flash over an existing "permanent" installation.  We say "permanent" in quotation marks because reverting to WearOS is typically simple as restoring the original boot partition.

## watch-image
This tool allows a user to easily save and restore the original disk image for a watch.  If you would like to try [AsteroidOS](https://github.com/AsteroidOS) on your watch, but would like to be able to restore the "as shipped" version easily (perhaps to resell the watch), this tool is for you.  

**NOTE:** the watch must be running AsteroidOS for this tool to work

### Options
The program options are currently:
```
./watch-image codename [option]
Save/restore boot partition from watch running AsteroidOS.

Available options:
-d or --dissect     separates previously saved image into one file per partition
-h or --help        prints this help screen and quits
-i or --image FN    uses FN as the file name of the image
-r or --restore     restore the boot partition of the watch
-s or --save        save the entire watch image (may be 4G or more!)
-q or --quiet       don't emit messages describing the action
-N or --dryrun      don't actually flash, just show what would happen
```

### Examples

#### Save image using a temporary installation
If you have a `catfish` model watch currently a temporary installation of AsteroidOS, you can save the entire watch file image with a single command:

```
./watch-image catfish --save
```

This will be a large file and take some time, but it only needs to be done once.  Note that although it will work with either a temporary or permanent installation of AsteroidOS, it will be most useful if it's done with a temporary installation.  This is because the `boot` and `userdata` partitions are unchanged by a temporary installation but are altered by a permanent installation.  The effect, if done with a permanent installation, would be to copy the AsteroidOS boot partition rather than the existing stock version provided by the manufacturer, making later restoration impossible unless you can find a copy of the original boot partition somewhere.

This creates a file named `original-`codename`.img` where *codename* is replaced with the provided codename on the command line.  So for our `catfish` example, the file would be named `original-catfish.img` and would be placed in the current directory. It's possible to override that by specifying the name of the file with the `--image` option:

```
./watch-image catfish --save --image ~/watchimages/my-alternative-name.foo
```

If you want to see what it *would* do if you execute that command (or any other `watch-image` command), just use the `-N` or `--dryrun` option which will show but not execute the commands that it would have executed.
```
./watch-image catfish --save --dryrun
```

#### Restore original OS to the watch
If you have a permanent installation of AsteroidOS on your watch and have already saved the image as described above using a temporary installation, you can restore your watch to the original operating system:

```
./watch-image catfish --restore
```

This reverts to the original boot partition, effectively restoring the original operating system.  Reboot the watch to boot into the original OS (usually WearOS). 

#### Dissect a saved disk image
It's easy to extract all partitions to individual image files:

```
./watch-image catfish --dissect
```

This will extract each partition into a separate file named for that partition.  By default it will use the same naming scheme described above, so it will expect a file in the current directory named `original-catfish.img`.  It's possible to override that by specifying the name of the file with the `--image` option. As described earlier.

## watch-util
This is a multi-use utility to do various things on an AsteroidOS watch.  For example, to put many of my preferred settings into the emulated watch using QEMU, I use this command:

```
./watch-util --qemu forgetkeys \
    settimezone America/New_York \
    settime \
    routing \
    wallpaper ~/AsteroidOS/unofficial-watchfaces/wallpaper.jpg \
    pushface ~/AsteroidOS/unofficial-watchfaces/analog-weather-glow \
    watchface analog-weather-glow \
    restart
```

### Options
The program options are currently:

```
watch-util v1.1
./watch-util [option] [command...]
Utility functions for AsteroidOS device.  By default, uses "SSH Mode"
but can also use "ADB Mode."

Available options:
-h or --help    prints this help screen and quits
-a or --adb     uses ADB command to communicate with watch
-p or --port    specifies a port to use for ssh and scp commands
-r or --remote  specifies the remote (watch)  name or address for ssh and scp commands
-q or --qemu    communicates with QEMU emulated watch (same as -r localhost -p 2222 )
-v or --version displays the version of this program

Available commands:
backup BD       backs up settings of currently connected watch to directory BD
restore BD      restores previously saved settings from dir BD to connected watch
fastboot        reboots into bootloader mode
forgetkeys      forgets the ssh keys for both "watch" and "192.168.2.15"
snap            takes a screenshot and downloads it to a local jpg file
settime         sets the time on the watch according to the current time on host
listtimezones   lists the timezones known to the watch
settimezone TZ  sets the timezone on the watch to the passed timezone
wallpaper WP    sets the wallpaper on the watch to named file WP
restart         restarts the ceres user on the watch
reboot          reboots the watch
waitwatch MSG   wait for a watch to connect while displaying MSG
routing         sets up the routing to go through the local host and DNS 1.1.1.1
pushface WF     pushes the named watchface to the watch (point to WF directory)
watchface WF    sets the active watchface to the named watchface
screen on|off   sets the screen always on or normal mode
```

### Examples

#### Push a new watchface to your watch
With the default setup, you can easily push a new watchface to your watch and activate it in one command.

```
./watch-util \
    pushface ~/AsteroidOS/unofficial-watchfaces/my-new-watchface \
    watchface my-new-watchface \
    restart \
    wait "Waiting for watch"
```

#### List timezones on your watch
You can list timezones your watch knows using this command:

```
./watch-util listtimezones
```

#### Set timezone on your watch
You can easily set a timezone on your watch

```
./watch-util settimezone Europe/Paris
```

#### Take a screenshot from your watch
Taking a screenshot from your watch is now very simple:

```
./watch-util snap
```

This will immediately take a screenshot on the watch and copy it to your local directory named with a timestamp, so a screenshot would be named something like `20230117_095533.jpg` for a screenshot taken on 17 January 2023 at 9:55:33 local time.  Note that the timestamp is preserved from the watch, so the timestamp of the file will be the time that the watch thought it was at the time of the screenshot.  The two timestamps might not be the same, but assuming both are synchronized, should differ by no more than a few seconds.

#### Change connected watches
If you have a watch connected to the computer via USB and then change it to another one, `ssh` will rightly complain:

>     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
>     @    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
>     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
>     IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
>     Someone could be eavesdropping on you right now (man-in-the-middle attack)!
>     It is also possible that a host key has just been changed.

The easy way to deal with this is to remove the old keys from the previous watch.  This can be combined with other commands which are always executed in the order they appear on the command line:

```
./watch-util forget-keys settime
```

You will be prompted to accept the new keys.  If you say yes to that, the new keys will be accepted and then, in this case, the `settime` command will be executed.

#### Backup/restore settings for a watch
Most of the configuration options in Settings and the settings for various programs can be backed up very easily:

```
./watch-util backup mywatchconfig
```

This will navigate to a directory `mywatchconfig` which *must already exist* and save the configuration from the `ceres` user on the watch to that directory.  

Restoration is very similar:

```
./watch-util restore mywatchconfig restart
```

This will restore the settings to the connected watch.  **NOTE:** Use this option *very carefully*, as it will overwrite settings already on the watch.  For instance, it will set the current watchface regardless of whether that watchface is actually installed on the watch.  It's recommended to do a `restart` after restoring the configuration so that the settings take effect.  
