use std::{str::FromStr, time::Duration};

#[derive(Default, Debug)]
pub struct Args<'a> {
    pub timeout: Duration,
    pub url: &'a str,
    pub method: Method,
    pub body: Option<&'a str>,
    pub ship_file: &'a str,
    pub show_headers: ShowHeaders,
    pub headers: Vec<&'a str>,
    pub save: bool,
    pub ship_output_folder: &'a str,
    pub insecure: bool,
}

impl<'a> Args<'a> {
    pub fn new(args: &'a [String]) -> Self {
        let mut arg = Self::default();

        let mut i = 1;
        while i < args.len() {
            match args[i].as_str() {
                "-t" => arg.timeout = Duration::from_secs(args[i + 1].trim().parse().unwrap_or(30)),
                "-m" => arg.method = args[i + 1].trim().parse().unwrap_or_default(),
                "-u" => arg.url = args[i + 1].trim(),
                "-f" => arg.ship_file = args[i + 1].trim(),
                "-h" => arg.show_headers = args[i + 1].trim().parse().unwrap_or_default(),
                "-c" => arg.headers = args[i + 1].split(';').collect(),
                "-s" => arg.save = args[i + 1].trim().parse().unwrap_or(false),
                "-d" => arg.ship_output_folder = args[i + 1].trim(),
                "-b" => arg.body = Some(args[i + 1].trim()),
                "-i" => arg.insecure = args[i + 1].trim().parse().unwrap_or(false),
                _ => break,
            }
            i += 2;
        }

        arg
    }
}

#[derive(Default, Debug)]
pub enum ShowHeaders {
    All,
    Res,
    #[default]
    None,
}

impl FromStr for ShowHeaders {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "all" => Ok(ShowHeaders::All),
            "res" => Ok(ShowHeaders::Res),
            "none" => Ok(ShowHeaders::None),
            _ => Err(()),
        }
    }
}

#[derive(Default, Debug)]
pub enum Method {
    #[default]
    Get,
    Post,
    Put,
    Head,
    Patch,
    Delete,
}

impl AsRef<str> for Method {
    fn as_ref(&self) -> &str {
        match self {
            Self::Get => "GET",
            Self::Post => "POST",
            Self::Put => "PUT",
            Self::Head => "HEAD",
            Self::Patch => "PATCH",
            Self::Delete => "DELETE",
        }
    }
}

impl FromStr for Method {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "GET" => Ok(Method::Get),
            "POST" => Ok(Method::Post),
            "PUT" => Ok(Method::Put),
            "HEAD" => Ok(Method::Head),
            "PATCH" => Ok(Method::Patch),
            "DELETE" => Ok(Method::Delete),
            _ => Err(()),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::time::Duration;

    fn create_args(params: Vec<&str>) -> Vec<String> {
        let args: Vec<String> = std::iter::once("program_name".to_string())
            .chain(params.iter().map(|s| s.to_string()))
            .collect();
        args
    }

    #[test]
    fn test_default_args() {
        let params = create_args(vec![]);
        let args = Args::new(&params);

        assert_eq!(args.url, "");
        assert!(matches!(args.method, Method::Get));
        assert_eq!(args.body, None);
        assert_eq!(args.ship_file, "");
        assert!(matches!(args.show_headers, ShowHeaders::None));
        assert!(args.headers.is_empty());
        assert!(!args.save);
        assert_eq!(args.ship_output_folder, "");
        assert!(!args.insecure);
    }

    #[test]
    fn test_all_parameters() {
        let params = create_args(vec![
            "-t",
            "10",
            "-m",
            "POST",
            "-u",
            "https://example.com",
            "-f",
            "data.json",
            "-h",
            "all",
            "-c",
            "header1;header2",
            "-s",
            "true",
            "-d",
            "output",
            "-b",
            "body_content",
            "-i",
            "true",
        ]);
        let args = Args::new(&params);

        assert_eq!(args.timeout, Duration::from_secs(10));
        assert!(matches!(args.method, Method::Post));
        assert_eq!(args.url, "https://example.com");
        assert_eq!(args.ship_file, "data.json");
        assert!(matches!(args.show_headers, ShowHeaders::All));
        assert_eq!(args.headers, vec!["header1", "header2"]);
        assert!(args.save);
        assert_eq!(args.ship_output_folder, "output");
        assert_eq!(args.body, Some("body_content"));
        assert!(args.insecure);
    }

    #[test]
    fn test_method_parsing() {
        let test_cases = vec![
            ("GET", Method::Get),
            ("POST", Method::Post),
            ("PUT", Method::Put),
            ("HEAD", Method::Head),
            ("PATCH", Method::Patch),
            ("DELETE", Method::Delete),
        ];

        for (input, _method) in test_cases {
            let params = create_args(vec!["-m", input]);
            let args = Args::new(&params);
            assert!(matches!(args.method, _method));
        }
    }

    #[test]
    fn test_invalid_method_fallback() {
        let params = create_args(vec!["-m", "INVALID"]);
        let args = Args::new(&params);
        assert!(matches!(args.method, Method::Get));
    }

    #[test]
    fn test_show_headers_parsing() {
        let test_cases = vec![
            ("all", ShowHeaders::All),
            ("res", ShowHeaders::Res),
            ("none", ShowHeaders::None),
        ];

        for (input, _expected) in test_cases {
            let params = create_args(vec!["-h", input]);
            let args = Args::new(&params);
            assert!(matches!(args.show_headers, _expected));
        }
    }

    #[test]
    fn test_invalid_show_headers_fallback() {
        let params = create_args(vec!["-h", "invalid"]);
        let args = Args::new(&params);
        assert!(matches!(args.show_headers, ShowHeaders::None));
    }

    #[test]
    fn test_timeout_fallback() {
        let params = create_args(vec!["-t", "invalid"]);
        let args = Args::new(&params);
        assert_eq!(args.timeout, Duration::from_secs(30));
    }

    #[test]
    fn test_body_parameter() {
        let params = create_args(vec!["-b", "test_body"]);
        let args = Args::new(&params);
        assert_eq!(args.body, Some("test_body"));
    }

    #[test]
    fn test_insecure_flag() {
        let params = create_args(vec!["-i", "true"]);
        let args = Args::new(&params);
        assert!(args.insecure);

        let params = create_args(vec!["-i", "false"]);
        let args = Args::new(&params);
        assert!(!args.insecure);

        let params = create_args(vec!["-i", "invalid"]);
        let args = Args::new(&params);
        assert!(!args.insecure); // Default
    }

    #[test]
    fn test_save_flag() {
        let params = create_args(vec!["-s", "true"]);
        let args = Args::new(&params);
        assert!(args.save);

        let params = create_args(vec!["-s", "false"]);
        let args = Args::new(&params);
        assert!(!args.save);

        let params = create_args(vec!["-s", "invalid"]);
        let args = Args::new(&params);
        assert!(!args.save); // Default
    }

    #[test]
    fn test_headers_parsing() {
        let params = create_args(vec!["-c", "header1;header2;header3"]);
        let args = Args::new(&params);
        assert_eq!(args.headers, vec!["header1", "header2", "header3"]);
    }

    #[test]
    fn test_odd_argument_handling() {
        let params = create_args(vec!["-u", "url", "extra"]);
        let args = Args::new(&params);
        assert_eq!(args.url, "url");

        let params = create_args(vec!["unknown", "-u", "url"]);
        let args = Args::new(&params);
        assert_eq!(args.url, "");
    }
}
