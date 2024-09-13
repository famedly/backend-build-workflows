//! Crate for testing CI workflows
#![deny(
	trivial_casts,
	trivial_numeric_casts,
	unused_extern_crates,
	unused_qualifications
)]
#![warn(
	missing_debug_implementations,
	missing_docs,
	unused_import_braces,
	dead_code,
	clippy::unwrap_used,
	clippy::expect_used,
	clippy::missing_docs_in_private_items,
	clippy::missing_panics_doc
)]
#![allow(clippy::print_stdout)]

/// Write a hello world message
pub fn hello_world() {
	let _ = std::time::Instant::now();
	println!("Hello, world!");
}

/// This function is not covered by tests for coverage checking
/// # Panics
/// Just panics, that's all.
pub fn untested_function_for_coverage() {
	println!(
		"I'm sure this part of code just works and can't horribly fail, so I just left it untested"
	);
	panic!()
}
