use std::fs::{File, OpenOptions};
use std::io::{Read, Write};
use std::time::Duration;
use std::{cell::RefCell, time::Instant};

use curl::easy::{Easy, Form, InfoType, List, Transfer};
use serde_json::Value;

use crate::arguments::{Args, ShowHeaders};
use crate::xml::format_xml;

#[derive(Debug)]
pub struct Shipper<'a> {
    pub args: Args<'a>,
    inner_body: Option<String>,
}

impl<'a> Shipper<'a> {
    pub fn new(args: Args<'a>) -> Self {
        Self {
            args,
            inner_body: None,
        }
    }

    pub fn call(&mut self) {
        let filename = if self.args.save {
            std::fs::create_dir_all(self.args.ship_output_folder).unwrap();
            &format!("{}/{}", self.args.ship_output_folder, self.args.ship_file)
        } else {
            self.args.ship_file
        };

        let mut ship_file = OpenOptions::new()
            .create(true)
            .append(true)
            .open(filename)
            .expect("Unable to open file");

        let response = RefCell::new(vec![]);
        let mut curl = Easy::new();
        curl.url(self.args.url).unwrap();
        curl.custom_request(self.args.method.as_ref()).unwrap();
        curl.timeout(self.args.timeout).unwrap();
        curl.ssl_verify_host(!self.args.insecure).unwrap();
        curl.ssl_verify_peer(!self.args.insecure).unwrap();

        let is_multipart = self.args.headers.iter().any(|header| {
            header.to_lowercase().contains("content-type") && header.contains("multipart/form-data")
        });

        if let ShowHeaders::All = self.args.show_headers {
            curl.verbose(true).unwrap();
        }

        let headers = &self.args.headers;
        if !headers.is_empty() {
            let mut list = List::new();
            for header in headers {
                list.append(header).unwrap();
            }
            curl.http_headers(list).unwrap();
        }

        let response_headers = RefCell::new(vec![]);

        if let Some(body) = self.args.body {
            if is_multipart {
                curl.httppost(self.new_form(body)).unwrap();
            } else if body.starts_with("@") {
                let body = std::fs::read_to_string(body.replace("@", "")).unwrap();
                self.inner_body = Some(body);
                curl.post_field_size(self.inner_body.as_ref().unwrap().len() as u64)
                    .unwrap();
            } else {
                self.inner_body = Some(body.to_string());
                curl.post_field_size(body.len() as u64).unwrap();
            }
        }

        let mut transfer = curl.transfer();

        if let ShowHeaders::All = self.args.show_headers {
            transfer
                .debug_function(|infotype, data| {
                    match infotype {
                        InfoType::Text | InfoType::HeaderIn | InfoType::HeaderOut => {
                            ship_file.write_all(data).unwrap();
                        }
                        _ => {}
                    };
                })
                .unwrap();
        }

        transfer
            .header_function(|header| {
                if let Ok(header_str) = std::str::from_utf8(header) {
                    response_headers
                        .borrow_mut()
                        .push(header_str.trim_end().to_string());
                }
                true
            })
            .unwrap();

        if self.inner_body.is_some() && !is_multipart {
            let body = self.inner_body.as_ref().unwrap();
            self.set_body(body, &mut transfer);
        }

        let start = Instant::now();
        transfer
            .write_function(|data| {
                response.borrow_mut().extend_from_slice(data);
                Ok(data.len())
            })
            .unwrap();

        transfer.perform().unwrap();
        drop(transfer);
        let elapsed = start.elapsed();

        self.write_code_and_time_to_file(curl.response_code().unwrap_or(0), elapsed)
            .unwrap();

        if response_headers.borrow().iter().any(|header| {
            header.to_lowercase().contains("content-type") && header.contains("application/xml")
        }) {
            let borrow_response = response.borrow();
            let xml_response = std::str::from_utf8(borrow_response.as_slice()).unwrap();
            let pretty = format_xml(xml_response).unwrap();
            self.write_to_ship_file(&mut ship_file, &pretty, response_headers.borrow().to_vec());
        } else {
            let s: Value = serde_json::from_slice(response.borrow().as_slice()).unwrap();
            let pretty = serde_json::to_string_pretty(&s).unwrap();
            self.write_to_ship_file(&mut ship_file, &pretty, response_headers.borrow().to_vec());
        }
    }

    fn write_to_ship_file(&self, ship_file: &mut File, content: &str, headers: Vec<String>) {
        match self.args.show_headers {
            ShowHeaders::Res => {
                let headers_to_str = headers.join("\n");
                ship_file.write_all(headers_to_str.as_bytes()).unwrap();
                ship_file.write_all(b"\n").unwrap();
            }
            ShowHeaders::All => ship_file.write_all(b"\n").unwrap(),
            ShowHeaders::None => {}
        }
        ship_file.write_all(content.as_bytes()).unwrap();
    }

    fn write_code_and_time_to_file(
        &self,
        status_code: u32,
        elapsed: Duration,
    ) -> std::io::Result<()> {
        let mut file = std::fs::File::create("/tmp/ship_code_time_tmp")?;
        let code_time = format!("{},{:.4}", status_code, elapsed.as_secs_f64());

        file.write_all(code_time.as_bytes())?;
        Ok(())
    }

    fn set_body(&self, data: &'a str, transfer: &mut Transfer<'a, 'a>) {
        let mut data = data.as_bytes();
        transfer
            .read_function(move |buf| Ok(data.read(buf).unwrap_or(0)))
            .unwrap();
    }

    fn new_form(&self, body: &str) -> Form {
        let mut form = Form::new();

        let fields: Vec<&str> = body.split('&').collect();
        for f in fields {
            let (field, value) = f.split_once('=').unwrap();
            if value.starts_with("@") {
                form.part(field)
                    .file(&value.replace("@", ""))
                    .add()
                    .unwrap();
            }
            form.part(field).contents(value.as_bytes()).add().unwrap();
        }

        form
    }
}
