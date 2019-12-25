# Basic Concepts

**Module**: A set of parts that can be assembled into a structure. To Xcode, that means you can have a group of lines of code that you can (re)use in different places without having to write that code again.

**Bundle**: A collection of files that make up a built app. In this case, the compiled binary and plists, images, and any databases - these files make up an app, which is an .ipa, which is just a .zip file.

**Framework**: A supporting structure, like a skeleton - Apple creates these files, which have code we use to create our apps. Not every app uses every framework. There are Private and Public frameworks. Devs can only use/add Public frameworks for their apps. Private frameworks are only used by Apple. Think of them as sets of instructions, known as libraries.

**Frameworks folder**: This folder holds the libraries/frameworks that have been included in the project, that Xcode uses to build your app.

**Product** : The results, or output, from you run and build your app.

**Products folder**: Inside the Products folder, you'll find the built version of your app, that Xcode translated from the source code into the object code for your device's processor to execute, or run.

## Target
Each project has one or more targets. Think of a target as the main thing Xcode is interested in when you decide to run and build your app.

- Each target defines a list of build settings for that project
- Each target also defines a list of classes, resources, custom scripts etc to include/use when building
- Targets are usually used for different distributions of the same project. You can have one project, with more than one target, where you can create different apps without having to have more than one project.

See Xcode Concepts: https://developer.apple.com/library/content/featuredarticles/XcodeConcepts/Concept-Targets.html
