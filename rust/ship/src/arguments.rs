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
