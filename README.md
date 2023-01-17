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

