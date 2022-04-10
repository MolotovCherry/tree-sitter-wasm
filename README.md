# Tree Sitter WASM 

Takes the entire tree sitter API and uses the Rust bindings and WSM to create a new tree sitter WASM library.

## Why?

Mainly because the tree sitter highlight API is written in Rust, so now we can use tree sitter highlighting
from WASM and use the tree sitter API as normal. It's a replacement WITH built-in highlighting!

## Setup

Download emscriptensdk and put it in a subfolder `emsdk`. Do the usual installing and activating the latest sdk.

Make sure you also have the Rust `wasm32-unknown-emscripten` build target installed.

Then do the usual `build.ps1` in a powershell terminal. Output goes to `build/`

Also, note that this is pretty experimental and may not even build properly yet. I'm still unsure how to best approach this
