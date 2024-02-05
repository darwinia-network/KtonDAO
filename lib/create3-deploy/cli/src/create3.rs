use cast::SimpleCast;
use clap::Parser;
use ethers::{
    core::rand::thread_rng,
    types::{Address, Bytes, H256},
    utils::{get_create2_address_from_hash, keccak256},
};
use eyre::{Result, WrapErr};
use rayon::prelude::*;
use regex::RegexSetBuilder;
use std::{str::FromStr, time::Instant};

/// CLI arguments for `cast create3`
#[derive(Debug, Clone, Parser)]
#[clap(name = "create3", version = "0.1.0")]
pub struct Create3 {
    /// Prefix for the contract address.
    #[clap(
        long,
        short,
        required_unless_present_any = &["ends_with", "matching"],
        value_name = "HEX"
    )]
    starts_with: Option<String>,

    /// Suffix for the contract address.
    #[clap(long, short, value_name = "HEX")]
    ends_with: Option<String>,

    /// Sequence that the address has to match.
    #[clap(long, short, value_name = "HEX")]
    matching: Option<String>,

    /// Case sensitive matching.
    #[clap(short, long)]
    case_sensitive: bool,

    /// Address of the create3 factory contract.
    #[clap(
        short,
        long,
        default_value = "0x0000000000C76fe1798a428F60b27c6724e03408",
        value_name = "ADDRESS"
    )]
    factory: Address,

    /// Address of the contract deployer.
    #[clap(
        short,
        long,
        default_value = "0x0f14341A7f464320319025540E8Fe48Ad0fe5aec",
        value_name = "ADDRESS"
    )]
    deployer: Address,
}

#[allow(dead_code)]
pub struct Create3Output {
    pub address: Address,
    pub salt: H256,
}

impl Create3 {
    pub fn run(self) -> Result<Create3Output> {
        let Create3 {
            starts_with,
            ends_with,
            matching,
            case_sensitive,
            factory,
            deployer,
        } = self;

        let mut regexs = vec![];

        if let Some(matches) = matching {
            if starts_with.is_some() || ends_with.is_some() {
                eyre::bail!("Either use --matching or --starts/ends-with");
            }

            let matches = matches.trim_start_matches("0x");

            if matches.len() != 40 {
                eyre::bail!("Please provide a 40 characters long sequence for matching");
            }

            hex::decode(matches.replace('X', "0")).wrap_err("invalid matching hex provided")?;
            // replacing X placeholders by . to match any character at these positions

            regexs.push(matches.replace('X', "."));
        }

        if let Some(prefix) = starts_with {
            regexs.push(format!(
                r"^{}",
                get_regex_hex_string(prefix).wrap_err("invalid prefix hex provided")?
            ));
        }
        if let Some(suffix) = ends_with {
            regexs.push(format!(
                r"{}$",
                get_regex_hex_string(suffix).wrap_err("invalid prefix hex provided")?
            ))
        }

        debug_assert!(
            regexs.iter().map(|p| p.len() - 1).sum::<usize>() <= 40,
            "vanity patterns length exceeded. cannot be more than 40 characters",
        );

        let regex = RegexSetBuilder::new(regexs)
            .case_insensitive(!case_sensitive)
            .build()?;

        let init_code_hash: H256 =
            "0x21c35dbe1b344a2488cf3321d6ce542f8e9f305544ff09e4993a62319a497c1f".parse()?;

        println!("Starting to generate deterministic contract address...");
        let timer = Instant::now();
        let (salt, addr) = std::iter::repeat(())
            .par_bridge()
            .map(|_| {
                let salt = H256::random_using(&mut thread_rng());

                let mut bytes = Vec::with_capacity(52);
                bytes.extend_from_slice(deployer.as_bytes());
                bytes.extend_from_slice(salt.as_bytes());

                let mix_salt = keccak256(bytes);
                let mix_salt = Bytes::from(mix_salt);

                let proxy =
                    get_create2_address_from_hash(factory, mix_salt.clone(), init_code_hash);

                let addr = SimpleCast::to_checksum_address(&get_contract_address_at_nonce_1(proxy));

                let salt = Bytes::from(salt.to_fixed_bytes());
                (salt, addr)
            })
            .find_any(move |(_, addr)| {
                let addr = addr.to_string();
                let addr = addr.strip_prefix("0x").unwrap();
                regex.matches(addr).into_iter().count() == regex.patterns().len()
            })
            .unwrap();

        let salt = H256::from_slice(salt.to_vec().as_slice());
        let address = Address::from_str(&addr).unwrap();

        println!(
            "Successfully found contract address in {} seconds.\nAddress: {}\nSalt: {:?}",
            timer.elapsed().as_secs(),
            addr,
            salt
        );

        Ok(Create3Output { address, salt })
    }
}

fn get_regex_hex_string(s: String) -> Result<String> {
    let s = s.strip_prefix("0x").unwrap_or(&s);
    let pad_width = s.len() + s.len() % 2;
    hex::decode(format!("{s:0<pad_width$}"))?;
    Ok(s.to_string())
}

fn get_contract_address_at_nonce_1(proxy: Address) -> Address {
    let mut bytes = Vec::with_capacity(23);
    bytes.push(0xd6);
    bytes.push(0x94);
    bytes.extend_from_slice(proxy.as_bytes());
    bytes.push(0x01);

    let hash = keccak256(bytes);

    let mut bytes = [0u8; 20];
    bytes.copy_from_slice(&hash[12..]);
    Address::from(bytes)
}
