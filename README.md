# iOS.Console
Console uses in iOS


## Features

1.Add custom log(with console input or code)

2.Filter

3.All logs are stored in Library/Caches, current log can be sent by mail


## How to setup

```
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
// #if DEBUG
     Console.attach(toWindow: self.window!)
// #endif
  return true
}

```

## How to open console

Shake your device


## How to add log by code

```
Console.print("log")

// log

Console.print("log1", "log2", separator: ",", color: .yellow, global: true)

// log1,log2
```

## Demo

<img src="https://github.com/mithyer/iOS.Console/blob/master/Demo/demo.gif" alt=" text" width="25%" />

