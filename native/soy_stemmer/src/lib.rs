use hashbrown::HashSet;
use rust_stemmers::{Algorithm, Stemmer};
use rustler::{Error as NifError, NifResult, ResourceArc};

struct FilterEx {
    stemmer: Stemmer,
    stopwords: StopWordsSet,
}

fn lang_name_to_algo(name: &str) -> NifResult<Algorithm> {
    use Algorithm::*;
    match name {
        "en" => Ok(English),
        "ar" => Ok(Arabic),
        "da" => Ok(Danish),
        "du" => Ok(Dutch),
        "fi" => Ok(Finnish),
        "fr" => Ok(French),
        "ge" => Ok(German),
        "gr" => Ok(Greek),
        "hu" => Ok(Hungarian),
        "it" => Ok(Italian),
        "no" => Ok(Norwegian),
        "po" => Ok(Portuguese),
        "ro" => Ok(Romanian),
        "ru" => Ok(Russian),
        "sp" => Ok(Spanish),
        "sw" => Ok(Swedish),
        "ta" => Ok(Tamil),
        "tu" => Ok(Turkish),
        _ => Err(NifError::Term(Box::new(format!(
            "stemming language not supported: {}",
            name
        )))),
    }
}

impl FilterEx {
    fn new(lang: &str, stopwords: Vec<String>) -> NifResult<FilterEx> {
        let algo = lang_name_to_algo(lang)?;
        Ok(FilterEx {
            stemmer: Stemmer::create(algo),
            stopwords: StopWordsSet::from(stopwords),
        })
    }
}

struct StopWordsSet {
    set: HashSet<String>,
}

impl StopWordsSet {
    fn contains(&self, word: &str) -> bool {
        self.set.contains(word)
    }
}

impl From<Vec<String>> for StopWordsSet {
    fn from(words: Vec<String>) -> Self {
        let mut set = HashSet::with_capacity(words.len());
        for word in words {
            let lower_word = word.to_lowercase();
            set.insert(lower_word);
        }
        set.shrink_to_fit();
        StopWordsSet { set }
    }
}

type Filter = ResourceArc<FilterEx>;

#[rustler::nif]
fn new_filter(name: String, stopwords: Vec<String>) -> NifResult<ResourceArc<FilterEx>> {
    Ok(ResourceArc::new(FilterEx::new(&name[..], stopwords)?))
}

#[rustler::nif]
fn filter_stem(filt: Filter, words: Vec<String>) -> Vec<String> {
    let stemmer = &filt.stemmer;
    words
        .into_iter()
        .map(|w| w.to_lowercase())
        .map(|w| stemmer.stem(&w).to_string())
        .collect()
}

#[rustler::nif]
fn filter_remove_stopwords(filt: Filter, words: Vec<String>) -> Vec<String> {
    let stopwords = &filt.stopwords;
    words
        .into_iter()
        .map(|w| w.to_lowercase())
        .filter(|w| !stopwords.contains(&w[..]))
        .collect()
}

#[rustler::nif]
fn filter_remove_stopwords_and_stem(filt: Filter, words: Vec<String>) -> Vec<String> {
    let stopwords = &filt.stopwords;
    let stemmer = &filt.stemmer;
    words
        .into_iter()
        .map(|w| w.to_lowercase())
        .filter(|w| !stopwords.contains(&w[..]))
        .map(|w| stemmer.stem(&w).to_string())
        .collect()
}

fn load(env: rustler::Env, _: rustler::Term) -> bool {
    rustler::resource!(FilterEx, env);
    true
}

rustler::init!(
    "Elixir.SoyStemmer",
    [
        new_filter,
        filter_stem,
        filter_remove_stopwords,
        filter_remove_stopwords_and_stem
    ],
    load = load
);
