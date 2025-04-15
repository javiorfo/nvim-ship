#[derive(Debug)]
pub enum ShipError {
    Io(std::io::Error),
    Curl(curl::Error),
    Form(curl::FormError),
    Generic(String),
}

pub type ShipResult<T = ()> = Result<T, ShipError>;

impl std::fmt::Display for ShipError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ShipError::Io(e) => write!(f, "IO internal error: {}", e),
            ShipError::Curl(e) => write!(f, "Curl internal error: {}", e),
            ShipError::Form(e) => write!(f, "Form internal error: {}", e),
            ShipError::Generic(e) => write!(f, "{}", e),
        }
    }
}

impl std::error::Error for ShipError {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        match self {
            ShipError::Io(e) => Some(e),
            ShipError::Curl(e) => Some(e),
            ShipError::Form(e) => Some(e),
            ShipError::Generic(_) => None,
        }
    }
}
