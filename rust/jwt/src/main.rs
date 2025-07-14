use std::env;

use jwt::decode_jwt;

mod jwt;

fn main() {
    let args: Vec<String> = env::args().collect();
    let token = &args[1];

    match decode_jwt(token.strip_prefix("Bearer").unwrap_or(token).trim()) {
        Ok((headers, claims)) => {
            println!(
                "Header:\n{}\n",
                serde_json::to_string_pretty(&headers).unwrap()
            );
            println!(
                "Payload:\n{}\n",
                serde_json::to_string_pretty(&claims).unwrap()
            );
        }
        Err(err) => {
            eprintln!("Error:\n{err}");
        }
    }
}
