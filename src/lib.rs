

use std::panic;
use tree_sitter;


// When the `wee_alloc` feature is enabled, use `wee_alloc` as the global
// allocator.
#[cfg(feature = "wee_alloc")]
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;


pub fn main() {}

extern {
  fn alert(s: &str);
}

#[no_mangle]
pub extern fn greet() {
  unsafe{alert(&tree_sitter::LANGUAGE_VERSION.to_string());}
}
