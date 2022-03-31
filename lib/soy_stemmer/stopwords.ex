defmodule SoyStemmer.Stopwords do
  def load(lang) do
    lang
    |> filepath()
    |> load_file()
  end

  def load_file(filepath) do
    if !File.exists?(filepath) do
      {:error, {:stopwords_file_does_not_exist, filepath}}
    else
      words =
        filepath
        |> File.stream!([:utf8], :line)
        |> parse()
        |> Enum.to_list()

      {:ok, words}
    end
  end

  @doc false
  def filepath(lang) do
    rel_path = Path.join(["lang", lang, "stopwords.txt"])

    :soy_stemmer
    |> Application.app_dir("priv")
    |> Path.join(rel_path)
  end

  @line_comment_regex ~r/\|/

  @doc false
  def parse(stream) do
    stream
    |> Stream.map(fn line ->
      line
      |> String.trim()
      |> String.split(@line_comment_regex, include_captures: true)
      |> case do
        [sw, "|" | _] ->
          String.trim(sw)

        [sw_alone] ->
          String.trim(sw_alone)
      end
    end)
    |> Stream.filter(fn
      "" -> false
      _ -> true
    end)
  end
end
