#
# Rust's emscripten target is kinda broken and needs additional help to compile properly
# You need to install Rust target `wasm32-unknown-emscripten` for this
#

param(
    [switch]$release
)

$CUR_DIR = $PSScriptRoot | ForEach-Object { $_ -replace "\\","/" }
$LIB_DIR = "$CUR_DIR/tree-sitter-lib"
$WEB_DIR = "$LIB_DIR/binding_web"


$OUT_DIR = "$CUR_DIR/build/"
if (!(test-path $OUT_DIR))
{
    New-Item -ItemType "directory" -Path $OUT_DIR > $null
} else {
    Remove-Item "$OUT_DIR/*"
}

# set up debug vs release flags
$EMCC_FLAGS = "-O3"
if (-Not $release) {
    $EMCC_FLAGS = "-s ASSERTIONS=1 -s SAFE_HEAP=1 -O0"
}

# set up emscripten env
./emsdk/emsdk_env.ps1 > $null

# this was a patch to fix rust linking with emscripten build target
# https://github.com/rust-lang/rust/issues/92738
$Env:EMSCRIPTEN_LINKING_RUST=1

$EMCC_CFLAGS = @"
  --no-entry
  -gsource-map
  -s ERROR_ON_UNDEFINED_SYMBOLS=0
  $EMCC_FLAGS
  -s WASM=1
  -s TOTAL_MEMORY=33554432
  -s ALLOW_MEMORY_GROWTH=1
  -s MAIN_MODULE=2
  -s NO_FILESYSTEM=1
  -s NODEJS_CATCH_EXIT=0
  -s NODEJS_CATCH_REJECTION=0
  -s EXPORTED_FUNCTIONS=@$WEB_DIR/exports.json
  -std=c99
  -D 'fprintf(...)='
  -D NDEBUG=
  -I $LIB_DIR/src
  -I $LIB_DIR/include
  --js-library $WEB_DIR/imports.js
  --pre-js $WEB_DIR/prefix.js
  --post-js $WEB_DIR/binding.js
  --post-js $WEB_DIR/suffix.js
  $LIB_DIR/src/lib.c
  $WEB_DIR/binding.c
  -o ${OUT_DIR}tree-sitter.js
"@ | foreach-object { $_ -replace [Environment]::NewLine, "" }

$Env:EMCC_CFLAGS = $EMCC_CFLAGS

$outdir = ""
if ($release) {
    cargo build --target=wasm32-unknown-emscripten --release
    $outdir = "release"
} else {
    cargo build --target=wasm32-unknown-emscripten
    $outdir = "debug"
}

Move-Item -Path "$CUR_DIR/target/wasm32-unknown-emscripten/$outdir/*.wasm" -Destination "$OUT_DIR"
Move-Item -Path "$CUR_DIR/target/wasm32-unknown-emscripten/$outdir/deps/*.map" -Destination "$OUT_DIR"
