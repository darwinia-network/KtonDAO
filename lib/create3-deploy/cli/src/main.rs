use clap::Parser;
use eyre::Result;

pub mod create3;

use create3::Create3;

fn main() -> Result<()> {
    let cmd = Create3::parse();
    cmd.run()?;
    Ok(())
}
