use xml::reader::{ParserConfig, XmlEvent as ReadEvent};
use xml::writer::{EmitterConfig, XmlEvent as WriteEvent};

pub fn format_xml(src: &str) -> Result<String, Box<dyn std::error::Error>> {
    let mut dest = Vec::new();
    let reader = ParserConfig::new()
        .trim_whitespace(true)
        .create_reader(src.as_bytes());

    let mut writer = EmitterConfig::new()
        .perform_indent(true)
        .create_writer(&mut dest);

    for event in reader {
        match event.map_err(|e| e.to_string())? {
            ReadEvent::StartElement {
                name, attributes, ..
            } => {
                let elem_name = name.local_name.as_str();
                let mut elem = WriteEvent::start_element(elem_name);

                let attrs: Vec<_> = attributes
                    .iter()
                    .map(|attr| (attr.name.local_name.as_str(), attr.value.as_str()))
                    .collect();

                for (name, value) in attrs {
                    elem = elem.attr(name, value);
                }
                writer.write(elem)?;
            }
            ReadEvent::EndElement { .. } => {
                writer.write(WriteEvent::end_element())?;
            }
            ReadEvent::Characters(text) => {
                writer.write(WriteEvent::characters(&text))?;
            }
            ReadEvent::CData(text) => {
                writer.write(WriteEvent::cdata(&text))?;
            }
            ReadEvent::Comment(text) => {
                writer.write(WriteEvent::comment(&text))?;
            }
            _ => {}
        }
    }

    Ok(String::from_utf8(dest)?)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_format_xml() {
        let input = r#"<root><child attr="value">Text</child></root>"#;
        let expected_output = r#"<?xml version="1.0" encoding="UTF-8"?>
<root>
  <child attr="value">Text</child>
</root>"#;

        let result = format_xml(input).unwrap();
        assert_eq!(result, expected_output);
    }

    #[test]
    fn test_format_xml_with_malformed_input() {
        let input = r#"<root><child></root>"#;
        let result = format_xml(input);
        assert!(result.is_err());
    }
}
