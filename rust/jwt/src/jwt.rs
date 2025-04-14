use base64::Engine as _;
use serde_json::Value;
use std::error::Error;
use std::str;

fn base64_url_decode(input: &str) -> Result<Vec<u8>, Box<dyn Error>> {
    let input = input.replace('-', "+").replace('_', "/");
    let padding = (4 - (input.len() % 4)) % 4;
    let padded_input = format!("{}{}", input, "=".repeat(padding));
    let decoded = base64::engine::general_purpose::STANDARD.decode(&padded_input)?;
    Ok(decoded)
}

pub fn decode_jwt(token: &str) -> Result<(Value, Value), Box<dyn Error>> {
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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_decode_jwt_valid() {
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.\
                    eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.\
                    SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c";

        let (header, claims) = decode_jwt(token).unwrap();

        assert_eq!(header["alg"], "HS256");
        assert_eq!(header["typ"], "JWT");
        assert_eq!(claims["sub"], "1234567890");
        assert_eq!(claims["name"], "John Doe");
        assert_eq!(claims["iat"], 1516239022);
    }

    #[test]
    fn test_decode_jwt_invalid_token_structure() {
        let token = "invalid.token.extra.part";
        let result = decode_jwt(token);
        assert!(result.is_err());
    }

    #[test]
    fn test_decode_jwt_invalid_base64() {
        let token = "invalid~base64.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.signature";
        let result = decode_jwt(token);
        assert!(result.is_err());
    }

    #[test]
    fn test_decode_jwt_invalid_json() {
        let invalid_json = base64::engine::general_purpose::URL_SAFE.encode("not valid json");

        let token = format!(
            "{}.{}.signature",
            base64::engine::general_purpose::URL_SAFE.encode(r#"{"alg":"HS256","typ":"JWT"}"#),
            invalid_json
        );

        let result = decode_jwt(&token);
        assert!(result.is_err());
    }
}
