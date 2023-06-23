<img src="https://github.com/android-generic/artwork/raw/master/brand/Android-Generic_Logo__2_transparent.png">

# Android-Generic Project Readme

## What Is This?

Android-Generic Project is a collection of scripts, manifests & patches that allow for rapid prototyping of Android projects based off AOSP to produce generic images for Linux PC hardware as well as others.

The initial two versions of AG were able to help so many projects, but there were a few restraints. So we reworked the source to become the project you see here.

## Key Features

 - **Support for multiple targets:** AG v2023 can now be used to build images for a variety of targets, including Android phones, tablets, Raspberry Pi, emulators, TVs, and PCs. As usual, we start things out with the PC target, and let that act as an example for the rest.
Target-based system: AG v2023 uses a new target-based system that makes it easier to build images for specific targets.
 - **Target variants:** AG v2023 now supports target variants, which allow you to build images with different configurations for different targets. This system is used to have separate base structures for targets. So for the PC builds (target), we will have the variants: Android-x86 base, Bliss OS base, Bliss OS Go, etc.
 - **Conditions for menu items:** AG v2023 allows you to use conditions to control the availability of menu items. This makes it possible to create more complex and flexible menus.
 - **Addon templates:** AG v2023 includes addon templates that you can use to create your own addons. Addons are a great way to extend the functionality of AG.
 - **Public and private addons:** AG v2023 supports both public and private addons. Public addons are available to everyone, while private addons are only available to a select group of users. 

## Updates

In addition to the new features listed above, AG v2023 also includes a number of updates and improvements. These include:
 
 - Updates to the easy-menu system for more dynamic menu options.
 - A new targets based system.
 - The ability to add target variants.
 - The ability to lock the process with conditions per option.
 - Updated api-32 support.
 - Added api-33 support.
 - Reworked manifest structure to include in targets.
 - Added addon template for contributors to use to create their own addons.
 - Added Targets template for contributors to use to create their own targets.
 - Reworked open/private addon structure and added new addons.

## Generic/PC Addons

The following new addons have been added for generic/PC targets:

 - Configurable battery stats addon
 - Rotation/orientation configuration options through Grub
 - Expanded LMKD configuration addon
 - LMKD tuning options through Grub
 - Memory tuning options through Grub
 - Performance tuning options through Grub

## Licensed Addons

The following new addons have been added for licensed targets:

 - Device Management addon
 - Navbar tuning addon
 - Recents tuning addon
 - QS settings tile customization addon
 - Addon for locking various features
 - Customizing new user functions addon
 - Configuring app uninstalls addon
 - Addon for locking the ability for the user to change settings
 - Special Requests? contact us

We hope you enjoy these new features and improvements!

The menu system in this version has been adapted to use our own [easy-menu-system](https://github.com/electrikjesus/easy-menu-system), which is based on [easybashgui](https://sites.google.com/site/easybashgui/), so it will automatically detect and use: yad, gtkdialog, kdialog, zenity, Xdialog, (c)dialog, whiptail or bash builtins to display the options. That means this system should work on any server or SSH session.

### Development Chats:

Telegram:
[PC/x86/x86_64/waydroid](https://t.me/androidgenericpc)


### Resources:

AG Artwork:  
[Android-Generic Artwork](https://github.com/android-generic/artwork)

AG Documentation:
[Android-Generic Project Documentation](https://android-generic-project.gitbook.io/documentation/)

Source & Troubleshooting Documentation:  
[Android-x86 Documentation](https://www.android-x86.org/documentation.html)

[Bliss OS Docs](https://docs.blissos.org)

[**LICENSING**](LINCENSING.md)
[**OPEN_SOURCE LICENSE**](LICENSE.md)
[**CONTRIBUTING**](CONTRIBUTING.md)
[**CODE OF CONDUCT**](CODE_OF_CONDUCT.md)

## Documentation:

Our documentation has moved to it's own repo:
[AG Documentation Repo](https://github.com/android-generic/documentation)

[Android-Generic Project Documentation Site](https://android-generic-project.gitbook.io/documentation/)


# Credits

We'd like to say thanks to all these great individuals first:
@phhusson @cwhuang @maurossi @goffioul @me176c-dev @bosconovic @farmerbb @aclegg2011 @eternityson and many others

And these great teams second:
@Google @LineageOS @GZR @OmniROM @SlimROM @ParanoidAndroid @dahliaOS @waydroid and many others, for you still lead the way for Open Innovation in the Android community. 

Projects Used:
@boringdroid @easybashgui @smart-dock @android-x86 @projectceladon 


