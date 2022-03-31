defmodule SoyStemmer do
  use Rustler, otp_app: :soy_stemmer, crate: "soy_stemmer"

  alias SoyStemmer.Stopwords

  defp err, do: :erlang.nif_error(:soy_stemmer_nif_not_loaded)

  def new do
    new("en")
  end

  def new(lang) do
    with(
      {:ok, words} <- stopwords(lang),
      {:ok, filter} <- new(lang, words)
    ) do
      {:ok, filter}
    end
  end

  def new(lang, stopwords) do
    case new_filter(lang, stopwords) do
      ref when is_reference(ref) -> {:ok, {__MODULE__, ref}}
      {:error, _} = err -> err
    end
  end

  def stopwords(lang \\ "en") do
    Stopwords.load(lang)
  end

  def stem({__MODULE__, ref}, words) do
    filter_stem(ref, words)
  end

  def remove_stopwords({__MODULE__, ref}, words) do
    filter_remove_stopwords(ref, words)
  end

  def remove_stopwords_and_stem({__MODULE__, ref}, words) do
    filter_remove_stopwords_and_stem(ref, words)
  end

  @doc false
  def new_filter(_lang, _stopwords), do: err()

  @doc false
  def filter_stem(_filter, _words), do: err()

  @doc false
  def filter_remove_stopwords(_filter, _words), do: err()

  @doc false
  def filter_remove_stopwords_and_stem(_filter, _words), do: err()
end
