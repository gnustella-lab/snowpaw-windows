//! snowpaw desktop client binary.

#![windows_subsystem = "windows"]

fn main() -> std::process::ExitCode {
    snowpaw_client::main_entry()
}

