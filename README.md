# rustBobbleHeadSimulation: Desktop Bobble Head Simulation in Rust and QML
Nick Phua 2025

Rust based desktop simulation of 3 different types of bobble heads.

## Description of the Project
This project is just a simple desktop application that runs a bobble head simulation with 
the back end in Rust and the front end in QML. 
The bobble head simulation uses a spring-damper physics, like I've learned in my physics class.

![Ferris the Rustacean](/images/rust_crab.gif) ![Cat Bobble Head](/images/cat.gif) ![Baseball Player Bobble Head](/images/baseball.gif)

### Features
- **Three Unique Bobble Heads**:
  - **Ferris the Rustacean**: The beloved Rust mascot.
  - **Cat**: A cute orange tabby.
  - **Baseball Player**: A sporty bobble head.
- **Physics Simulation**: Realistic spring-damper physics for the bobbling head movement.

- **Interactive**:
  - Drag the bobble head body to move the window around your screen.
  - Interact with the head/claws to make them bobble.
  - Menu system to switch between bobble heads.

## Prerequisites

1.  **Rust**: [Install Rust](https://www.rust-lang.org/tools/install)
2.  **Qt**: You need Qt installed (Qt 5.15+ or Qt 6).
    - On Ubuntu/Debian: `sudo apt install qt6-base-dev qt6-declarative-dev libqt6svg6-dev` 
    - On Windows: Install via the Qt Online Installer.

## Build and Run

1.  **Build and Run from Source**:
    ```bash
    #If you have the prerequisites installed, as above then run: 
    cargo run
    ```


## Processes

This video from KDAB introduce me on how to expose QML object to Rust variables, It seems
to work as thin wrapper for C++ types to then be converted into Rust types.


# Acknowledgements 
This video is the initial tutorial I used to get started with this project
- [QML with Rust Tutorial Link](https://www.youtube.com/watch?v=uR4RzDjctm4)

# Sources

- [Source for Ferris The Crab svg](https://rustacean.net/)
- [Source for Kitty SVG](https://www.svgrepo.com/svg/454286/cat-halloween-kitty-2)
- [Source for Baseball Player SVG](https://www.svgrepo.com/svg/106207/baseball-player)

# License
This project is licensed under the MIT License - see the LICENSE file for details.
