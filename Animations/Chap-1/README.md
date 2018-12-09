# Animation Chapter-1 Basics

![image](https://github.com/byelaney/Swift-4.2-Guide/blob/master/Animations/Chap-1/chap-1.gif)

```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    heading.center.x -= view.bounds.width
    username.center.x -= view.bounds.width
    password.center.x -= view.bounds.width

    cloud1.alpha = 0.0
    cloud2.alpha = 0.0
    cloud3.alpha = 0.0
    cloud4.alpha = 0.0
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    UIView.animate(withDuration: 0.5) {
        self.heading.center.x += self.view.bounds.width
    }
    UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
        self.username.center.x += self.view.bounds.width
    }, completion: nil)
    UIView.animate(withDuration: 0.5, delay: 0.4, options: [], animations: {
        self.password.center.x += self.view.bounds.width
    }, completion: nil)

    // Cloud animation
    UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
        self.cloud1.alpha = 1
    }, completion: nil)

    UIView.animate(withDuration: 0.5, delay: 0.7, options: [], animations: {
        self.cloud2.alpha = 1
    }, completion: nil)

    UIView.animate(withDuration: 0.5, delay: 0.9, options: [], animations: {
        self.cloud3.alpha = 1
    }, completion: nil)

    UIView.animate(withDuration: 0.5, delay: 1.1, options: [], animations: {
        self.cloud4.alpha = 1
    }, completion: nil)
  }
```
