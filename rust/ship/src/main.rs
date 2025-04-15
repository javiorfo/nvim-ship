use std::env;

use arguments::Args;
use error::ShipResult;
use request::Shipper;

mod arguments;
mod error;
mod request;
mod xml;

fn main() -> ShipResult {
    let args: Vec<String> = env::args().collect();
    let mut shipper = Shipper::new(Args::new(&args));
    shipper.call()?;

    Ok(())
}
