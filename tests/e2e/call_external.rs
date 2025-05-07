use std::process::Command;

#[test]
fn test_stuff() {
	Command::new("curl")
		.args(["http://nginx"])
		.output()
		.expect("Should be able to talk to nginx");
}
