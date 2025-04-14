use base64::Engine as _;
use serde_json::Value;
use std::error::Error;
use std::{env, str};

fn base64_url_decode(input: &str) -> Result<Vec<u8>, Box<dyn Error>> {
    let input = input.replace('-', "+").replace('_', "/");
    let padding = (4 - (input.len() % 4)) % 4;
    let padded_input = format!("{}{}", input, "=".repeat(padding));
    let decoded = base64::engine::general_purpose::STANDARD.decode(&padded_input)?;
    Ok(decoded)
}

fn decode_jwt(token: &str) -> Result<(Value, Value), Box<dyn Error>> {
    let parts: Vec<&str> = token.split('.').collect();
    if parts.len() != 3 {
        return Err("Invalid JWT token".into());
    }

    let header = parts[0];
    let decoded_header = base64_url_decode(header)?;
    let header_str = str::from_utf8(&decoded_header)?;
    let headers: Value = serde_json::from_str(header_str)?;

    let payload = parts[1];
    let decoded_payload = base64_url_decode(payload)?;
    let payload_str = str::from_utf8(&decoded_payload)?;
    let claims: Value = serde_json::from_str(payload_str)?;

    Ok((headers, claims))
}

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
            eprintln!("Error:\n{}", err);
        }
    }
}
