# Welcome to Bluetooth CTL

## What?

A minimal CLI interface for Bluetooth devices on MacOS, allowing you to list & connect do devices. Disconnect is also implemented, but doesn't work for some reason.

## Why?

One of my computers has a Bluetooth icon disabled due to some kind of security restriction. But my colleagues like my BT headphones to be connected when I am listening to the music, and I am lazy going through settings every time I need to use it, and I don't want to install any packages I don't know (security restriction again).

## Use

1. Checkout the repo
2. `chmod u+x main.swift`
3. `./main.swift list` - show Bluetooth devices which are paired with the computer
4. `./main.swift connect <device-mac>` - connect to a Bluetooth device
5. `./main.swift disconnect <device-mac>` - try to disconnect from a Bluetooth device and see that the script is lying to you.
`
